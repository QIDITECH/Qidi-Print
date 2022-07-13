# -*- coding: utf-8 -*-

import subprocess
import re
import threading
import platform
from socket import *
from plugins.GCodeWriter.GCodeWriter import GCodeWriter
from PyQt5.QtCore import QUrl, pyqtSignal, pyqtProperty, QEvent, Q_ENUMS
from UM.FlameProfiler import pyqtSlot
import subprocess
import struct
from UM.Mesh.MeshWriter import MeshWriter
from UM.Qt.QtApplication import QtApplication
import time
import os
from os import path
from UM.Application import Application
from PyQt5.QtCore import pyqtProperty, pyqtSignal, QObject, QUrl
import UM.Qt.ListModel
import traceback
import sys
from UM.Message import Message
from UM.i18n import i18nCatalog
from UM.Logger import Logger
from PyQt5.QtWidgets import QFileDialog, QMessageBox
from UM.Preferences import Preferences
from .CuraConf import *
from UM.Resources import  Resources
from UM.Platform import Platform

i18n_catalog = i18nCatalog("cura")

class NetDevice():
    def __init__(self):
        self.ipaddr = ''
        self.name = 'undefined'

    def __str__(self):
        s = ('Device addr:'+self.ipaddr + '==' + self.name)
        return s

