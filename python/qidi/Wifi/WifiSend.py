# -*- coding: utf-8 -*-

import subprocess
import re
import threading
from socket import *
import traceback
import time

from PyQt5.QtNetwork import QUdpSocket, QHostAddress
from PyQt5.QtCore import pyqtSignal, pyqtProperty
from PyQt5.QtCore import pyqtProperty, pyqtSignal, QObject

from timeit import default_timer as Timer

from QD.FlameProfiler import pyqtSlot
from QD.Application import Application
from QD.Message import Message
from QD.i18n import i18nCatalog
from QD.Logger import Logger
from QD.Platform import Platform
from QD.TaskManagement.HttpRequestManager import HttpRequestManager

from PyQt5.QtCore import pyqtSignal, pyqtProperty, pyqtSlot, QObject


i18n_catalog = i18nCatalog("qidi")


class NetDevice():

    def __init__(self):
        self.ipaddr = ''
        self.name = 'undefined'

    def __str__(self):
        s = ('Device addr:' + self.ipaddr + '==' + self.name)
        return s


class WifiSend(QObject):

    def __init__(self):
        super(WifiSend, self).__init__()  #不运行父类初始化，
        self.devices = []  #NetDevice
        self.devices_same_machine = []  #NetDevice
        self.devices_notsame_machine = []  #NetDevice
        self.PORT = 3000
        self.PORT_qidi = 8989
        self.BUFSIZE = 256 * 5
        self.RECVBUF = 256 * 5
        self.sendNow = 0
        self.sendMax = 0
        self.sock = socket(AF_INET, SOCK_DGRAM)
        self.sock.setsockopt(SOL_SOCKET, SO_BROADCAST, 1)
        self.sock.settimeout(3)
        self._nameable = "false"
        self._socket = QUdpSocket(self)
        self.ip_list = []
        self.fullname_ip_list = []
        self._scan_in_progress = False
        self.scanDeviceThread()
        self._file_encode = 'utf-8'
        self.currentDeviceIP = ''
        self.nowifi = 0
        self.strIP = ""
        self.alliplist = ""
        self._input_ip = ""
        self._input_sm = ""
        Application.getInstance().getPreferences().addPreference(
            "qidiwifi/broad_addr", "")
        Application.getInstance().getPreferences().addPreference(
            "view/show_ip_warning", True)

    def _generate_broad_addr(self, targetIP, maskstr):

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
        ipconfig_process = subprocess.Popen(
            "ifconfig" if
            (Platform.isLinux() or Platform.isOSX()) else "ipconfig",
            stdout=subprocess.PIPE,
            shell=True)
        output = ipconfig_process.stdout.read().decode("utf-8", 'ignore')
        allIPlist = re.findall(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', output)
        Logger.log("i", "allIPlist = %s", allIPlist)
        allIP = ""
        for j in allIPlist:
            if j.count("255.255") < 1:
                allIP += j + "   "
        Logger.log("i", "allIP = %s", allIP)
        self.alliplist = allIP
        inputIP = "Please input host IP."
        ipList = []
        if self._input_ip == "":
            try:
                from netifaces import interfaces, ifaddresses, AF_INET
                for name in interfaces():
                    addresses = [
                        i['addr'] for i in ifaddresses(name).setdefault(
                            AF_INET, [{
                                'addr': 'No IP '
                            }])
                    ]
                    if ' '.join(addresses) != 'No IP ':
                        ipList.append(' '.join(addresses))
                Logger.log("d", ipList)
            except:
                Logger.log("e", "get addresses Error")
        else:
            ipList = [self._input_ip]
            Logger.log("i", "ipList = %s", ipList)
        broadcast = []
        if len(ipList) == 0:
            ipList = ["192.168.0.1"]
        for i in range(len(allIPlist)):
            ipaddr = allIPlist[i]
            if (ipaddr in ipList
                    and ipaddr != '127.0.0.1') and (i + 1) < len(allIPlist):
                if Platform.isOSX():
                    broadcast.append(allIPlist[i + 1])
                else:
                    broadcast.append(
                        self._generate_broad_addr(ipaddr, allIPlist[i + 1]))
        rembroadcastip = Application.getInstance().getPreferences().getValue(
            "qidiwifi/broad_addr")
        Logger.log("d", "remember broadcast IP:" + rembroadcastip)
        if rembroadcastip != "":
            broadcast.append(rembroadcastip)
        if self._input_ip != "":
            if self._input_sm.find("255.") != -1:
                Application.getInstance().getPreferences().setValue(
                    "qidiwifi/broad_addr",
                    self._generate_broad_addr(self._input_ip, self._input_sm))
                broadcast.append(
                    self._generate_broad_addr(self._input_ip, self._input_sm))
            else:
                Application.getInstance().getPreferences().setValue(
                    "qidiwifi/broad_addr",
                    self._generate_broad_addr(self._input_ip, "255.255.255.0"))
                broadcast.append(
                    self._generate_broad_addr(self._input_ip, "255.255.255.0"))

            self._input_ip = ""
            self._input_sm = ""
        if not broadcast:
            Logger.log("i", "Cann't fine valid boradcast,use all IP")
            if (Platform.isLinux() or Platform.isOSX()):
                broadcast.append(ipList[0])
            else:
                broadcast.append(
                    self._generate_broad_addr(ipList[0], '255.255.255.0'))
        # broadcast = ["255.255.255.255"]
        Logger.log("i", broadcast)
        return broadcast

    @pyqtSlot()
    def scanDeviceThread(self):
        Logger.log("i", "..........scan device")

        if self._scan_in_progress:
            return
        threading.Thread(target=self.scanDevice).start()

    @pyqtSlot()
    def ip_sort(self):
        while (1):
            try:
                machine_lname = Application.getInstance(
                ).getGlobalContainerStack().getProperty(
                    "machine_name", "value").lower().replace(" ", "_")
                break

            except:
                self.sock.settimeout(1)
                pass
        self.devices_same_machine = []  #NetDevice
        self.devices_notsame_machine = []  #NetDevice
        if len(self.devices) != 0:
            self.devices_same_machine = [
                n for n in self.devices if self.is_same(n, machine_lname)
            ]
            self.devices_notsame_machine = [
                n for n in self.devices if n not in self.devices_same_machine
            ]
            self.devices = []
            self.devices = self.devices_same_machine + self.devices_notsame_machine

    def is_same(self, val, name):
        if val.name.find("@") == -1:
            return True
        elif val.name.split("@")[1].split("/")[0] == name:
            return True
        else:
            return False

    def _isDuplicateIP(self, ip):
        for device in self.devices:
            if ip == device.ipaddr:
                return True
        return False

    def _readPendingDatagrams(self):
        while self._socket.hasPendingDatagrams():
            datagram, host, port = self._socket.readDatagram(
                self._socket.pendingDatagramSize())
            message = datagram.decode('utf-8', 'ignore')
            message = message.rstrip()
            QHostAddress(host.toIPv4Address()).toString()
            if message.find('ok MAC:') != -1:
                device = NetDevice()
                device.ipaddr = QHostAddress(
                    host.toIPv4Address()).toString() + "%CBD"
                if not self._isDuplicateIP(device.ipaddr):
                    if 'NAME:' in message:
                        device.name = message[message.find('NAME:') +
                                              len('NAME:'):]
                    Logger.log("d", 'Got reply from: {}', device)
                    self.devices.append(device)

                else:
                    Logger.log("d", 'Got reply from known device')
            elif message.find('mkswifi:') != -1:
                device = NetDevice()
                device.ipaddr = QHostAddress(
                    host.toIPv4Address()).toString() + "%QIDI"
                if not self._isDuplicateIP(device.ipaddr):
                    device.name = message[message.find('mkswifi:') +
                                              len('mkswifi:'):message.find(',')]
                    Logger.log("d", 'Got reply from: {}', device)
                    self.devices.append(device)

                else:
                    Logger.log("d", 'Got reply from known device')

    def scanDevice(self):
        self.nowifi = 0
        if self.devices == []:
            self.nowifi = 1
        self.devices = []

        self.ip_list = []
        self.fullname_ip_list = []
        #先清空
        broadcasts = self._getAllBroadcast()
        self.sock.settimeout(2)
        end_time = Timer() + 3
        counttime = 3
        while counttime > 0:
            Logger.log("d", 'Broadcasting discovery packet')
            for broadcast in broadcasts:
                self._socket.writeDatagram('mkswifi\r\n'.encode('utf-8'),
                                           QHostAddress(broadcast), 8989)
                self._socket.writeDatagram('M99999'.encode('utf-8'),
                                           QHostAddress(broadcast), 3000)
            time.sleep(1)
            self._readPendingDatagrams()
            counttime = counttime - 1
        self.ip_sort()
        for device in self.devices:
            devicename = device.name
            self.fullname_ip_list.append('/'.join([devicename, device.ipaddr]))

            try:
                _ = devicename.split("@")
                devicename = _[0]
            except:
                traceback.print_exc()
            self.ip_list.append('/'.join(
                [devicename, device.ipaddr.split("/")[0].split("%")[0]]))
        if not self.ip_list:
            self.ip_list.append('')
            self.fullname_ip_list.append('')

        self.IPListChanged.emit()
        self.FullNameIPListChanged.emit()

        self.setCurrentDeviceIP(self.FullNameIPList[0])

        Logger.log("i", "device scan done")

        if self.devices == [] and self.nowifi == 1:
            self.nowifi = 2
        self._scan_in_progress = False

    @pyqtSlot(str, str)
    def renameDevice(self, newName, strIP):
        strIP = self.currentDeviceIP
        ss = strIP.split('/')
        if(len(ss) >= 2):
            ipstr = ss[-1].split("%")[0]
        else:
            return
        if ss[-1] =="CBD":
            newName = newName.replace('&', '%')  #为了避免和校验和的冲突
            newName = newName.replace('@', '#')
            try:
                newName += '@' + Application.getInstance().getGlobalContainerStack(
                ).getProperty("machine_name", "value").lower().replace(" ", "_")
            except:
                pass
            Logger.log(
                "d", "newName : %s",
                Application.getInstance().getGlobalContainerStack().getProperty(
                    "machine_name", "value").lower())
            str_cmd = "U100 " + "'" + newName + "'"
            b_cmd = str_cmd.encode('utf-8')
            checkSum = 0
            for i in b_cmd:
                checkSum ^= i
            b_cmd = b_cmd + b"&" + str(checkSum).encode('utf-8') + b"&"
            Logger.log("i", b_cmd)
            try:
                self.sock.sendto(b_cmd, (strIP, self.PORT))
                self.sock.settimeout(0.2)
                message, address = self.sock.recvfrom(self.BUFSIZE)
            except timeout:
                pass
            except:
                traceback.print_exc()
        else:
            # url = "http://"+strIP+":8990/printer/dev_name?name=" + newName
            newName += '@' + Application.getInstance().getGlobalContainerStack(
                ).getProperty("machine_name", "value").lower().replace(" ", "_")
            url = "http://"+ipstr+":10088/machine/system_info?dev_name="+ newName
            headers = {'User-Agent': 'Cura Plugin Moonraker', 'Accept': 'application/json, text/plain', 'Connection': 'keep-alive'}
            HttpRequestManager.getInstance().get(
                        url,
                        headers
                    )
        self.scanDeviceThread()

    @pyqtSlot(str)
    def setCurrentDeviceIP(self, deviceIP=""):
        self.currentDeviceIP = deviceIP
        Logger.log("i", "currentDeviceIP : %s", self.currentDeviceIP)
        self.setNameable()
        if self._nameable == "false" and (
                self.currentDeviceIP != "") and Application.getInstance(
                ).getPreferences().getValue("view/show_ip_warning") == True:
            m = Message(i18n_catalog.i18nc(
                "@info:plugin",
                "The printer corresponding to the IP address you selected does not match the printer you currently selected."
            ),
                        lifetime=5)
            m.addAction("Print_immediately",
                        i18n_catalog.i18nc("@action:button", "No prompt"), "",
                        "")

            m.addAction("No", i18n_catalog.i18nc("@action:button", "Close"),
                        "", "")

            m.show()
            m.actionTriggered.connect(self.ipWarningForButton)

    @pyqtSlot(str)
    def setInputIp(self, inputIP=""):
        self._input_ip = inputIP
        Logger.log("i", "self._input_ip : %s", inputIP)

    @pyqtSlot(str)
    def setInputSM(self, inputSM=""):
        self._input_sm = inputSM
        Logger.log("i", "self._input_sm : %s", inputSM)

    IPListChanged = pyqtSignal()

    @pyqtProperty("QVariantList", notify=IPListChanged)
    def IPList(self):
        return self.ip_list

    nameableChanged = pyqtSignal()

    @pyqtProperty(str, notify=nameableChanged)
    def nameable(self) -> str:
        return self._nameable

    @pyqtSlot()
    def setNameable(self):
        if self.currentDeviceIP.find("@") != -1:
            machinename = self.currentDeviceIP.split("@")[1].split("/")[0]
            if machinename == Application.getInstance(
            ).getGlobalContainerStack().getProperty("machine_name",
                                                    "value").lower().replace(
                                                        " ", "_"):
                self._nameable = "true"
            else:
                self._nameable = "false"
        elif (self.currentDeviceIP != ""):
            self._nameable = "true"
        Logger.log("i", "nameable : %s", self._nameable)
        self.nameableChanged.emit()

    FullNameIPListChanged = pyqtSignal()

    @pyqtProperty("QVariantList", notify=FullNameIPListChanged)
    def FullNameIPList(self):
        return self.fullname_ip_list

    @pyqtSlot()
    def ipWarningForButton(self, m, action):
        self.sock.settimeout(2)
        tryCnt = 0
        m.hide()
        if action == "No":
            return
        Application.getInstance().getPreferences().setValue(
            "view/show_ip_warning", False)

    _instance = None

    @classmethod
    def getInstance(cls, *args, **kwargs) -> "WifiSend":
        if not WifiSend._instance:
            WifiSend._instance = cls()
        return WifiSend._instance
