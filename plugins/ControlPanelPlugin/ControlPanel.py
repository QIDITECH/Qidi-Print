import os
import os.path
import time
from socket import *
from PyQt5.QtWidgets import QFileDialog
from PyQt5.QtCore import QDir, pyqtProperty, pyqtSignal, QObject ,pyqtSlot
from QD.Extension import Extension
from QD.i18n import i18nCatalog
from QD.Logger import Logger
from QD.Application import Application
from QD.Platform import Platform
# from PyQt5.QtQuick import QQuickView
# from PyQt5 import  QtGui, QtWidgets, QtCore ,QtWebEngine
# from PyQt5.QtCore import *
# from PyQt5.QtGui import *
# from PyQt5.QtWidgets import *
# from PyQt5 import QtQml,QtQuick
# from PyQt5.QtWebEngine  import *
from qidi.PrinterOutputDevice import  ConnectionState
# from typing import cast
from enum import IntEnum



try:
    from . import qrc
except:
    pass

from qidi.Wifi.WifiSend import WifiSend
from qidi.Wifi.CBDConnect import CBDConnect
from qidi.Wifi.MKSConnect import MKSConnect


catalog = i18nCatalog("qidi")
#message处有调用

class UnifiedConnectionState(IntEnum):
    try:
        Closed = ConnectionState.Closed
        Connecting = ConnectionState.Connecting
        Connected = ConnectionState.Connected
        Busy = ConnectionState.Busy
        Error = ConnectionState.Error
        Printing = ConnectionState.Printing
        Pause = ConnectionState.Pause
        
    except AttributeError:
        Closed = ConnectionState.closed          # type: ignore
        Connecting = ConnectionState.connecting  # type: ignore
        Connected = ConnectionState.connected    # type: ignore
        Busy = ConnectionState.busy              # type: ignore
        Error = ConnectionState.error            # type: ignore

class ControlPanel(Extension, QObject):
    
    def __init__(self, parent = None):
        Extension.__init__(self)
        QObject.__init__(self, parent)
        
        self._controlpanel_window = None
        self.setMenuName(catalog.i18nc("@item:inmenu", "Control Panel"))
        self.addMenuItem(catalog.i18nc("@item:inmenu", "Control Panel"), self.showControlPanel)
        self._connection_state = ConnectionState.Closed
        self.sdFiles = []
        self._uploadpath = ''
        self.select_ip = ""
        self.show_text = ""
        self.firmware_manufacturers=""
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
        self.file_list = []
        self.filecmd_result = ""
        self.select_file = ""
        self.getFilePath = ""
        self.cbdConnect = CBDConnect.getInstance()
        self.mksConnect = MKSConnect.getInstance()
        self.cbdConnect.updateRequested.connect(self._onUpdateRequested)
        self.cbdConnect.updateInfoRequested.connect(self._onUpdateInfoRequested)
        self.cbdConnect.setStateConnected.connect(self._onSetStateConnected)
        self.cbdConnect.setStateClosed.connect(self._onSetStateClosed)
        self.cbdConnect.updateFileList.connect(self._onUpdateFileList)
        self.cbdConnect.updateShowText.connect(self._onUpdateShowText)
        self.mksConnect.updateRequested.connect(self._onUpdateRequested)
        self.mksConnect.setStateConnected.connect(self._onSetStateConnected)
        self.mksConnect.setStateClosed.connect(self._onSetStateClosed)
        self.mksConnect.updateFileList.connect(self._onUpdateFileList)
        self.mksConnect.updateShowText.connect(self._onUpdateShowText)
        self.mksConnect.updateInfoRequested.connect(self._onUpdateInfoRequested)
                            
    #发送和接收函数等
    connectionStateControlChanged = pyqtSignal()

    @pyqtSlot(str)
    def sendCommand(self, cmd):
        if self.firmware_manufacturers =="MKS":
            # self.mksConnect._sendCommand(cmd)
            if cmd == "DOWNLOAD_CONFIGURE":
                self.downloadConfigure()
            else:
                self.mksConnect._sendCommand("printer/gcode/script?script="+cmd,"post")
            # /api/printer/command 
            # "printer/gcode/script?script=G91"
        else:
            self.cbdConnect._sendCommand(cmd)

    @pyqtSlot()
    def cancelPrint(self):
        if self.firmware_manufacturers =="MKS":
            self.sendCommand("CANCEL_PRINT")
        else:
            self.cbdConnect._sendCommand("M33")