class MyWifiSend(QObject):
    SEND_DONE = 0
    CONNECT_TIMEOUT = 1
    WRITE_ERROR = 2
    FILE_EMPTY = 3
    FILE_NOT_OPEN = 4
    SEND_RUNNING = 5
    FILE_NOT_SAVE = 6
    CANNOT_SART_PRINT = 7
    def __init__(self):
        super(MyWifiSend, self).__init__()              #不运行父类初始化，
        self.devices = []           #NetDevice
        self.isLocalFile = False
        self._localTempGcode = ''
        self._targetIP = ''
        self.PORT = 3000
        self.BUFSIZE = 256 * 5
        self.RECVBUF = 256 * 5
        self.targetSendFileName = ''
        self.targetSendFileNameBase = ''
        self.isLocalFile = ''
        self.sendNow = 0
        self.sendMax = 0
        self.sock = socket(AF_INET, SOCK_DGRAM)
        self.sock.setsockopt(SOL_SOCKET, SO_BROADCAST, 1)
        self.sock.settimeout(3)
        self._scan_in_progress = False
        self.scanDeviceThread()

        self._sending_in_progress = False

        self._send_thread = None
        self._file_encode = 'utf-8'

    def _generate_broad_addr(self,targetIP, maskstr):
        iptokens = list(map(int, targetIP.split(".")))
        masktokens = list(map(int, maskstr.split(".")))
        broadlist = []
        for i in range(len(iptokens)):
            ip = iptokens[i]
            mask = masktokens[i]
            broad = ip & mask | (~mask & 255)
            broadlist.append(broad)
        return '.'.join(map(str, broadlist))


    def _getAllBroadcast(self):
        ipconfig_process = subprocess.Popen("ifconfig" if (Platform.isLinux() or Platform.isOSX()) else "ipconfig",
                               stdout=subprocess.PIPE,shell=True)
        output = ipconfig_process.stdout.read().decode("utf-8", 'ignore')
        allIPlist = re.findall(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}',output)
        Logger.log("i", allIPlist)
        
        allIP = ""
        for j in allIPlist:
            if j.count("255.255") < 1:
                allIP += j + "   "
        Logger.log("i", allIP)
        Preferences.getInstance().setValue("general/iplist", allIP)

        inputIP = Preferences.getInstance().getValue("general/input_ip")
        if inputIP == "Please input host IP.":
            ipList = gethostbyname_ex(gethostname())
            Logger.log("i", ipList)
            if(len(ipList) == 3):
                ipList = ipList[2]
        else:
            ipList = [inputIP]
            Logger.log("i", ipList)

        broadcast = []
        for i in range(len(allIPlist)):
            ipaddr = allIPlist[i]
            if(ipaddr in ipList and ipaddr != '127.0.0.1') and (i + 1) < len(allIPlist):
                if (Platform.isLinux() or Platform.isOSX()):
                    broadcast.append(allIPlist[i + 1])
                else:
                    broadcast.append(self._generate_broad_addr(ipaddr, allIPlist[i + 1]))

        if not broadcast:
            Logger.log("i","Cann't fine valid boradcast,use all IP")
            #broadcast = allIPlist
            if (Platform.isLinux() or Platform.isOSX()):
                broadcast.append(ipList[0])
            else:
                broadcast.append(self._generate_broad_addr(ipList[0], '255.255.255.0'))
        Logger.log("i", broadcast)
        return broadcast

    @pyqtSlot()
    def scanDeviceThreadByInputIP(self):
        threading.Thread(target=self.scanDevice).start()

    @pyqtSlot()
    def scanDeviceThread(self):
        Logger.log("i", "..........scan device")
        if self._scan_in_progress:
            return
        threading.Thread(target=self.scanDevice).start()

    @pyqtSlot()
    def updateIPList(self):
        self.IPListChanged.emit()

    def _isDumplicateIP(self,ip):
        for device in self.devices:
            if ip == device.ipaddr:
                return True
        return False
    # def __LINE__(funcGetFile = ''):######call method:__LINE__(__file__)
    def scanDevice(self):
        self.devices = []
        self.IPListChanged.emit()           #先清空

        self._scan_in_progress = True
        self.sock.settimeout(2)

        for broadcast in self._getAllBroadcast():       #先把所有广播先发出去
            self.sock.sendto(b"M99999",(broadcast,self.PORT))
        while True:
            try:
                message,address = self.sock.recvfrom(2048)
            except:
                break
            Logger.log("i", message)
            Logger.log("i", address)
            message = message.decode('utf-8','ignore')
            message = message.replace('\r','')
            message = message.replace('\n', '')
            if message.find("ok MAC:") != -1:
                device = NetDevice()
                device.ipaddr = str(address[0])
                if not self._isDumplicateIP(device.ipaddr):     #相同的IP不扫入
                    if 'NAME:' in message:
                        device.name = message[message.find('NAME:') + len('NAME:'):].split(" ")[0]
                    Logger.log("i", device)

                    self.devices.append(device)

                    self.IPListChanged.emit()

        self.IPListChanged.emit()
        self._scan_in_progress = False
        Logger.log("i", "device scan done")

    # ========此类为接受qml中传出的接收方IP接受完毕就压缩然后发送=========
    @pyqtSlot()  # 输入参数为str类型
    def stopSending(self):
        self._abort = True


    @pyqtSlot(str,str)  # 输入参数为str类型
    def renameDevice(self, newName,strIP):
        ss = strIP.split('/')
        if(len(ss) >= 2):
            strIP = ss[-1]
        else:
            return

        newName = newName.replace('&','%')      #为了避免和校验和的冲突
        if QIDI_MACHINE:
            newName = newName.replace('@','#')
            try:
                newName += '@' + Application.getInstance().getGlobalContainerStack().getProperty("machine_name", "value").lower()
            except:
                pass

        str_cmd = "U100 "+ "'"+ newName  +"'"
        b_cmd = str_cmd.encode('utf-8')
        checkSum = 0
        for i in b_cmd:
            checkSum ^= i
        b_cmd = b_cmd + b"&"+ str(checkSum).encode('utf-8') + b"&"
        Logger.log("i", b_cmd)
        try:
            self.sock.sendto(b_cmd, (strIP, self.PORT))
            self.sock.settimeout(0.2)
            message, address = self.sock.recvfrom(self.BUFSIZE)
        except timeout:
            pass
        except:
            traceback.print_exc()
        self.scanDeviceThread()


    @pyqtSlot(str,str)  # 输入参数为str类型
    def startSending(self, fileName,strIP):
        ss = strIP.split('/')
        if(len(ss) >= 2):
            strIP = ss[-1]
        else:
            return
        self._targetIP = strIP

        self.targetSendFileNameBase = fileName
        self.targetSendFileName = fileName + ".gcode.tz"
        self._send_thread = threading.Thread(target=self.startSendingThread)
        self._send_thread.daemon = True
        self._send_thread.start()


    def startSendingThread(self):
        self._result = MyWifiSend.SEND_RUNNING
        self._errorMsg = ""
        self._abort = False
        self._sending_in_progress = True
        Application.getInstance().getOutputDeviceManager().writeStarted.emit(None)
        self.progressChanged.emit();
        self._genTempGcodeFile()
        if self._result == MyWifiSend.SEND_RUNNING:
            self.dataCompressThread()
            if self._result == MyWifiSend.SEND_RUNNING:
                self.sendDatThread()

        if self._result == MyWifiSend.SEND_DONE:
            self.fileSendDoneChanged.emit()
            m = Message(i18n_catalog.i18nc("@info:status", "Send file {0} successfully", self.decodeCmd(self.encodeCmd(self.targetSendFileName))),
                        lifetime=0)
            m.show()
            Logger.log("i", "=============send success============")
        elif self._result == MyWifiSend.CONNECT_TIMEOUT:
            m = Message(i18n_catalog.i18nc("@info:status", " Connection timeout"), lifetime=0)
            m.show()
        elif self._result == MyWifiSend.WRITE_ERROR:
            m = Message(i18n_catalog.i18nc("@info:status",self._errorMsg),lifetime=0)
            m.show()
            if 'create file' in self._errorMsg:
                m = Message(i18n_catalog.i18nc("@info:status", " Write error,please check that the SD card /U disk has been inserted"), lifetime=0)
                m.show()
        elif self._result == MyWifiSend.FILE_EMPTY:
            m = Message(i18n_catalog.i18nc("@info:status", " File empty"), lifetime=0)
            m.show()
        elif self._result == MyWifiSend.FILE_NOT_OPEN:
            m = Message(i18n_catalog.i18nc("@info:status", " File cann't open"), lifetime=0)
            m.show()
        elif self._result == MyWifiSend.FILE_NOT_SAVE:
            m = Message(i18n_catalog.i18nc("@info:status", " File cann't save"), lifetime=0)
            m.show()
        elif self._result == MyWifiSend.CANNOT_SART_PRINT:
            m = Message(i18n_catalog.i18nc("@info:status", " Cann't start print"), lifetime=0)
            m.show()
        self._sending_in_progress = False
        self.sendMax = 0  # 标识发送结束
        self.progressChanged.emit()
        Logger.log("i", "send done.....")

    @pyqtSlot(str)
    def saveDataWifi(self, setData):

        dialog = QFileDialog()

        dialog.setWindowTitle(i18n_catalog.i18nc("@title:window", "Save to File"))
        dialog.setFileMode(QFileDialog.AnyFile)
        dialog.setAcceptMode(QFileDialog.AcceptSave)

        # Ensure platform never ask for overwrite confirmation since we do this ourselves
        dialog.setOption(QFileDialog.DontConfirmOverwrite)

        if Platform.isLinux() and "KDE_FULL_SESSION" in os.environ:
            dialog.setOption(QFileDialog.DontUseNativeDialog)

        dialog.setNameFilters(["txt (*.txt)", "*.*"])
        # dialog.selectNameFilter(["txt (*.txt)", "*.*"])
        dialog.selectFile('router_hotspot_passwd.txt')
        stored_directory = Preferences.getInstance().getValue("local_file/dialog_save_path")
        dialog.setDirectory(stored_directory)
        if not dialog.exec_():
            return
        save_path = dialog.directory().absolutePath()
        Preferences.getInstance().setValue("local_file/dialog_save_path", save_path)

        path = dialog.selectedFiles()[0]
        Logger.log("i", "save path:",path)
        if(path.startswith('file:///')):
            path = os.path.normpath(path[8:])
        fp = open(path, "w+",  encoding="utf-8")
        fp.write(setData)
        fp.close()
        m = Message(i18n_catalog.i18nc("@info:status", " Save file to {0}",path), lifetime=0)
        m.show()

        # fp = open("data.gcode", 'w+', buffering=1)


