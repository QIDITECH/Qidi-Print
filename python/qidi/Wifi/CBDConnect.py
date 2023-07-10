# -*- coding: utf-8 -*-


import collections
import json
import sys
import threading
import time
import os
from os import path
from typing import cast

from QD.i18n import i18nCatalog
from PyQt5.QtCore import QUrl, QTimer, pyqtSignal, pyqtProperty, pyqtSlot, QCoreApplication, Qt, QObject
from PyQt5.QtWidgets import QFileDialog, QMessageBox
from PyQt5.QtCore import pyqtProperty, pyqtSignal, QObject, QUrl,QByteArray
from PyQt5.QtNetwork import QHttpMultiPart, QHttpPart, QNetworkRequest, QNetworkAccessManager, QNetworkReply, QTcpSocket,QUdpSocket,QHostAddress
from queue import Queue
from QD.Logger import Logger
from QD.Signal import Signal, signalemitter
from QD.Resources import  Resources
from socket import *
from QD.Message import Message
from QD.Application import Application
from QD.Platform import Platform
from QD.Mesh.MeshWriter import MeshWriter
from QD.PluginRegistry import PluginRegistry #To get the g-code output.
from QD.Settings.ContainerRegistry import ContainerRegistry

import subprocess

import traceback
import struct
import re

catalog = i18nCatalog("qidi")