# SDCARD_PRINT_FILE FILENAME="20mm_Box.gcode"
    @pyqtSlot()
    def pausePrint(self):
        if self.firmware_manufacturers =="MKS":
            self.sendCommand("PAUSE")
        else:
            self.cbdConnect._sendCommand("M25")

    @pyqtSlot()
    def continuePrint(self):
        if self.firmware_manufacturers =="MKS":
            self.sendCommand("RESUME")
        else:
            self.cbdConnect._sendCommand("M24")

    @pyqtSlot(str)
    def printSDFiles(self, filename):
        if self.firmware_manufacturers =="MKS":
            # filename = filename[:filename.find(".gcode")+len(".gcode")]
            filename = filename.replace(".",".")
            self.sendCommand("SDCARD_PRINT_FILE FILENAME="+filename.replace("\\", "/"))
        else:
            if ".tz" in filename :
                filename = filename[:filename.find(".tz")+len(".tz")] 
            else:
                filename = filename[:filename.find(".gcode")+len(".gcode")] 

            self.cbdConnect._sendCommand('M6030 ":' + filename + '" I1')

    @pyqtSlot(str)
    def deleteSDFiles(self, filename):
        if self.firmware_manufacturers =="MKS":
            # self._sendCommand("M30 1:/" + filename+"\r\nM20\r\n")
            self.mksConnect._sendDeleteRequest("server/files/gcodes/"+filename.replace("\\","/"),on_success = self.mksConnect._checkPrinterStatus)
        else:
            if "tz" in filename :
                filename = filename[:filename.find(".tz")+len(".tz")] 
            else:
                filename = filename[:filename.find(".gcode")+len(".gcode")] 
            self.cbdConnect._sendCommand('M30 ' + filename)
            time.sleep(0.2)
            self.cbdConnect._sendCommand('M20 ')

    @pyqtSlot()
    def refreshSDFiles(self):
        if self.firmware_manufacturers =="MKS":
            self.mksConnect._sendCommand("server/files/list","get")
        else:
            self.cbdConnect._sendCommand("M20")

    @pyqtSlot(str,str)
    def e0down(self,e,speed):
        if self.firmware_manufacturers =="MKS":
            try:
                # self.sendCommand("T0\r\n G91\r\n G1 E%s F%s\r\n G90"% (e, str(int(speed)*60)))
                self.mksConnect._sendCommand("printer/gcode/script?script=T0\nG91\nG1 E%s F%s\nG90"% (e, str(int(speed)*60)),"post")
                # self.mksConnect._sendCommand(["printer/gcode/script?script=T0","printer/gcode/script?script=G91","printer/gcode/script?script=G1 E%s F%s"% (e, str(int(speed)*60)),"printer/gcode/script?script=G90"],"post")
            except:
                Logger.log("e","change E0 speed type error")
        else:
            try:
                self.cbdConnect._sendCommand("G1 E%s F%s I0 T0\r\n"% (e, str(int(speed)*60)))
            except:
                Logger.log("e","change E0 speed type error")

    @pyqtSlot(str,str)
    def e0up(self,e,speed):
        if self.firmware_manufacturers =="MKS":
            try:
                self.mksConnect._sendCommand("printer/gcode/script?script=T0\nG91\nG1 E-%s F%s\nG90"% (e, str(int(speed)*60)),"post")
                # self.mksConnect._sendCommand(["printer/gcode/script?script=T0","printer/gcode/script?script=G91","printer/gcode/script?script=G1 E-%s F%s"% (e, str(int(speed)*60)),"printer/gcode/script?script=G90"],"post")
                # self.sendCommand("T0\r\n G91\r\n G1 E-%s F%s\r\n G90"% (e, str(int(speed)*60)))
            except:
                Logger.log("e","change E0 speed type error")
        else:
            try:
                self.cbdConnect._sendCommand("G1 E-%s F%s I0 T0\r\n"% (e, str(int(speed)*60)))
            except:
                Logger.log("e","change E0 speed type error")

    @pyqtSlot(str,str)
    def e1down(self,e,speed):
        if self.firmware_manufacturers =="MKS":
            try:
                self.mksConnect._sendCommand("printer/gcode/script?script=T1\nG91\nG1 E%s F%s\nG90"% (e, str(int(speed)*60)),"post")
                # self.mksConnect._sendCommand(["printer/gcode/script?script=T1","printer/gcode/script?script=G91","printer/gcode/script?script=G1 E%s F%s"% (e, str(int(speed)*60)),"printer/gcode/script?script=G90"],"post")
                # self.sendCommand("T1\r\n G91\r\n G1 E%s F%s\r\n G90"% (e, str(int(speed)*60)))
            except:
                Logger.log("e","change E1 speed type error")
        else:
            try:
                self.cbdConnect._sendCommand("G1 E%s F%s I0 T1\r\n"% (e, str(int(speed)*60)))
            except:
                Logger.log("e","change E1 speed type error")

    @pyqtSlot(str,str)
    def e1up(self,e,speed):
        if self.firmware_manufacturers =="MKS":
            try:
                self.mksConnect._sendCommand("printer/gcode/script?script=T1\nG91\nG1 E-%s F%s\nG90"% (e, str(int(speed)*60)),"post")
                # self.mksConnect._sendCommand(["printer/gcode/script?script=T1","printer/gcode/script?script=G91","printer/gcode/script?script=G1 E-%s F%s"% (e, str(int(speed)*60)),"printer/gcode/script?script=G90"],"post")
                # self.sendCommand("T1\r\n G91\r\n G1 E-%s F%s\r\n G90"% (e, str(int(speed)*60)))
            except:
                Logger.log("e","change E1 speed type error")
        else:
            try:
                self.cbdConnect._sendCommand("G1 E-%s F%s I0 T1\r\n"% (e, str(int(speed)*60)))
            except:
                Logger.log("e","change E1 speed type error")

    @pyqtSlot(str,str)
    def xleft(self,x,speed):
        if self.firmware_manufacturers =="MKS":
            try:
                # self.sendCommand("G91\r\n G1 X%s F%s\r\n G90"% (x, str(int(speed)*60)))
                # self.mksConnect._sendCommand(["printer/gcode/script?script=G91","printer/gcode/script?script=G1 X%s F%s"% (x, str(int(speed)*60)),"printer/gcode/script?script=G90"],"post")
                self.mksConnect._sendCommand("printer/gcode/script?script=G91\nG1 X-%s F%s\nG90"% (x, str(int(speed)*60)),"post")
            except:
                Logger.log("e","change X speed type error")
        else:
            try:
                self.cbdConnect._sendCommand("G1 X-%s F%s I0\r\n"% (x, str(int(speed)*60)))
            except:
                Logger.log("e","change X speed type error")

    @pyqtSlot(str,str)
    def xright(self,x,speed):
        if self.firmware_manufacturers =="MKS":
            try:
                # self.mksConnect._sendCommand("printer/gcode/script?script=G91\r\n G1 X-%s F%s\r\n G90"% (x, str(int(speed)*60)),"post")
                # self.mksConnect._sendCommand(["printer/gcode/script?script=G91","printer/gcode/script?script=G1 X-%s F%s"% (x, str(int(speed)*60)),"printer/gcode/script?script=G90"],"post")
                self.mksConnect._sendCommand("printer/gcode/script?script=G91\nG1 X%s F%s\nG90"% (x, str(int(speed)*60)),"post")
            except:
                Logger.log("e","change X speed type error")
        else:
            try:
                self.cbdConnect._sendCommand("G1 X%s F%s I0\r\n"% (x, str(int(speed)*60)))
            except:
                Logger.log("e","change X speed type error")

    @pyqtSlot(str,str)
    def yback(self,y,speed):
        if self.firmware_manufacturers =="MKS":
            try:
                # self.sendCommand("G91\r\n G1 Y%s F%s\r\n G90"% (y, str(int(speed)*60)))
                # self.mksConnect._sendCommand(["printer/gcode/script?script=G91","printer/gcode/script?script=G1 Y%s F%s"% (y, str(int(speed)*60)),"printer/gcode/script?script=G90"],"post")
                self.mksConnect._sendCommand("printer/gcode/script?script=G91\nG1 Y-%s F%s\nG90"% (y, str(int(speed)*60)),"post")

            except:
                Logger.log("e","change Y speed type error")
        else:
            try:
                self.cbdConnect._sendCommand("G1 Y-%s F%s I0\r\n"% (y, str(int(speed)*60)))
            except:
                Logger.log("e","change Y speed type error")

    @pyqtSlot(str,str)
    def yfont(self,y,speed):
        if self.firmware_manufacturers =="MKS":
            try: 
                # self.sendCommand("G91\r\n G1 Y-%s F%s\r\n G90"% (y, str(int(speed)*60)))
                self.mksConnect._sendCommand("printer/gcode/script?script=G91\nG1 Y%s F%s\nG90"% (y, str(int(speed)*60)),"post")
            except:
                Logger.log("e","change Y speed type error")
        else:
            try:
                self.cbdConnect._sendCommand("G1 Y%s F%s I0\r\n"% (y, str(int(speed)*60)))
            except:
                Logger.log("e","change Y speed type error")

    @pyqtSlot(str,str)
    def zdown(self,z,speed):
        if self.firmware_manufacturers =="MKS":
            try:
                # self.sendCommand("G91\r\n G1 Z%s F%s\r\n G90"% (z, str(int(speed)*60)))
                self.mksConnect._sendCommand("printer/gcode/script?script=G91\nG1 Z%s F%s\nG90"% (z, str(int(speed)*60)),"post")
            except:
                Logger.log("e","change Z speed type error")
        else:
            try:
                self.cbdConnect._sendCommand("G1 Z%s F%s I0\r\n"% (z, str(int(speed)*60)))
            except:
                Logger.log("e","change Z speed type error")

    @pyqtSlot(str,str)
    def zup(self,z,speed):
        if self.firmware_manufacturers =="MKS":
            try:
                # self.sendCommand("G91\r\n G1 Z-%s F%s\r\n G90"% (z, str(int(speed)*60)))
                self.mksConnect._sendCommand("printer/gcode/script?script=G91\nG1 Z-%s F%s\nG90"% (z, str(int(speed)*60)),"post")
            except:
                Logger.log("e","change Z speed type error")
        else:
            try:
                self.cbdConnect._sendCommand("G1 Z-%s F%s I0\r\n"% (z, str(int(speed)*60)))
            except:
                Logger.log("e","change Z speed type error")

    @pyqtSlot()
    def xyhome(self):
        if self.firmware_manufacturers =="MKS":
            # self._sendCommand("G28 X Y")
            self.mksConnect._sendCommand("printer/gcode/script?script=G28","post")
        else:
            self.cbdConnect._sendCommand("G28 X0 Y0")

    @pyqtSlot()
    def zhome(self):
        if self.firmware_manufacturers == "MKS":
            self.mksConnect._sendCommand("printer/gcode/script?script=G28 Z","post")
        else:
            self.cbdConnect._sendCommand("G28 Z")

    @pyqtSlot(str)
    def setfan(self,speed):
        if self.firmware_manufacturers == "MKS":
            self.sendCommand("SET_PIN PIN=fan0 VALUE=%s"%(str(int(speed)*2.55)))
        else:
            self.cbdConnect._sendCommand("M106 S%s"%(str(int(speed)*2.55)))

    @pyqtSlot(str)
    def setrapidfan(self,speed):
        if self.firmware_manufacturers == "MKS":
            self.sendCommand("SET_PIN PIN=fan2 VALUE=%s"%(str(int(speed)*2.55)))
        else:
            self.cbdConnect._sendCommand("M106 S%s"%(str(int(speed)*2.55)))

    @pyqtSlot(str)
    def setchamber(self,speed):
        if self.firmware_manufacturers == "MKS":
            self.sendCommand("SET_PIN PIN=fan1 VALUE=%s"%(str(int(speed)*2.55)))
        else:
            self.cbdConnect._sendCommand("M106 T-2 S%s"%(str(int(speed)*2.55)))

    @pyqtSlot(str)
    def setVolumet(self,tem):
        if self.firmware_manufacturers =="MKS":
            self.mksConnect._sendCommand("M141 S%s"%(str(tem)),"post")
        else:
            self.cbdConnect._sendCommand("M141 S%s"%(str(tem)))

    @pyqtSlot(str)
    def setSensor(self,sen):
        if self.firmware_manufacturers =="MKS":
            self.sendCommand("SET_FILAMENT_SENSOR SENSOR=fila ENABLE=%s"%(str(sen)))
        else:
            self.cbdConnect._sendCommand("M8029 D%s"%(str(sen)))

    @pyqtSlot(str)
    def setextruder0t(self,tem):
        if self.firmware_manufacturers =="MKS":
            self.sendCommand("SET_HEATER_TEMPERATURE HEATER=extruder TARGET=%s"%(tem))
        else:
            self.cbdConnect._sendCommand("M104 T0 S%s"%(str(tem)))

    @pyqtSlot(str)
    def setextruder1t(self,tem):
        self.cbdConnect._sendCommand("M104 T1 S%s"%(tem))

    @pyqtSlot(str)
    def setbedt(self,tem):
        if self.firmware_manufacturers =="MKS":
            # self.sendCommand("M892 S%s"%(tem))
            self.sendCommand("SET_HEATER_TEMPERATURE HEATER=heater_bed TARGET=%s"%(str(tem)))

        else:
            self.cbdConnect._sendCommand("M140 S%s"%(str(tem)))

    @pyqtSlot()
    def motorsoff(self):
        if self.firmware_manufacturers == "MKS":
            self.mksConnect._sendCommand("printer/gcode/script?script=M84","post")


    @pyqtSlot()
    def machinestop(self):
        if self.firmware_manufacturers == "MKS":
            # self.mksConnect._sendCommand("printer/gcode/script?script=M0","post")
            self.mksConnect._sendCommand("printer/gcode/script?script=M84","post")
        else:
            self.cbdConnect._sendCommand("M112")

    @pyqtSlot()
    def machineclose(self):
        if self.firmware_manufacturers =="MKS":
            self.mksConnect._sendCommand("printer/gcode/script?script=M81","post")
            # self.mksConnect._sendCommand("printer/gcode/script?script=M84","post")
        else:
            self.cbdConnect._sendCommand("M4003")

    @pyqtSlot(str)
    def setname(self,name):
        change_name = "U100 " + "\'" + name + "\'"
        nameSum = 0
        for i in change_name:
            nameSum ^= ord(i)
        if self.firmware_manufacturers =="CBD":
            self.cbdConnect.thisdict["printer_name"] = name
            self.cbdConnect._sendCommand(change_name + "&" + str(nameSum) + "&")
        else:
            self.mksConnect.thisdict["printer_name"] = name
            # self.mksConnect._sendCommand("/printer/dev_name?name="+name,"get")
            self.mksConnect._sendCommand("machine/system_info?dev_name="+name,"get")

    @pyqtSlot()
    def selectFileToUplload(self):
        if self.firmware_manufacturers =="MKS":
            filename, type = QFileDialog.getOpenFileName(None, 'Upload file to Machine', "C:\\", "(*.gcode);;all files(*.*)")
            self._uploadpath = filename
            if ".g" in filename.lower():
                # if self.isBusy():
                #     return
                # else:
                self.mksConnect.uploadfunc(filename,'')
        else:
            path, type = QFileDialog.getOpenFileName(None, 'Upload file to Machine', "C:\\", "(*.gcode);;all files(*.*)")
            self.cbdConnect.getFilePath = str(path)
            if path != '':
                self.cbdConnect._sendCommand("M28")

    def downloadConfigure(self):
        self.mksConnect._sendCommand("server/files/config/printer.cfg","get")
        self.mksConnect._sendCommand("server/files/config/MKS_THR.cfg","get")

    @pyqtSlot(str)
    def selectFileToDownload(self,filename):
        if self.firmware_manufacturers =="MKS":
            # filename, type = QFileDialog.getOpenFileName(None, 'Upload file to Machine', "C:\\", "(*.gcode);;all files(*.*)")
            # if filename!= None:
            # dlg = QFileDialog()
            # dlg.setFileMode(QFileDialog.AnyFile)
            # dlg.setFilter(QDir.Files)
            # if dlg.exec_():
            path, type = QFileDialog.getSaveFileName(None, 'Save file to Disk', filename, "(*.gcode)")

            self.mksConnect.getFilePath = str(path)#str(dlg.selectedFiles()[0])
            # self.mksConnect.getFilePath = filename
            if self.mksConnect.getFilePath != None and self.mksConnect.getFilePath !="":
                self.mksConnect._sendCommand("server/files/gcodes/"+filename.replace("\\", "/"),"get")
        else:
            if "tz" in filename :
                filename = filename[:filename.find(".tz")+len(".tz")] 
            else:
                filename = filename[:filename.find(".gcode")+len(".gcode")] 
            self.select_file = filename
            path, type = QFileDialog.getSaveFileName(None, 'Save file to Disk', filename, "(*.gcode)")
            self.cbdConnect.getFilePath = str(path)
            if self.cbdConnect.getFilePath != None and self.cbdConnect.getFilePath !="":
                self.cbdConnect._sendCommand("M6032 " + "'" + filename + "'")
                    
    PrintstateChanged = pyqtSignal()
    @pyqtProperty(bool, notify = PrintstateChanged)
    def isBusy(self):
        if self.firmware_manufacturers =="MKS":
            return self.mksConnect.isBusy()
        else:
            return self.cbdConnect.isBusy()

    @pyqtProperty(bool, notify = PrintstateChanged)
    def isPrinting(self): 
        if self.firmware_manufacturers =="MKS":
            return self.mksConnect.isPrinting()
        else:
            return self.cbdConnect.isPrinting()

    @pyqtProperty(bool, notify = PrintstateChanged)
    def isPause(self): 
        if self.firmware_manufacturers =="MKS":
            return self.mksConnect.isPause()
        else:
            return self.cbdConnect.isPause()

    #实时温度  
    TempStringChanged = pyqtSignal()
    #打印机列表信息
    PrinterInfoListChanged = pyqtSignal()
    # PrinterNameChanged = pyqtSignal()

    @pyqtProperty("QString", notify = TempStringChanged)
    def realE1TempString(self): 
        return self.thisdict["E1Tem"] #self.realE1Temp

    @pyqtProperty("QString", notify = TempStringChanged)
    def expectE1TempString(self): 
        return self.thisdict["E1TarTem"] #self.exceptE1Temp

    @pyqtProperty("QString", notify = TempStringChanged)
    def realE2TempString(self): 
        return self.thisdict["E2Tem"] #self.realE2Temp

    @pyqtProperty("QString", notify = TempStringChanged)
    def expectE2TempString(self): 
        return self.thisdict["E2TarTem"]# self.exceptE2Temp

    @pyqtProperty("QString", notify = TempStringChanged)
    def realBedTempString(self): 
        return self.thisdict["BedTem"] # self.realBedTemp

    @pyqtProperty("QString", notify = TempStringChanged)
    def expectBedTempString(self): 
        return self.thisdict["BedTarTem"] # self.exceptBedTemp

    @pyqtProperty("QString", notify = TempStringChanged)
    def realVolTempString(self): 
        return self.thisdict["VolTem"] # self.realVolTemp

    @pyqtProperty("QString", notify = TempStringChanged)
    def expectVolTempString(self): 
        return self.thisdict["VolTarTem"] # self.exceptVolTemp

    @pyqtProperty("QString", notify = TempStringChanged)
    def realIReadString(self): 
        return self.thisdict["FilaSen"] # self.realiread

    @pyqtProperty("QString", notify = TempStringChanged)
    def realFanSpeedString(self): 
        return self.thisdict["FanSpeed"] # self.realFanSpeed


    @pyqtProperty("QString", notify = TempStringChanged)
    def realrapid_cooling_speedString(self): 
        return self.thisdict["rapid_cooling_speed"] # self.realFanSpeed

    @pyqtProperty("QString", notify = TempStringChanged)
    def realchamber_cooling_speedString(self): 
        return self.thisdict["chamber_cooling_speed"] # self.realFanSpeed

    @pyqtProperty("QString", notify = TempStringChanged)
    def exceptFanSpeedString(self): 
        return self.thisdict["FanTarSpeed"] # self.exceptFanSpeed

    @pyqtProperty("QString", notify = TempStringChanged)
    def xlocationString(self): 
        return self.thisdict["x_location"] # self.x_location

    @pyqtProperty("QString", notify = TempStringChanged)
    def ylocationString(self): 
        return self.thisdict["y_location"] # self.y_location

    @pyqtProperty("QString", notify = TempStringChanged)
    def zlocationString(self): 
        return self.thisdict["z_location"] # self.z_location

    @pyqtProperty("QString", notify = PrinterInfoListChanged)
    def printertypeString(self): 
        return self.thisdict["printer_type"] # self.printer_type

    @pyqtProperty("QString", notify = PrinterInfoListChanged)
    def macadressString(self): 
        return self.thisdict["mac_address"] # self.mac_address

    @pyqtProperty("QString", notify = PrinterInfoListChanged)
    def ipadressString(self): 
        return self.thisdict["ip_address"] # self.ip_address

    @pyqtProperty("QString", notify = PrinterInfoListChanged)
    def wifiversionString(self): 
        return self.thisdict["wifi_version"] # self.wifi_version

    @pyqtProperty("QString", notify = PrinterInfoListChanged)
    def extrudernumString(self): 
        return self.thisdict["extruder_num"] # self.extruder_num

    @pyqtProperty("QString", notify = PrinterInfoListChanged)
    def printersizeString(self): 
        return self.thisdict["printsize_string"] # self.printsize_string

    @pyqtProperty("QString", notify = PrinterInfoListChanged)
    def printernameString(self): 
        return self.thisdict["printer_name"] # self.printer_name

    @pyqtProperty("QString", notify = TempStringChanged)
    def PrintProgress(self): 
        return self.thisdict["print_progress"]

    @pyqtProperty("QString", notify = PrinterInfoListChanged)
    def MotorsString(self): 
        return self.thisdict["homed_axes"] # self.printer_name

    @pyqtProperty("QString", notify = PrinterInfoListChanged)
    def firmwareString(self): 
        return self.firmware_manufacturers

    @pyqtProperty("QString", notify = PrinterInfoListChanged)
    def chamber_cooling_enabled(self): 
        return self.thisdict["chamber_cooling_enabled"] 

    @pyqtProperty("QString", notify = PrinterInfoListChanged)
    def rapid_cooling_enabled(self): 
        return self.thisdict["rapid_cooling_enabled"] 

    @pyqtProperty("QString", notify = PrinterInfoListChanged)
    def volume_enabled(self): 
        return self.thisdict["volume_enabled"] 

    @pyqtProperty("QString", notify = PrinterInfoListChanged)
    def close_machine_enabled(self): 
        return self.thisdict["close_machine_enabled"] 



    @pyqtSlot(str)    
    def connect(self,string):
        Logger.log("d","The firmware manufacturers: "+string[-3:])
        ip_add = string[string.find("/")+1:string.rfind("/")]
        ip_name = string[:string.find("/")]
        Logger.log("d","IP address: "+ip_add)
        self.firmware_manufacturers = string[-3:]
        # self.firmware_manufacturers = "MKS"
        if self.firmware_manufacturers in ["MKS","CBD","KLI"]:
            if self.firmware_manufacturers =="MKS":
                self.select_ip = ip_add
                self.mksConnect.connect(ip_add,ip_name)
                
                # self.mksconnect(ip_add)
            elif self.firmware_manufacturers =="CBD":
                # self.cbdconnect(ip_add)
                CBDConnect.getInstance().connect(ip_add)
                # self.setConnectionState(cast(ConnectionState, UnifiedConnectionState.Connecting))
        else:
            Logger.log("e","The wrong manufacturer")

    def setConnectionState(self, connection_state: "ConnectionState") -> None:
        if self._connection_state != connection_state:
            self._connection_state = connection_state
            self.connectionStateControlChanged.emit()


    @pyqtProperty(int, notify = connectionStateControlChanged)
    def connectionState(self) -> "ConnectionState":
        return self._connection_state

    @pyqtSlot()    
    def disconnect(self):
        Logger.log("d", "disconnect--------------")
        if self.firmware_manufacturers == "MKS":
            self.mksConnect.disconnect()
        else:
            self.cbdConnect.disconnect()
        return
         
    FileListChanged = pyqtSignal()
    @pyqtProperty("QVariantList", notify=FileListChanged)
    def FileList(self):
        list = []
        self.sdFiles.sort()
        return self.sdFiles#list

    alliplistChanged = pyqtSignal()
    @pyqtProperty("QString", notify = alliplistChanged)
    def getalliplist(self):
        # 更新文件列表
        Logger.log("i", "WifiSend.getInstance().alliplist = %s" , WifiSend.getInstance().alliplist )
        return WifiSend.getInstance().alliplist

    def _onUpdateRequested(self):
        if self.firmware_manufacturers =="MKS":
            self.thisdict = self.mksConnect.thisdict
        else:
            self.thisdict = self.cbdConnect.thisdict
        self.TempStringChanged.emit()
        self.PrintstateChanged.emit()

    def _onUpdateInfoRequested(self):
        if self.firmware_manufacturers =="MKS":
            self.thisdict = self.mksConnect.thisdict
        else:
            self.thisdict = self.cbdConnect.thisdict
        self.PrinterInfoListChanged.emit()
        # self.PrintstateChanged.emit()

    def _onSetStateConnected(self):
        self.setConnectionState(ConnectionState.Connected)
        # if self.firmware_manufacturers =="MKS":
        #     self.thisdict = self.mksConnect.thisdict
        # else:
        #     self.thisdict = self.cbdConnect.thisdict
        # self.PrinterInfoListChanged.emit()
        # self.PrinterNameChanged.emit()
        
    def _onSetStateClosed(self):
        self.setConnectionState(ConnectionState.Closed)

    def _onUpdateFileList(self):
        if self.firmware_manufacturers =="MKS":
            self.sdFiles = self.mksConnect.sdFiles
        else:
            self.sdFiles = self.cbdConnect.sdFiles
        self.FileListChanged.emit()

    def _onUpdateShowText(self):
        if self.firmware_manufacturers =="MKS":
            if len(self.mksConnect.show_text)>25000:
                self.mksConnect.show_text = ''
            self.show_text = self.mksConnect.show_text
        else:
            if len(self.cbdConnect.show_text)>25000:
                self.cbdConnect.show_text = ''
            self.show_text = self.cbdConnect.show_text
        self.allResultdataChanged.emit()



    allResultdataChanged = pyqtSignal()
    @pyqtProperty("QString", notify = allResultdataChanged)
    def allResultdata(self): 
        return self.select_ip + "  " + "Connnected:\n " + self.show_text

    # 实例化对象
    def showControlPanel(self):
        if not self._controlpanel_window:
            #path = os.path.join(PluginRegistry.getInstance().getPluginPath(self.getPluginId()), "ControlPanel.qml")
            # path = "qrc:/ControlPanel.qml"
            path = "./plugins/ControlPanelPlugin/ControlPanel.qml"
            if os.path.exists(path):
                self._controlpanel_window = Application.getInstance().createQmlComponent(path, {"controlpanel": self})
            else:
                path = "qrc:/ControlPanel.qml"
                self._controlpanel_window = Application.getInstance().createQmlComponent(path, {"controlpanel": self})
        self._controlpanel_window.show()