# =====whz=="data.gcode"为切片模型的数据（只有发送模型数据的时候会使用到）===g_filename为将要在接受方创建的文件名（在发送本地文件的时候其也是发送文件的路径）====

# ========此类为接受qml中传出的文件名数据（即g_filename的数据）=========


    def _genTempGcodeFile(self):
        self._localTempGcode = Resources.getStoragePath(Resources.Resources, "data.gcode")
        fp = open(self._localTempGcode, 'w+', buffering=1)
        if not fp:
            self._result = MyWifiSend.FILE_NOT_SAVE
        else:
            writer = GCodeWriter ()
            writer.write( fp, Application.getInstance().getController().getScene().getRoot(), MeshWriter.OutputMode.TextMode)
            fp.close()


    IPListChanged = pyqtSignal()
    @pyqtProperty("QVariantList",notify = IPListChanged)  # 输入参数为str类型
    def IPList(self):
        ipList = []
        for device in self.devices:
            name = device.name
            try:
                if QIDI_MACHINE:            #启迪的界面需要一个机型只显示一个指定的wifi设备
                    _ = name.split("@")
                    if(len(_) >= 2 and _[1] != Application.getInstance().getGlobalContainerStack().getProperty("machine_name", "value").lower()):
                        continue
                    name = _[0]
            except:
                traceback.print_exc()
            ipList.append('/'.join([name,device.ipaddr]))
        if not ipList:
            ipList.append('')
        return ipList

    progressChanged = pyqtSignal()
    @pyqtProperty(int,notify = progressChanged)  # 输入参数为str类型
    def progress(self):
       ratio = 0.0

       if  self._sending_in_progress == False:
           return 0
       elif self.sendMax != 0:
           ratio = 100*self.sendNow/self.sendMax
       return int((1 if ratio < 1 else ratio))

    fileSendDoneChanged = pyqtSignal()
    @pyqtProperty(bool,notify = fileSendDoneChanged)
    def sendFileDone(self):
        return len(self.targetSendFileName) != 0

    def dataCompressThread(self):
        Logger.log("i", "========start compress file=========")
        self.datamask = '[0-9]{1,12}\.[0-9]{1,12}'
        self.maxmask = '[0-9]'
        tryCnt = 0
        while True:#(send_ip):
            try:
                if self._abort:
                    break

                self.sock.settimeout(2)
                Logger.log("i", self._targetIP)
                self.sock.sendto(b"M4001", (self._targetIP, self.PORT))
                message, address = self.sock.recvfrom(self.BUFSIZE)
                pattern = re.compile(self.datamask)
                msg = message.decode('utf-8','ignore')
                if('X' not in msg or 'Y' not in msg or 'Z' not in msg ):
                    continue
                msg = msg.replace('\r','')
                msg = msg.replace('\n', '')
                msgs = msg.split(' ')
                Logger.log("i", msg)
                e_mm_per_step = z_mm_per_step = y_mm_per_step = x_mm_per_step = '0.0'
                s_machine_type = s_x_max = s_y_max = s_z_max = '0.0'
                for item in msgs:
                    _ = item.split(':')
                    if(len(_) == 2):
                        id = _[0]
                        value = _[1]
                        Logger.log("i", _)
                        if id == 'X':
                            x_mm_per_step = value
                        elif id == 'Y':
                            y_mm_per_step = value
                        elif id == 'Z':
                            z_mm_per_step = value
                        elif id == 'E':
                            e_mm_per_step = value
                        elif id == 'T':
                            _ = value.split('/')
                            if len(_) == 5:
                                s_machine_type = _[0]
                                s_x_max = _[1]
                                s_y_max = _[2]
                                s_z_max = _[3]
                        elif id == 'U':
                            self._file_encode = value.replace("'","")



                if Platform.isWindows():
                    exePath = os.path.join(os.path.dirname(sys.argv[0]), 'VC_compress_gcode.exe')
                    Logger.log("i", exePath)
                    if not os.path.exists(exePath):
                        exePath = ".\\VC_compress_gcode.exe"
                elif Platform.isOSX():
                    exePath = os.path.join(os.path.dirname(sys.argv[0]), 'VC_compress_gcode_MAC')
                    Logger.log("i", exePath)
                    if not os.path.exists(exePath):
                        exePath = "./VC_compress_gcode_MAC"
                elif Platform.isLinux():
                    exePath = "./VC_compress_gcode_Linux"
                cmd = "\"" + exePath + "\"" + " \"" + self._localTempGcode + "\" " + x_mm_per_step + " " + y_mm_per_step + " " + z_mm_per_step + " " + e_mm_per_step\
                         + ' \"' + path.dirname(self._localTempGcode) + '\" ' + s_x_max + " " + s_y_max + " " + s_z_max + " " + s_machine_type
                Logger.log("i", cmd)
                ret = subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True)
                Logger.log("i", ret.stdout.read().decode("utf-8", 'ignore'))
                break
            except timeout:
                tryCnt += 1
                if(tryCnt > 2):
                    self._result = MyWifiSend.CONNECT_TIMEOUT
                    break
            except:
                traceback.print_exc()
                break



    def encodeCmd(self,cmd):
        return cmd.encode(self._file_encode, 'ignore')
    def decodeCmd(self,cmd):
        return cmd.decode(self._file_encode,'ignore')

    def sendDatThread(self):
        Logger.log("i", "==========start send file============")
        try:
            while True:
                oldseek = 0
                self.sock.settimeout(2)
                Logger.log("i", "targetIP:" + self._targetIP)
                tryCnt = 0
                while True:
                    try:
                        if self._abort:
                            break
                        if tryCnt > 3:
                            self._result = MyWifiSend.CONNECT_TIMEOUT
                            break
                        self.sock.sendto(b"M4001\r\n", (self._targetIP, self.PORT))
                        message, address = self.sock.recvfrom(self.RECVBUF)
                        Logger.log("i", message)
                        break
                    except timeout:
                        Logger.log("w", "Socket M4001 timeout ")
                    except:
                        tryCnt += 1
                        traceback.print_exc()
                if self._result != MyWifiSend.SEND_RUNNING:
                    break

                if self._abort:
                    break

                filePath = self._localTempGcode + ".tz"
                Logger.log("i", "compress file path:" + filePath)
                try:
                    self.sendMax = path.getsize(filePath)
                    Logger.log("i", "compress file size:" + str(self.sendMax))
                    if(self.sendMax == 0):
                        self._result = MyWifiSend.FILE_EMPTY
                        break

                    fp = open(filePath, 'rb', buffering=1)
                    if not fp:
                        self._result = MyWifiSend.FILE_NOT_OPEN
                        Logger.log("i", "==error open file %s",filePath)
                        break
                except Exception as e:
                    Logger.log("w", str(e))
                    self._result = MyWifiSend.FILE_EMPTY
                    break
                fp.seek(0, 0)
                cmd = "M28 " + self.targetSendFileName
                Logger.log("i", "cmd:" + cmd)
                self.sock.sendto(self.encodeCmd(cmd), (self._targetIP, self.PORT))
                message, address = self.sock.recvfrom(self.RECVBUF)
                message = message.decode('utf-8','replace')
                Logger.log("i", "message:" +  message)
                if ('Error' in message):
                    self._result = MyWifiSend.WRITE_ERROR
                    self._errorMsg = message
                    break
                self.progressChanged.emit()
                self.sock.settimeout(0.1)
                lastProgress = 0
                lastDataArray = None
                finishedCnt = 0
                timeoutCnt = 0
                finishedRcvOkCnt = 0
                while True:
                    try:
                        if self._abort:
                            break
                        data = fp.read(self.BUFSIZE)
                        if not data:
                            Logger.log("i", "reach file end")
                            if finishedCnt >= 50 or not lastDataArray:       #连续5次，重发，如果也没收到重传类的响应，可以直接退出了,主要是防止类似快读完时，数据丢失
                                break
                            dataArray = lastDataArray
                            time.sleep(0.33)     #延时一下，等前面的缓存彻底清空
                            finishedCnt += 1
                        else:
                            finishedRcvOkCnt = finishedCnt = 0
                            check_sum = 0
                            data += b"000000"
                            dataArray = bytearray(data)
                            seek = fp.tell()
                            seekArray = struct.pack('>I', oldseek)
                            # Logger.log("i", "is  seek ========================")
                            oldseek = seek
                            # Logger.log("i", oldseek)
                            self.sendNow = seek
                            if(int(100*self.sendNow/self.sendMax) > int(100*lastProgress)):
                                lastProgress = self.sendNow/self.sendMax
                                self.progressChanged.emit()
                            datSize = len(dataArray) - 6

                            if datSize <= 0:
                                break

                            # dataArray += seekArray[0:4]
                            dataArray[datSize] = seekArray[3]
                            dataArray[datSize+1] = seekArray[2]
                            dataArray[datSize+2] = seekArray[1]
                            dataArray[datSize+3] = seekArray[0]

                            for i in range(0, datSize+4, 1):
                                check_sum ^= dataArray[i]
                            # sum = struct.pack('<h', check_sum)

                            # Logger.log("i", sum)
                            dataArray[datSize+4] = check_sum
                            # dataArray += sum[0:1]
                            dataArray[datSize + 5] = 0x83
                            # dataArray += b'0x83'

                            # Logger.log("i", dataArray)
                            lastDataArray = dataArray
                        self.sock.sendto(dataArray, (self._targetIP, self.PORT))
                        # time.sleep(0)

                        message, address = self.sock.recvfrom(self.RECVBUF)
                        timeoutCnt = 0
                        # Logger.log("i", "状态信息===================")
                        message = message.decode('utf-8','replace')
                        # Logger.log("i", message)

                        if('ok' in message):
                            if(finishedRcvOkCnt > 3):      #确保数据发送完整了
                                break
                            else:
                                if(finishedCnt):
                                    finishedRcvOkCnt += 1
                                continue
                        elif ('Error') in message:
                            self._result = MyWifiSend.WRITE_ERROR
                            break
                        elif ('resend') in ((message)):
                            value = re.findall(r'resend \d+',message)
                            if value:
                                value = value[0].replace('resend ','')
                                oldseek = offset = int(value)
                                fp.seek(offset, 0)
                                Logger.log("i", "resend offset:" + str(offset))
                            else:
                                Logger.log("i", "Error offset:" + message)
                    except timeout:
                        if (finishedCnt < 4 and timeoutCnt > 150)  or finishedCnt > 45:         #差不多15s左右
                            print("finishedCnt: ",finishedCnt," timeoutcnt",timeoutCnt)
                            self._result = MyWifiSend.CONNECT_TIMEOUT
                            break
                        print("timeout:",timeoutCnt)
                        timeoutCnt += 1
                    except:
                        traceback.print_exc()
                fp.close()
                os.remove(filePath)
                break
            if not self._abort and self._result == MyWifiSend.SEND_RUNNING:
                self.sock.settimeout(2)
                tryCnt = 0
                while True:
                    try:
                        self.sock.sendto(b"M29", (self._targetIP, self.PORT))
                        message, address = self.sock.recvfrom(self.RECVBUF)
                        message = message.decode('utf-8','replace')
                        Logger.log("i", 'M29 rcv:' + message)
                        if 'Error' in message:
                            self._result = MyWifiSend.WRITE_ERROR
                            break
                        else:
                            self._result = MyWifiSend.SEND_DONE
                            break
                    except:
                        tryCnt += 1
                        Logger.log("i", "Try to Close file")
                        if tryCnt > 6:
                            self._result = MyWifiSend.CONNECT_TIMEOUT
                            break


        except:
            self._result = MyWifiSend.WRITE_ERROR
            traceback.print_exc()

    @pyqtSlot()
    def startPrint(self):
        self.sock.settimeout(2)
        tryCnt = 0
        while True:
            try:
                cmd = 'M6030 ":' + self.targetSendFileName + '" I1'
                Logger.log("i", 'Start print:' + cmd)
                self.sock.sendto(self.encodeCmd(cmd), (self._targetIP, self.PORT))
                message, address = self.sock.recvfrom(self.RECVBUF)
                message = message.decode('utf-8', 'replace')
                if "Error" in message:
                    self._result = MyWifiSend.CANNOT_SART_PRINT
                    break;
                else:
                    break;
            except:
                Logger.log("i", "Try to start print")
                traceback.print_exc()
                tryCnt += 1
                if tryCnt > 6:
                    self._result = MyWifiSend.CONNECT_TIMEOUT



    _instance = None
    ##  Return the singleton instance of the application object
    @classmethod
    def getInstance(cls, *args, **kwargs) -> "MyWifiSend":
        # Note: Explicit use of class name to prevent issues with inheritance.
        if not MyWifiSend._instance:
            MyWifiSend._instance = cls()
        return MyWifiSend._instance
    # Factory function, used by QML

if __name__ == '__main__':
    wifi = MyWifiSend.getInstance()
    time.sleep(4)
    wifi._localTempGcode = 'data.gcode'
    wifi._targetIP = '192.168.1.54'
    wifi.dataCompressThread()