class CBDConnect(QObject):
    SEND_DONE = 0
    CONNECTING = 1
    OPEN_FILE = 2
    CREATE_FILE = 3
    WRITING = 4
    FINISH_WRITING = 5

    CONNECT_TIMEOUT = 10
    WRITE_ERROR = 11
    FILE_EMPTY = 12
    FILE_NOT_OPEN = 13
    SEND_RUNNING = 14
    FILE_NOT_SAVE = 15
    CANNOT_SART_PRINT = 16

    def __init__(self):

        super(CBDConnect, self).__init__()              #不运行父类初始化，不知道原因，但是只有这样才能让下面的定时器被调用时能正常运行
        self._command_queue = Queue()
        self._socket = None
        self._update_timer = QTimer()
        self.select_ip =""
        self.first_connect = 0
        self.thisdict =	{
            "state":"",
            "E1Tem": "0",
            "E2Tem": "0",
            "BedTem": "0",
            "FanSpeed":"0",
            "E1TarTem": "0",
            "E2TarTem": "0",
            "BedTarTem": "0",
            "FanTarSpeed": "0",
            "VolTem": "0",
            "VolTarTem": "0",
            "FilaSen": "0",
            "x_location":"0",
            "y_location" : "0",
            "z_location":"0",
            "printer_type" : "None",
            "mac_address" : "None",
            "ip_address" : "None",
            "wifi_version" : "None",
            "extruder_num" : "1",
            "printsize_string" : "0/0/0",
            "printer_name" : "",
            "print_progress" : "0%",
            "homed_axes":"xyz",
            "chamber_cooling_enabled" : "False",
            "rapid_cooling_enabled" : "False",
            "volume_enabled" : "False",
            "close_machine_enabled":"False",
            "rapid_cooling_speed":"0",
            "chamber_cooling_speed":"0"
        }
        self.Error_dict={
            CBDConnect.CONNECT_TIMEOUT : catalog.i18nc("@info:status", " Connection timeout"),
            CBDConnect.WRITE_ERROR : catalog.i18nc("@info", "Write error,please check that the SD card /U disk has been inserted"),
            CBDConnect.FILE_EMPTY : catalog.i18nc("@info:status", " File empty"),
            CBDConnect.FILE_NOT_OPEN : catalog.i18nc("@info:status", " File cann't open"),
            CBDConnect.FILE_NOT_SAVE : catalog.i18nc("@info:status", " File cann't save"),
            CBDConnect.CANNOT_SART_PRINT : catalog.i18nc("@info:status", " Cann't start print")
        }
        self._sdFileList = False
        self._isPrinting = False
        self._isPause = False
        self._ischanging = False
        self.isGettingFiles = False
        self.sending_file_state = CBDConnect.SEND_DONE
        self._abort = False
        self.sdFiles = []
        self.show_text = ""
        self._localTempGcode = ""
        self.sendNow = 0
        self.sendMax = 0
        self.sock = socket(AF_INET, SOCK_DGRAM)
        self.sock.setsockopt(SOL_SOCKET, SO_BROADCAST, 1)
        self.sock.settimeout(3)
        self.PORT = 3000
        self.sendtime = 0
        self.RECVBUF = 256 * 8
        self.BUFSIZE = 256 * 5
        self._file_encode = 'utf-8'
        self._progress_message = None
        self._sending_progress = 0
        self.targetSendFileName = ""
        self._send_thread = None
        self._file_path = None
        self.getFilePath =""
        self._container_registry = ContainerRegistry.getInstance()

        #发送相关
        self.tryCnt = 0
        
    updateRequested = Signal()
    updateFileList = Signal()
    updateInfoRequested = Signal()
    setStateConnected = Signal()
    setStateClosed = Signal()
    updateShowText = Signal()
    
    def connect(self,ipstr):
        if self._socket is not None:
            self._socket.close()
            self._socket.abort()
            self._socket = None
        self._socket =  QUdpSocket()
        try:
            self._update_timer.timeout.disconnect(self._update)
        except:
            pass
        self._update_timer = QTimer()
        self._update_timer.setInterval(3000)  # TODO; Add preference for update interval
        self._update_timer.setSingleShot(False)
        self._update_timer.timeout.connect(self.update)
        Logger.log("d","self._socket.connectToHost %s" % ipstr)
        self._socket.connectToHost(ipstr, 3000)
        Logger.log("d", "CBD socket connecting ")
        self._socket.waitForConnected(2000)
        self._socket.readyRead.connect(self.on_read)
        self.select_ip = ipstr
        self._update_timer.start()

    def disconnect(self):
        self._isConnect = False
        self._update_timer.stop()
        if self._socket is not None:
            self._socket.readyRead.disconnect(self.on_read)
            self._socket.close()
        self._socket = None
        self.sdFiles = []
        self.show_text = ""
        self.select_ip = ""
        self.thisdict =	{
            "state":"",
            "E1Tem": "0",
            "E2Tem": "0",
            "BedTem": "0",
            "FanSpeed":"0",
            "E1TarTem": "0",
            "E2TarTem": "0",
            "BedTarTem": "0",
            "FanTarSpeed": "0",
            "VolTem": "0",
            "VolTarTem": "0",
            "FilaSen": "0",
            "x_location":"0",
            "y_location" : "0",
            "z_location":"0",
            "printer_type" : "None",
            "mac_address" : "None",
            "ip_address" : "None",
            "wifi_version" : "None",
            "extruder_num" : "1",
            "printsize_string" : "0/0/0",
            "printer_name" : "",
            "print_progress" : "0%",
            "homed_axes":"xyz",
            "chamber_cooling_enabled" : "False",
            "rapid_cooling_enabled" : "False",
            "volume_enabled" : "False",
            "close_machine_enabled":"False",
            "rapid_cooling_speed":"0",
            "chamber_cooling_speed":"0"
            }
        self.updateRequested.emit()
        self.updateFileList.emit()
        self.setStateClosed.emit()
        self.updateShowText.emit()
        self.updateInfoRequested.emit()
        self._isPrinting = False
        self._isPause = False

    def _sendCommand(self, cmd):
        if self._ischanging:
            if "G28" in cmd or "G0" in cmd:
                # Logger.log("d", "_sendCommand G28 in cmd or G0 in cmd-----------: %s" % str(cmd))
                return
        # Logger.log("d", "_sendCommand %s" % str(cmd))
        if self.isBusy():
            if "M20" in cmd:
                # Logger.log("d", "_sendCommand M20 in cmd-----------: %s" % str(cmd))
                return
        if self.isGettingFiles:
            if "M20" in cmd:
                Logger.log("d", "isGettingFiles _sendCommand M20 in cmd-----------: %s" % str(cmd))
                return
        if self._socket is not None and (self._socket.state() == 2 or self._socket.state() == 3):
            if isinstance(cmd, str):
                self._command_queue.put(cmd + "\r\n")
            elif isinstance(cmd, list):
                for eachCommand in cmd:
                    self._command_queue.put(eachCommand + "\r\n")
        elif self._socket is  None :
            tryCnt = 0
            while True:
                try:
                    # Logger.log("i", 'Start print:' + cmd)
                    self.sock.sendto(self.encodeCmd(cmd), (self.select_ip, self.PORT))
                    Logger.log("d", "_send_data: %s\r\n" % cmd)
                    self.show_text +="-> %s \r\n" % cmd
                    self.updateShowText.emit()

                    message, address = self.sock.recvfrom(self.RECVBUF)
                    message = message.decode('utf-8', 'replace')
                    Logger.log("d", "cbd recv: " + message)
                    self.show_text +="<- %s \r\n" % message
                    self.updateShowText.emit()
                    if "Error" in message:
                        self.send_state_change(CBDConnect.CANNOT_SART_PRINT)
                        break;
                    else:
                        break;
                except:
                    Logger.log("i", "Try to start print")
                    traceback.print_exc()
                    tryCnt += 1
                    if tryCnt > 6:
                        self.send_state_change(CBDConnect.CONNECT_TIMEOUT)

    def update(self):
        if self.sendtime > 10:
            self.disconnect()
            return
        if self._socket is not None and (self._socket.state() == 2 or self._socket.state() == 3):
            if self.sending_file_state != CBDConnect.SEND_DONE :
                Logger.log("i","Sending file")
                time.sleep(1)
            else:
                if self._command_queue.qsize() > 0:
                    _send_data = ""
                elif self.first_connect == 0:
                    _send_data = "M4001\r\nM99999\r\nM20"
                else:
                    _send_data = "M4000"
                while self._command_queue.qsize() > 0:
                    _queue_data = self._command_queue.get()
                    if "U100" in _queue_data:
                        changename = _queue_data[_queue_data.find("U100 '")+len("U100 '"):_queue_data.find("'&")]
                        checksum = _queue_data[_queue_data.find("'&")+len("'&"):-2]
                        changcmd = "U100 '"+changename+"'&"+checksum+"&"
                        self._socket.writeData(changcmd.encode('UTF-8'))
                        Logger.log("d", "_queue_data: %s\r\n" % changcmd)
                        send_cmd_list = _queue_data.split("\r\n")
                        for i in send_cmd_list:
                            if i != "":
                                self.show_text +="-> %s \r\n" % i
                        self.updateShowText.emit()
                        continue

                    if "M28" in _queue_data:
                        self.targetSendFileName = self.getFilePath.split("/")[-1]
                        self.sending_file_state = CBDConnect.CONNECTING
                        self.updateRequested.emit()
                        self._abort = False
                        self.show_progress_message()
                        self._file_path = self.getFilePath
                        self.getFilePath = None
                        self._send_thread = threading.Thread(target=self.sendDatThread)
                        self._send_thread.daemon = True
                        self._send_thread.start()
                        continue

                    if "M6032" in _queue_data:
                        self._abort = False
                        self.sending_file_state = CBDConnect.CONNECTING
                        self.updateRequested.emit()
                        self.download_command = _queue_data
                        self._send_thread = threading.Thread(target=self.download_file)
                        self._send_thread.daemon = True
                        self._send_thread.start()
                        continue

                    if self.isBusy():
                        if "M20" in _queue_data:
                            Logger.log("d", "_update M20 in _queue_data-----------: %s" % str(_queue_data))
                            continue
                    _send_data += _queue_data
                send_cmd_list = _send_data.split("\r\n")
                for i in send_cmd_list:
                    if i != "":
                        Logger.log("d", "_send_data: %s\r\n" % i)
                        self._socket.writeData(i.encode(sys.getfilesystemencoding()))
                        self.sendtime +=1
                        self.show_text +="-> %s \r\n" % i
                        time.sleep(0.2)
                self._socket.flush()
                self.updateShowText.emit()

        else:
            Logger.log("d", "UDP wifi reconnecting")
            self.connect(self.select_ip)

    def on_read(self):
        if not self._socket:
            self.disconnect()
            return
        try:
            if self.sending_file_state != CBDConnect.SEND_DONE:
                time.sleep(1)
                return
            while self._socket.hasPendingDatagrams():
                self.sendtime = 0
                datagram, host, port = self._socket.readDatagram(self._socket.pendingDatagramSize())
                message = datagram.decode('utf-8', 'ignore')
                message = message.rstrip()
                Logger.log("d", "cbd recv: " + message)
                if "Error:IP is connected by" in message or "Error:Wifi reboot" in message:
                    self.first_connect = 0
                self.show_text +="<- %s \r\n" % message
                self.updateShowText.emit()
                self.read_line(message)
        except Exception as e:
            print(e)

    def read_line(self, line):
        if "B" in line and "ok" in line and "X" in line and "Y" in line and "Z" in line and "E" in line and "U" in line and "T" in line:
            self.thisdict["extruder_num"] = line[line.find("T:") + len("T:"):line.find(" U:")].split("/")[-1]
            return
        if "B" in line and "E" in line and "X" in line and "Y" in line and "Z" in line and "F" in line and "D" in line and "T" in line:
            self.printer_info_update(line)
            return
        if line.startswith("ok MAC"):
            self.ip_info_update(line)
            return
        if self.printer_file_list_parse(line):
            return

    def printer_info_update(self, info):
        t0_temp = info[info.find("E1:") + len("E1:"):info.find("E2:")]
        t1_temp = info[info.find("E2:") + len("E2:"):info.find("X:")]
        bed_temp = info[info.find("B:") + len("B:"):info.find("E1:")]
        x_location = info[info.find("X:") + len("X:"):info.find("Y:")]
        y_location = info[info.find("Y:") + len("Y:"):info.find("Z:")]
        z_location = info[info.find("Z:") + len("Z:"):info.find("F:")]
        f_speed = info[info.find("F:") + len("F:"):info.find("D:")]
        if "L:" in info:
            d_read =info[info.find("D:") + len("D:"):info.find("I:")]
            t_read =info[info.find("T:") + len("T:"):]
            v_temp =info[info.find("I:") + len("I:"):info.find("L:")]
            l_read =info[info.find("L:") + len("L:"):info.find(" T:")]
            self.thisdict["VolTem"] = v_temp[0:v_temp.find("/")]
            try:
                if int(self.thisdict["VolTem"]) < 0:
                    self.thisdict["VolTem"] = "0"
            except:
                Logger.log("e","change realVolTemp type error")
            self.thisdict["VolTarTem"] = v_temp[v_temp.find("/") + 1:len(v_temp)]
            self.thisdict["FilaSen"] = l_read
        else:
            d_read =info[info.find("D:") + len("D:"):info.find("T:")]
            t_read =info[info.find("T:") + len("T:"):]
        if "I:" in t_read :
            t_read = t_read.split(" I:")[0]
            
        self.thisdict["E1Tem"] = t0_temp[0:t0_temp.find("/")]
        self.thisdict["E1TarTem"] = t0_temp[t0_temp.find("/") + 1:len(t0_temp)]
        self.thisdict["E2Tem"] = t1_temp[0:t1_temp.find("/")]
        try:
            if int(t1_temp[0:t1_temp.find("/")]) == 1077:
                self.thisdict["E2Tem"] = "0"
        except:
            pass
        self.thisdict["E2TarTem"] = t1_temp[t1_temp.find("/") + 1:len(t1_temp)]
        self.thisdict["BedTem"] = bed_temp[0:bed_temp.find("/")]
        self.thisdict["BedTarTem"] = bed_temp[bed_temp.find("/") + 1:len(bed_temp)]
        d_string = info[info.find(" D:") + 3: info.find(" T:") ]
        if int(d_string.split("/")[0])>0 and int(d_string.split("/")[1]) > 0 :
            self.thisdict["print_progress"] = str(int(int(d_string.split("/")[0])/int(d_string.split("/")[1])*100))+"%"
            # self.PrintprogressCBDChanged.emit()
            
        try:
            # self.realFanSpeed =  str(int(f_speed[0:f_speed.find("/")])/255*100)
            self.thisdict["FanSpeed"]   =  str(int(int(f_speed[0:f_speed.find("/")])/255*100))

        except:
            Logger.log("e","change realFanSpeed type error")

        self.thisdict["FanTarSpeed"]   =  f_speed[f_speed.find("/") + 1:len(f_speed)]
        self.thisdict["x_location"] = x_location
        self.thisdict["y_location"] = y_location
        self.thisdict["z_location"] = z_location


        try:
            #CBD状态判断
            if self.thisdict["state"] != "PRINTING"  and int(t_read) > 0  and int(d_read.split("/")[2]) == 0 :
                self.thisdict["state"] = "PRINTING"
                self._isPrinting = True
                self._isPause = False
                # self.PrintstateChanged.emit()
            elif  self.thisdict["state"] != "PAUSE" and int(t_read) > 0  and int(d_read.split("/")[2]) == 1:
                self.thisdict["state"] = "PAUSE"
                self._isPrinting = False
                self._isPause = True
                # self.PrintstateChanged.emit()
            elif self.thisdict["state"] != "IDLE" and int(t_read) == 0 :
                self.thisdict["state"] = "IDLE"
                self._isPrinting = False
                self._isPause = False

        except:
            Logger.log("e","change t_read type error")
        if t0_temp:
            self.setStateConnected.emit()

        if self._isPrinting:
            self._ischanging = False
        self.updateRequested.emit()
        
    def ip_info_update(self, info):
        printername = info[info.find("NAME:") + len("NAME:"):len(info)]
        macaddress = info[info.find("MAC:") + len("MAC:"):info.find("IP:")]
        ipaddress = info[info.find("IP:") + len("IP:"):info.find("VER:")]
        wifiwareversion = info[info.find("VER:") + len("VER:"):info.find("ID:")]
        self.thisdict["printer_name"] = printername
        self.thisdict["printer_type"] = "None" if printername.find("@") ==-1 else printername[printername.find("@") + 1:len(printername)]
        self.thisdict["mac_address"] = macaddress
        self.thisdict["ip_address"] = ipaddress  
        self.thisdict["wifi_version"] = wifiwareversion
        if printername.find("@") !=-1 :
            definitions = self._container_registry.findDefinitionContainers(id=printername[printername.find("@") + 1:].replace(" ","_"))
            if len(definitions) != 0:
                container_stack = definitions[0]
                parsed = json.loads(container_stack.serialize(), object_pairs_hook = collections.OrderedDict)
                machine_width = machine_depth = machine_height = 0
                # Logger.log("e",parsed["settings"]["cooling"]["children"].get("chamber_cooling_fan_speed")["enabled"])
                close_machine_enabled = chamber_cooling_enabled = rapid_cooling_enabled = volume_enabled = "False"

                try:
                    machine_width = parsed["settings"]["machine_settings"]["children"].get("machine_width")["default_value"] 
                    machine_depth = parsed["settings"]["machine_settings"]["children"].get("machine_depth")["default_value"]
                    machine_height = parsed["settings"]["machine_settings"]["children"].get("machine_height")["default_value"]
                    chamber_cooling_enabled = ''.join(parsed["settings"]["cooling"]["children"].get("chamber_cooling_fan_speed")["enabled"].split('='))
                    rapid_cooling_enabled =''.join( parsed["settings"]["cooling"]["children"].get("rapid_cooling_fan_speed")["enabled"].split('='))
                    volume_enabled = ''.join(parsed["settings"]["machine_settings"]["children"].get("machine_heated_build_volume")["default_value"].split('='))
                    close_machine_enabled = ''.join(parsed["settings"]["advanced"]["children"].get("shutdown_after_printing")["enabled"].split('='))

                except:
                    Logger.log("e","Get definition failure")
                self.thisdict["chamber_cooling_enabled"] = chamber_cooling_enabled
                self.thisdict["rapid_cooling_enabled"] = rapid_cooling_enabled
                self.thisdict["volume_enabled"] = volume_enabled
                self.thisdict["close_machine_enabled"] = close_machine_enabled
                # for key, value in parsed["settings"]["machine_settings"]["children"].items():
                #     if "machine_width" in key:
                #         machine_width = value["default_value"]
                #     if "machine_depth" in key:
                #         machine_depth = value["default_value"]
                #     if "machine_height" in key:
                #         machine_height = value["default_value"]
                self.thisdict["printsize_string"] = str(machine_width) +'/' + str(machine_depth) + '/' + str(machine_height)
            else:
                self.thisdict["printsize_string"] = "0/0/0"
        else:
            self.thisdict["printsize_string"] = "0/0/0"
        self.updateInfoRequested.emit()

    def printer_file_list_parse(self, info):
    
        if 'Begin file list' in info:
            self._sdFileList = True
            self.sdFiles = []
            self.last_update_time = time.time()
            return True
        if 'End file list' in info:
            self._sdFileList = False
            self.updateFileList.emit()
            self.first_connect = 1
            return True
        if self._sdFileList:
            filename = info.replace("\n", "").replace("\r", "")
            if filename.find(".") != -1 and filename.find(".") != 0:
                name = filename[:filename.rfind(".")]

                type = filename[filename.rfind(".") + 1: filename.rfind(" ")]
                size = filename[filename.rfind(" ") + 1:]

            else:
                name = filename[:filename.rfind(" ")]
                type = "File"
                size = filename[filename.rfind(" ") + 1:]
            self.sdFiles.append('/'.join([name, '+'.join([type, size.replace(" ", "")])]))
            return True
        return False
        
    def startSendingThread(self):
        
        self._abort = False
        Application.getInstance().getOutputDeviceManager().writeStarted.emit(None)
        self._genTempGcodeFile()
        if  Application.getInstance().getPreferences().getValue("view/send_with_compress") :
            self.dataCompressThread()
            self._file_path = Resources.getStoragePath(Resources.Resources, "data.gcode.tz")
            self.show_progress_message()
            self.sendDatThread()
        else :
            self._file_path = Resources.getStoragePath(Resources.Resources, "data.gcode")
            self.show_progress_message()
            self.sendDatThread()
        os.remove(self._file_path)
        self._file_path = None
        self.sending_file_state = CBDConnect.SEND_DONE
        self.updateRequested.emit()

        if self._socket is not None:
            self._sendCommand("M4001\r\nM20")
        Logger.log("i", "=============send success============")
        self.sendMax = 0  # 标识发送结束
        Logger.log("i", "send done.....")

    @pyqtSlot(str,str)  # 输入参数为str类型
    def startSending(self, fileName,strIP):
        ss = strIP.split('/')
        if(len(ss) >= 2):
            strIP = ss[-1].split("%")[0]
        else:
            return
        self._genTempGcodeFile()
        self.select_ip = strIP
        if  Application.getInstance().getPreferences().getValue("view/send_with_compress") :
            self.targetSendFileName = fileName + ".gcode.tz"
        else:
            self.targetSendFileName = fileName + ".gcode"
        self.sending_file_state = CBDConnect.CONNECTING
        self.updateRequested.emit()

        self._abort = False
        # Logger.log("e",Application.getInstance().getPreferences().getValue("view/send_with_compress"))
        if  Application.getInstance().getPreferences().getValue("view/send_with_compress") :
            self.dataCompressThread()
            self._file_path = Resources.getStoragePath(Resources.Resources, "data.gcode.tz")
            self.show_progress_message()
            self._send_thread = threading.Thread(target=self.sendDatThread)
            self._send_thread.daemon = True
            self._send_thread.start()
        else :
            self._file_path = Resources.getStoragePath(Resources.Resources, "data.gcode")
            self.show_progress_message()
            self._send_thread = threading.Thread(target=self.sendDatThread)
            self._send_thread.daemon = True
            self._send_thread.start()
        # os.remove(self._file_path)
    
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
                Logger.log("i", self.select_ip)
                self.sock.sendto(b"M4001", (self.select_ip, self.PORT))
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
                    exePath = "./VC_compress_gcode_linux.linux"
                    for pathdir in cast(str, os.getenv("PATH")).split(os.pathsep):
                        exePath = os.path.join(pathdir, "VC_compress_gcode_linux.linux")
                        if os.path.exists(exePath):
                            exePath = exePath
                            break
                    exePath = os.path.abspath(exePath)
                    cmd = "chmod 777 " + "\"" + exePath + "\""
                    Logger.log("i", cmd)
                    ret = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE,shell = True)
                    Logger.log("i", ret.stdout.read().decode("utf-8", 'ignore'))
                cmd = "\"" + exePath + "\"" + " \"" + self._localTempGcode + "\" " + x_mm_per_step + " " + y_mm_per_step + " " + z_mm_per_step + " " + e_mm_per_step\
                         + ' \"' + path.dirname(self._localTempGcode) + '\" ' + s_x_max + " " + s_y_max + " " + s_z_max + " " + s_machine_type
                Logger.log("i", cmd)
                ret = subprocess.Popen(cmd,stdout=subprocess.PIPE,shell=True)
                Logger.log("i", ret.stdout.read().decode("utf-8", 'ignore'))
                break
            except timeout:
                tryCnt += 1
                if(tryCnt > 2):
                    # self._result = WifiSend.CONNECT_TIMEOUT
                    break
            except:
                traceback.print_exc()
                break

    def _getResponse(self):
        if self.sending_file_state == CBDConnect.CONNECTING:
            try:
                message, address = self.sock.recvfrom(self.RECVBUF)
                message = message.decode('utf-8','replace')
                Logger.log("i", 'M4001 rcv:' + message)
            except:
                traceback.print_exc()
                self.tryCnt += 1
                if self.tryCnt > 3:
                    self._abort = True
                    self.send_state_change(CBDConnect.CONNECT_TIMEOUT)
                    # self.sending_file_state = CBDConnect.CONNECT_TIMEOUT
                    Logger.log("w","Socket M4001 timeout")
                return False
        elif self.sending_file_state == CBDConnect.CREATE_FILE:
            try:
                message, address = self.sock.recvfrom(self.RECVBUF)
                message = message.decode('utf-8','replace')
                Logger.log("i", 'M28 rcv:' + message)
                if ('Error' in message):
                    self.send_state_change(CBDConnect.WRITE_ERROR)
                    self._abort=True
            except:
                traceback.print_exc()
                self.tryCnt += 1
                if self.tryCnt > 3:
                    self._abort = True
                    self.send_state_change(CBDConnect.CONNECT_TIMEOUT)
                    Logger.log("w","Socket M28 timeout")
                return False
        elif self.sending_file_state == CBDConnect.FINISH_WRITING:
            try:
                message, address = self.sock.recvfrom(self.RECVBUF)
                message = message.decode('utf-8','replace')
                Logger.log("i", 'M29 rcv:' + message)
                if 'Error' in message:
                    self.send_state_change(CBDConnect.WRITE_ERROR)
                    self._abort = True
                else:
                    self.show_print_message()
                    self._file_path = None
                    self.sending_file_state = CBDConnect.SEND_DONE                    
                    self._abort = True
            except:
                traceback.print_exc()
                self.tryCnt += 1
                if self.tryCnt > 3:
                    self._abort = True
                    self.send_state_change(CBDConnect.CONNECT_TIMEOUT)
                    Logger.log("w","Socket M29 timeout")
                return False

        return message

    def send_state_change(self,state):
        # self.sending_file_state = state
        m = Message(self.Error_dict.get(state), lifetime=0)
        m.show()

    def sendDatThread(self):
        Logger.log("i", "==========start send file============")
        FilePath = self._file_path
        if self._progress_message is not None:
            self._progress_message.setProgress(0)
        try:
            while True:
                oldseek = 0
                self.sock.settimeout(2)
                self.tryCnt = 0
                while True:
                    if self._abort:
                        break  
                    self.sock.sendto(b"M4001\r\n", (self.select_ip, self.PORT))
                    if self._getResponse():
                        break
                self.sending_file_state = CBDConnect.OPEN_FILE
                self.updateRequested.emit()
                Logger.log("i", "compress file path:" + FilePath)
                if self._abort:
                    break
                try:
                    self.sendMax = os.path.getsize(FilePath)
                    Logger.log("i", "compress file size:" + str(self.sendMax))
                    if(self.sendMax == 0):
                        self.send_state_change(CBDConnect.FILE_EMPTY)
                        break
                    fp = open(FilePath, 'rb', buffering=1)
                    if not fp:
                        self.send_state_change(CBDConnect.FILE_NOT_OPEN)
                        Logger.log("w", "==error open file %s",FilePath)
                        break
                except Exception as e:
                    Logger.log("w", str(e))
                    self.send_state_change(CBDConnect.FILE_EMPTY)
                    break
                fp.seek(0, 0)
                self.sending_file_state = CBDConnect.CREATE_FILE
                self.updateRequested.emit()

                cmd = "M28 " + self.targetSendFileName
                Logger.log("d", "cmd:" + cmd)
                self.tryCnt = 0
                while True:
                    if self._abort:
                        break  
                    self.sock.sendto(self.encodeCmd(cmd), (self.select_ip, self.PORT))
                    if self._getResponse():
                        break
                self.sock.settimeout(0.1)
                lastProgress = 0
                lastDataArray = None
                finishedCnt = 0
                timeoutCnt = 0
                finishedRcvOkCnt = 0
                self.sending_file_state = CBDConnect.WRITING
                self.updateRequested.emit()

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
                            oldseek = seek
                            self.sendNow = seek

                            if(int(100*self.sendNow/self.sendMax) > int(100*lastProgress)):
                                lastProgress = self.sendNow/self.sendMax
                                if self._progress_message is not None:
                                    self._progress_message.setProgress(lastProgress*100)
                            datSize = len(dataArray) - 6
                            if datSize <= 0:
                                break
                            dataArray[datSize] = seekArray[3]
                            dataArray[datSize+1] = seekArray[2]
                            dataArray[datSize+2] = seekArray[1]
                            dataArray[datSize+3] = seekArray[0]

                            for i in range(0, datSize+4, 1):
                                check_sum ^= dataArray[i]
                            dataArray[datSize+4] = check_sum
                            dataArray[datSize + 5] = 0x83
                            lastDataArray = dataArray
                        self.sock.sendto(dataArray, (self.select_ip, self.PORT))
                        message, address = self.sock.recvfrom(self.RECVBUF)
                        timeoutCnt = 0
                        message = message.decode('utf-8','replace')
                        if('ok' in message):
                            if(finishedRcvOkCnt > 3):      #确保数据发送完整了
                                break
                            else:
                                if(finishedCnt):
                                    finishedRcvOkCnt += 1
                                continue
                        elif ('Error') in message:
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
                            break
                        print("timeout:",timeoutCnt)
                        timeoutCnt += 1
                    except:
                        traceback.print_exc()
                fp.close()
                if self._progress_message is not None:
                    self._progress_message.setProgress(0)
                break
            self.sending_file_state = CBDConnect.FINISH_WRITING
            self.updateRequested.emit()

            if not self._abort:
                self.sock.settimeout(2)
                self.tryCnt = 0
                while True:
                    if self._abort:
                        break  
                    self.sock.sendto(b"M29", (self.select_ip, self.PORT))
                    if self._getResponse():
                        break

            self.sending_file_state = CBDConnect.SEND_DONE
            self.updateRequested.emit()

            if self._progress_message is not None:
                self._progress_message.setProgress(0)
                self._progress_message.hide()
                self._progress_message = None
        except:
            self.sending_file_state = CBDConnect.SEND_DONE
            self.updateRequested.emit()

            self.send_state_change(CBDConnect.WRITE_ERROR)
            Logger.log("e","WRITE_ERROR")
            traceback.print_exc()

    def download_file(self):
        self.sock.settimeout(2)
        Logger.log("i", "targetIP:" + self.select_ip)
        tryCnt = 0
        while True:
            if self.getFilePath!="":
                break
            Logger.log("e","self.getFilePath = None")
            time.sleep(1)
        while True:
            try:
                if self._abort:
                    break
                if tryCnt > 3:
                    # WifiSend.getInstance()._result = WifiSend.CONNECT_TIMEOUT
                    break
                self.sock.sendto(b"M4001\r\n", (self.select_ip, self.PORT))
                message, address = self.sock.recvfrom(self.RECVBUF)
                Logger.log("i", message)
                break
            except timeout:
                Logger.log("w", "Socket M4001 timeout ")
            except:
                tryCnt += 1
                traceback.print_exc()
        file_size = 0
        try:
            self.sock.sendto(self.download_command.encode('UTF-8'), (self.select_ip, self.PORT))
            self.sock.sendto(b"M3000\r\n", (self.select_ip, self.PORT))
            message, address = self.sock.recvfrom(self.RECVBUF)
            message = message.decode('UTF-8')

            if message.find("ok L:") != -1:
                file_size = int(message[message.find("ok L:") + 5:])
            else:
                # 关闭SD卡
                #self.sendCmd("M22")
                self.sock.sendto(b"M22\r\n", (self.select_ip, self.PORT))
                message, address = self.sock.recvfrom(self.RECVBUF)

                # self.sendResult()
            # message[: -6]是因为取出来的字节串最后都是以 \r\r\n 结尾的，这些转换成字符串的时候是需要的，否则就是一些乱码
            # 但是如果直接写入 message 的话，就不会包含 \r\r\n ，所以，进一步处理文件需要定位到 -6
            Logger.log("i", "download size: " + str(file_size))
            self.sock.settimeout(0.1)
            file_object = open(self.getFilePath, "wb")

            if file_size < 1286:
                # self.sendCmd("M3001 I0")
                # message, address = self.s.recvfrom(2048)
                self.sock.sendto(b"M3001 I0\r\n", (self.select_ip, self.PORT))
                message, address = self.sock.recvfrom(self.RECVBUF)
                # 文件实体
                file_object.write(message[: -6])
                file_object.close()
                    # 关闭SD卡
                # self.sendCmd("M22")
                self.sock.sendto(b"M22\r\n", (self.select_ip, self.PORT))
                message, address = self.sock.recvfrom(self.RECVBUF)
                message = message.decode('UTF-8')

                findcount = 0
                while message.find("ok") == -1 and findcount <10 :
                #self.sendResult()
                #self.sendResult()
                    message, address = self.sock.recvfrom(self.RECVBUF)
                    message = message.decode('UTF-8')

                    findcount+=1
                    time.sleep(1)
                # self.show_text += " <- " + 'download successfully' + "\n"
                # self.allResultdataChanged.emit()
            else:
                # 文件实体
                # self.sendCmd("M3001 I0")
                # message, address = self.s.recvfrom(2048)
                self.sock.sendto(b"M3001 I0\r\n", (self.select_ip, self.PORT))
                message, address = self.sock.recvfrom(2048)
                # Logger.log("i",message)
                # self.sendCmd("M3000")
                self.sock.sendto(b"M3000\r\n", (self.select_ip, self.PORT))
                # self.sendCmd("M3001 I1280")
                # message, address = self.s.recvfrom(2048)
                self.sock.sendto(b"M3001 I1280\r\n", (self.select_ip, self.PORT))
                message, address = self.sock.recvfrom(2048)
                # Logger.log("i",message)

                file_object.write(message[: -6])
                # bytes("23333", encoding='UTF-8') 字符串转字节
                if file_size > 1280:
                    file_size = file_size - 1280
                else:
                    file_size = 0

                while file_size != 0:
                    # self.sendCmd("M3000")
                    # message, address = self.s.recvfrom(2048)
                    while True:
                        try:
                            self.sock.sendto(b"M3000\r\n", (self.select_ip, self.PORT))
                            message, address = self.sock.recvfrom(2048)
                            break
                        except timeout:
                            Logger.log("w", "Socket M3000 timeout ")
                            self.sending_file_state != CBDConnect.SEND_DONE
                    # 文件实体
                    file_object.write(message[: -6])
                    if file_size > 1280:
                        file_size = file_size - 1280
                    else:
                        file_size = 0
                else:
                    pass
                file_object.close()
                self.sock.sendto(b"M22\r\n", (self.select_ip, self.PORT))
                message, address = self.sock.recvfrom(self.RECVBUF)
                self.sock.sendto(b"M22\r\n", (self.select_ip, self.PORT))
                message, address = self.sock.recvfrom(self.RECVBUF)
                self.sending_file_state = CBDConnect.SEND_DONE
                self.updateRequested.emit()

                self.getFilePath =""
        except Exception:
            file_object.close()
            self.sending_file_state = CBDConnect.SEND_DONE
            self.updateRequested.emit()
            self.sock.sendto(b"M22\r\n", (self.select_ip, self.PORT))
            message, address = self.sock.recvfrom(self.RECVBUF)
            Logger.log("e","DOWNLOAD_ERROR")
            os.remove(self.getFilePath)
            self.getFilePath =""
            traceback.print_exc()

    def _genTempGcodeFile(self):
        self._localTempGcode = Resources.getStoragePath(Resources.Resources, "data.gcode")
        # fp = open(self._localTempGcode, 'w+', buffering=1)
        # if not fp:
        #     # self._result = WifiSend.FILE_NOT_SAVE
        #     Logger.log("e","FILE_NOT_SAVE")
        # else:
        #     # writer = cast(MeshWriter, PluginRegistry.getInstance().getPluginObject("GCodeWriter"))#GCodeWriter ()
        #     # writer.write( fp, Application.getInstance().getController().getScene().getRoot(), MeshWriter.OutputMode.TextMode)
        #     fp.close()

    def show_progress_message(self):

        status = catalog.i18nc("@info:status", "Uploading print job to printer")
        title = catalog.i18nc("@info:title", "Sending Print Job")
        self._progress_message = Message(
            status,
            0,
            False,
            -1,
            title)
        self._progress_message.addAction(
            "Cancel",  "Cancel", None, "")
        self._progress_message.actionTriggered.connect(
            self._cancelSendGcode)
        self._progress_message.show()

    def show_print_message(self):

        m = Message(catalog.i18nc("@info:status", "Send file {0} successfully, Do you want to print the file now?", self.decodeCmd(self.encodeCmd(self.targetSendFileName))),
                    lifetime=0)

        m.addAction(
            "Print_immediately",
            catalog.i18nc("@action:button", "Yes"),
            "",""
        )
        
        m.addAction(
            "No",
            catalog.i18nc("@action:button", "No"),
            "",""
        )
        m.actionTriggered.connect(self.startPrintForButton)
        m.show()

    def _cancelSendGcode(self, message_id, action_id):
        self._abort = True
        self.sending_file_state = CBDConnect.SEND_DONE
        self.updateRequested.emit()
        self._sendCommand("M4001")
        if self._progress_message is not None:
            self._progress_message.hide()
            self._progress_message = None

    def startPrintForButton(self, m, action):
        m.hide()
        if action == "No":
            return
        cmd = 'M6030 ":' + self.targetSendFileName + '" I1'
        self._sendCommand("M4001\r\n"+cmd)

    def isBusy(self):
        return self._isPrinting or self._isPause or self.sending_file_state != CBDConnect.SEND_DONE

    def isPrinting(self): 
        return self._isPrinting or self._ischanging

    def isPause(self): 
        return self._isPause
    
    def encodeCmd(self,cmd):
        return cmd.encode(self._file_encode, 'ignore')
        
    def decodeCmd(self,cmd):
        return cmd.decode(self._file_encode,'ignore')

    _instance = None
    @classmethod
    def getInstance(cls, *args, **kwargs) -> "CBDConnect":
        if not CBDConnect._instance:
            CBDConnect._instance = cls()
        return CBDConnect._instance