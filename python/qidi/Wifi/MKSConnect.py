# -*- coding: utf-8 -*-


import sys
import time
import json
from queue import Queue
from QD.i18n import i18nCatalog
from PyQt5.QtCore import  QObject,QByteArray,QVariant,QTimer
from PyQt5.QtNetwork import QHttpMultiPart, QHttpPart, QNetworkRequest,  QNetworkReply
from QD.Logger import Logger
from QD.Signal import Signal
from qidi.QIDIApplication import QIDIApplication
from QD.Message import Message
from QD.Resources import Resources
from QD.TaskManagement.HttpRequestManager import HttpRequestManager
import collections
from QD.Settings.ContainerRegistry import ContainerRegistry

catalog = i18nCatalog("qidi")

try:
    NoError = QNetworkReply.NetworkError.NoError
    FormDataType = QHttpMultiPart.ContentType.FormDataType
    ContentDispositionHeader = QNetworkRequest.KnownHeaders.ContentDispositionHeader
    ContentTypeHeader = QNetworkRequest.KnownHeaders.ContentTypeHeader
except AttributeError:
    NoError = 0
    FormDataType = QHttpMultiPart.FormDataType
    ContentDispositionHeader = QNetworkRequest.ContentDispositionHeader
    ContentTypeHeader = QNetworkRequest.ContentTypeHeader

class MKSConnect(QObject):

    def __init__(self):

        super(MKSConnect, self).__init__()              #不运行父类初始化，不知道原因，但是只有这样才能让下面的定时器被调用时能正常运行
        self._command_get_queue = Queue()
        self._command_post_queue = Queue()

        self._socket = None
        self._update_timer = QTimer()
        self.select_ip =""
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
            "homed_axes":"",
            "chamber_cooling_enabled" : "False",
            "rapid_cooling_enabled" : "False",
            "volume_enabled" : "False",
            "close_machine_enabled":"False",
            "rapid_cooling_speed":"0",
            "chamber_cooling_speed":"0"
            }
        self._sdFileList = False
        self._isPrinting = False
        self._isPause = False
        self._ischanging = False
        self.isGettingFiles = False
        self.sendind_file = False
        self.sdFiles = []
        self.firmware_manufacturers = ""
        self._localTempGcode = ""
        self.sendNow = 0
        self.sendMax = 0
        self._progress_message = None
        self._connect_progress_message = None
        self.getFilePath = None
        self.show_text = ""
        self._file_encode = 'utf-8'
        self.sendtime = 0
        self.error_message = Message(catalog.i18nc("@info:status", ""), 0, False)#Message(catalog.i18nc("@info:status", "There was a network error: {}").format(reply.errorString()[reply.errorString().find("server replied:")+15:] if reply else ""), 0, False)
        self.error_message.setTitle("QIDI - Error")
        self._container_registry = ContainerRegistry.getInstance()
        self._get_file_list = True
        self._get_system_info = True


    updateRequested = Signal()
    updateFileList = Signal()
    setStateConnected = Signal()
    setStateClosed = Signal()
    updateShowText = Signal()
    updateInfoRequested = Signal()

    def connect(self,ipstr,ipnamestr):

        self._update_timer = QTimer()
        self._update_timer.setInterval(100)  # TODO; Add preference for update interval
        self._update_timer.setSingleShot(False)
        self._update_timer.timeout.connect(self.update)
        Logger.log("d","self._socket.connectToHost %s" % ipstr)
        Logger.log("d", "QIDI socket connecting ")
        self.select_ip = ipstr+":7125"
        self.show_connect_progress_message()
        self._get_file_list = True
        self._get_system_info = True
        self._connect_progress_message.setProgress(0)
        self._update_timer.start()
    
    def disconnect(self):
        self._isConnect = False
        self._update_timer.stop()
        self.show_text = ""
        self.select_ip = ""
        self.sdFiles = []
        self.thisdict =	{"state":"","E1Tem": "0","E2Tem": "0","BedTem": "0","FanSpeed":"0","E1TarTem": "0","E2TarTem": "0","BedTarTem": "0","FanTarSpeed": "0","VolTem": "0","VolTarTem": "0","FilaSen": "0","x_location":"0","y_location" : "0","z_location":"0","printer_type" : "None","mac_address" : "None","ip_address" : "None","wifi_version" : "None","extruder_num" : "1","printsize_string" : "0/0/0","printer_name" : "","print_progress" : "0%","homed_axes":"",
            "chamber_cooling_enabled" : "False",
            "rapid_cooling_enabled" : "False",
            "volume_enabled" : "False",
            "close_machine_enabled":"False",
            "rapid_cooling_speed":"0",
            "chamber_cooling_speed":"0"}
        self.updateRequested.emit()
        self.updateFileList.emit()
        self.setStateClosed.emit()
        self.updateShowText.emit()
        self.updateInfoRequested.emit()
        self._get_file_list = True
        self._get_system_info = True
        self._isPause = False
        self._isPrinting = False


    def _sendCommand(self, cmd,request):
        # if self._ischanging:
            # if "G28" in cmd or "G0" in cmd:
                # Logger.log("d", "_sendCommand G28 in cmd or G0 in cmd-----------: %s" % str(cmd))
                # return
        # if self.isBusy():
            # if "M20" in cmd:
                # Logger.log("d", "_sendCommand M20 in cmd-----------: %s" % str(cmd))
                # return
        # if self.isGettingFiles:
            # if "M20" in cmd:
                # Logger.log("d", "isGettingFiles _sendCommand M20 in cmd-----------: %s" % str(cmd))
                # return
        # if self._socket and self._socket.state() == 2 or self._socket.state() == 3:
        if request=="get" and isinstance(cmd, str):
                self._command_get_queue.put(cmd + "\r\n")
        elif request=="get" and isinstance(cmd, list):
            for eachCommand in cmd:
                self._command_get_queue.put(eachCommand + "\r\n")
        elif request=="post" and isinstance(cmd, str):
            self._command_post_queue.put(cmd + "\r\n")
        elif request=="post" and isinstance(cmd, list):
            for eachCommand in cmd:
                self._command_post_queue.put(eachCommand + "\r\n")

    def update(self):
        if self.sendtime > 10:
            self.disconnect()
            return
        if self.sendind_file :
            Logger.log("i","Sending file")
            time.sleep(1)
        else:
            if self._command_get_queue.qsize() > 0 or self._command_post_queue.qsize() > 0:
                _send_data = ""
                _send_post_data = ""
            elif self._get_file_list and self._get_system_info:
                _send_data = 'server/files/list\r\nmachine/system_info\r\nprinter/objects/query?toolhead=position,homed_axes&output_pin fan0&output_pin fan1&output_pin fan2&print_stats=state&display_status=progress&heater_bed=target,temperature&extruder=target,temperature&filament_switch_sensor fila'
                # _send_data = "printer/dev_name"
                _send_post_data = ""
            elif self._get_file_list:
                _send_data = 'server/files/list'
                _send_post_data = ""
            elif self._get_system_info:
                _send_data = '/machine/system_info'
                _send_post_data = ""
            else:
                _send_data = 'printer/objects/query?toolhead=position,homed_axes&output_pin fan0&output_pin fan1&output_pin fan2&print_stats=state&display_status=progress&heater_bed=target,temperature&extruder=target,temperature&filament_switch_sensor fila'
                _send_post_data = ""

            while self._command_get_queue.qsize() > 0:
                _queue_data = self._command_get_queue.get()
                _send_data += _queue_data
                self.show_text +="-> %s \r\n" % _queue_data
                self.updateShowText.emit()
            send_cmd_list = _send_data.split("\r\n")
            for i in send_cmd_list:
                if i != "":
                    Logger.log("d", "_send_data: %s\r\n" % i)
                    if i == 'printer/objects/query?toolhead=position,homed_axes&output_pin fan0&output_pin fan1&output_pin fan2&print_stats=state&display_status=progress&heater_bed=target,temperature&extruder=target,temperature&filament_switch_sensor fila' or i == '/machine/system_info' or i == 'server/files/list':
                        self._sendRequest(i,on_success = self._checkPrinterStatus2)
                    else:
                        self._sendRequest(i,on_success = self._checkPrinterStatus)
                    
                    # self.show_text +="-> %s \r\n" % i
                    time.sleep(0.2)

            while self._command_post_queue.qsize() > 0:
                _queue_data = self._command_post_queue.get()
                _send_post_data += _queue_data
                self.show_text +="-> %s \r\n" % _queue_data
                self.updateShowText.emit()
            send_cmd_list = _send_post_data.split("1232")#.split("\r\n")
            for i in send_cmd_list:
                if i != "":
                    Logger.log("d", "_send_post_data: %s\r\n" % i)
                    self.sendtime +=1

                    self._sendRequest(i,data = json.dumps({}).encode(), dataIsJSON = True,on_success = self._checkPrinterStatus)
                    # self.show_text +="-> %s \r\n" % i
                    time.sleep(0.2)

    def uploadfunc(self, filename,ipstr):
        if ipstr !='':
            ss = ipstr.split('/')
            if(len(ss) >= 3):
                ipstr = ss[-2]
            else:
                return
            # Logger.log("e",ipstr)
            self.select_ip = ipstr+":7125"
            filename_path = Resources.getStoragePath(Resources.Resources, "data.gcode")
            # Logger.log("e",filename_path)

            try:
                f = open(filename_path,
                            "r",
                            encoding=sys.getfilesystemencoding())
                single_string_file_data = f.read()
                self._last_file_name = filename+ ".gcode"
                file_data = QByteArray()
                file_data.append(single_string_file_data.encode())
                self.show_progress_message()
                self._sendRequest('server/files/upload', name = filename + ".gcode", data = file_data, on_success = self._checkPrinterStatus)  
                
            except IOError as e:
                self.got_ioerror(e)
            except Exception as e:
                self.got_exeption(e)
        else:
            try:
                f = open(filename,
                            "r",
                            encoding=sys.getfilesystemencoding())
                single_string_file_data = f.read()
                file_name = filename[filename.rfind("/") + 1:]
                self._last_file_name = filename[filename.rfind("/") + 1:]
                file_data = QByteArray()
                file_data.append(single_string_file_data.encode())
                self.show_progress_message()
                self._sendRequest('server/files/upload', name = file_name, data = file_data, on_success = self._checkPrinterStatus)  
                
            except IOError as e:
                self.got_ioerror(e)
            except Exception as e:
                self.got_exeption(e)

    def _onUploadProgress(self, bytesSent, bytesTotal) -> None:
        if bytesTotal > 0:
            progress = int(bytesSent * 100 / bytesTotal)
            if self._progress_message:
                self._progress_message.setProgress(progress)

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
        # self._progress_message.optionToggled.connect(
        #     self._onOptionStateChanged)
        self._progress_message.show()

    def show_connect_progress_message(self):

        status = catalog.i18nc("@info:status", "Connecting to printer")
        title = catalog.i18nc("@info:title", "Connecting Printer Job")
        self._connect_progress_message = Message(
            status,
            0,
            False,
            -1,
            title)
        self._connect_progress_message.addAction(
            "Cancel",  "Cancel", None, "")
        self._connect_progress_message.actionTriggered.connect(
            self._cancelConnect)
        self._connect_progress_message.show()

    def show_print_message(self):
        # if self._last_file_name.find(".gcode") == -1 :
            # self._last_file_name = self._last_file_name + ".gcode"
        m = Message(catalog.i18nc("@info:status", "Send file {0} successfully, Do you want to print the file now?", self.decodeCmd(self.encodeCmd(self._last_file_name))),
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

    def startPrintForButton(self, m, action):
        m.hide()
        if action == "No":
            self._last_file_name = None
            return
        # Logger.log("e",self._last_file_name)
        self._sendRequest("printer/gcode/script?script=SDCARD_PRINT_FILE FILENAME="+self._last_file_name,data = json.dumps({}).encode(), dataIsJSON = True,on_success = self._checkPrinterStatus)
        self._last_file_name = None



    def _cancelSendGcode(self, message_id, action_id):
        manager = HttpRequestManager.getInstance()
        manager.abortRequest(self._request_data)
        if self._progress_message is not None:
            self._progress_message.hide()
            self._progress_message = None

    def _cancelConnect(self, message_id, action_id):
        self.disconnect()
        if self._connect_progress_message is not None:
            self._connect_progress_message.hide()
            self._connect_progress_message = None

    def _onUploadError(self, reply, sslerror):
        Logger.log("d", "Upload Error")

    def got_ioerror(self, error):
        Logger.log("e", str(error))

    def got_exeption(self, error):
        Logger.log("e", str(error))

    def _getResponse(self, reply: QNetworkReply):
        byte_string = reply.readAll()
        response = ''
        try:
            response = json.loads(str(byte_string, 'utf-8'))
            Logger.log("d", "QIDI recv: " + str(response))
            # self.show_text +="<- %s \r\n" % str(response)
            # self.updateShowText.emit()

        except json.JSONDecodeError:
            if ";FLAVOR:Marlin" in str(byte_string):
                file_object = open(self.getFilePath, "wb")
                file_object.write(byte_string)
                file_object.close()
                self.getFilePath = None
            elif "This file contains common pin mappings for MKS SKIPR" in str(byte_string):
                file_object = open(Resources.getStoragePath(Resources.Preferences, "printer.cfg"), "wb")
                file_object.write(byte_string)
                file_object.close()
            elif "mcu MKS_THR" in str(byte_string):
                file_object = open(Resources.getStoragePath(Resources.Preferences, "MKS_THR.cfg"), "wb")
                file_object.write(byte_string)
                file_object.close() 
            else:
                Logger.log("e", "Reply is not a JSON: %s" % str(byte_string, 'utf-8'))
        return response

    def _sendRequest(self, path: str, name: str = None, data: QByteArray = None, dataIsJSON: bool = False, on_success = None, on_error = None) -> None:
        url = "http://"+self.select_ip+"/" + path
        # self.show_text +="-> %s \r\n" % path
        # self.updateShowText.emit()
        headers = {'User-Agent': 'Cura Plugin Moonraker', 'Accept': 'application/json, text/plain', 'Connection': 'keep-alive'}
        postData = data
        requestManager = QIDIApplication.getInstance().getHttpRequestManager()
        if data is not None:
            if not dataIsJSON:
                # Create multi_part request           
                parts = QHttpMultiPart(FormDataType)

                part_file = QHttpPart()
                part_file.setHeader(ContentDispositionHeader, QVariant('form-data; name="file"; filename="/' + name + '"'))
                part_file.setHeader(ContentTypeHeader, QVariant('application/octet-stream'))
                part_file.setBody(data)
                parts.append(part_file)

                part_root = QHttpPart()
                part_root.setHeader(ContentDispositionHeader, QVariant('form-data; name="root"'))
                part_root.setBody(b"gcodes")
                parts.append(part_root)

                # if self._startPrint:
                # part_print = QHttpPart()
                # part_print.setHeader(ContentDispositionHeader, QVariant('form-data; name="path"'))
                # part_print.setBody(b"/sda1")
                # parts.append(part_print)
                headers['Content-Type'] = 'multipart/form-data; boundary='+ str(parts.boundary().data(), encoding = 'utf-8')
                postData = parts
                self._request_data = requestManager.post(url, headers, postData, callback = on_success, error_callback = on_error if on_error else self._onRequestError, upload_progress_callback = self._onUploadProgress if not dataIsJSON else None)
                return
            else:
                # postData is JSON
                headers['Content-Type'] = 'application/json'

            requestManager.post(url, headers, postData, callback = on_success, error_callback = on_error if on_error else self._onRequestError, upload_progress_callback = self._onUploadProgress if not dataIsJSON else None)
        else:
            requestManager.get(url, headers, callback = on_success, error_callback = on_error if on_error else self._onRequestError)
    
    def _sendDeleteRequest(self, path: str, name: str = None, data: QByteArray = None, dataIsJSON: bool = False, on_success = None, on_error = None) -> None:
        url = "http://"+self.select_ip+"/" + path
        headers = {'User-Agent': 'Cura Plugin Moonraker', 'Accept': 'application/json, text/plain', 'Connection': 'keep-alive'}
        requestManager = QIDIApplication.getInstance().getHttpRequestManager()
        requestManager.delete(url, headers, callback = on_success, error_callback = on_error if on_error else self._onRequestError)


            # self.show_text +="<- %s \r\n" % str(response)
            # self.updateShowText.emit()

    def _checkPrinterStatus2(self, reply: QNetworkReply) -> None:
        
        if reply.error() !=  QNetworkReply.NetworkError.NoError :        
            Logger.log("e", "Stopping due to reply error: {}.".format(reply.error()))
            self._onRequestError(reply)
            return
        response = self._getResponse(reply)
        # self.show_text +="<- %s \r\n" % str(response)
        # self.updateShowText.emit()
        self.sendtime = 0
        # self.show_text +="<- %s \r\n" % response
        if isinstance(response,dict):
            if response.get("result") !=None:
                if isinstance(response['result'],dict):
                    if response['result'].get("status") != None:
                        self.printer_info_update(response)
                        return
                    elif response['result'].get("item") != None:
                        Logger.log("d","Delete Done")
                        self._sendCommand("server/files/list","get")
                    elif response['result'].get("system_info") != None:
                        self.ip_info_update(response)
                elif isinstance(response['result'],list):
                    self.printer_file_list_parse(response)
                    return
                elif isinstance(response['result'],str):
                    Logger.log("d",response['result'])
                    return
            elif  response.get("item") !=None:
                Logger.log("d","Send Done")
                if self._progress_message is not None:
                    self._progress_message.hide()
                    self._progress_message = None
                self._sendCommand("server/files/list","get")
                self.show_print_message()
        elif isinstance(response,str):
            Logger.log("i","download done")


    def _checkPrinterStatus(self, reply: QNetworkReply) -> None:
        if reply.error() !=  QNetworkReply.NetworkError.NoError :        
            Logger.log("e", "Stopping due to reply error: {}.".format(reply.error()))
            self._onRequestError(reply)
            return
        response = self._getResponse(reply)
        self.show_text +="<- %s \r\n" % str(response)
        self.updateShowText.emit()
        self.sendtime = 0
        # self.show_text +="<- %s \r\n" % response
        if isinstance(response,dict):
            if response.get("result") !=None:
                if isinstance(response['result'],dict):
                    if response['result'].get("status") != None:
                        self.printer_info_update(response)
                        return
                    elif response['result'].get("item") != None:
                        Logger.log("d","Delete Done")
                        self._sendCommand("server/files/list","get")
                    elif response['result'].get("system_info") != None:
                        self.ip_info_update(response)
                elif isinstance(response['result'],list):
                    self.printer_file_list_parse(response)
                    return
                elif isinstance(response['result'],str):
                    Logger.log("d",response['result'])
                    return
            elif  response.get("item") !=None:
                Logger.log("d","Send Done")
                if self._progress_message is not None:
                    self._progress_message.hide()
                    self._progress_message = None
                self._sendCommand("server/files/list","get")
                self.show_print_message()
        elif isinstance(response,str):
            Logger.log("i","download done")

    def ip_info_update(self, response):
        mac_address = response['result']['system_info']['network']['wlan0']['mac_address']
        ip_address = response['result']['system_info']['network']['wlan0']['ip_addresses'][0]['address']
        try:
            dev_name = response['result']['system_info']['machine_name']
        except:
            dev_name = "QIDI"
        self.thisdict["mac_address"] = mac_address
        self.thisdict["ip_address"] = ip_address
        self.thisdict["printer_name"] = dev_name
        self.thisdict["printer_type"] = "None" if dev_name.find("@") ==-1 else dev_name[dev_name.find("@") + 1:len(dev_name)]
        if dev_name.find("@") !=-1 :
            definitions = self._container_registry.findDefinitionContainers(id=dev_name[dev_name.find("@") + 1:].replace(" ","_"))
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
                self.thisdict["printsize_string"] = str(machine_width) +'/' + str(machine_depth) + '/' + str(machine_height)
            else:
                self.thisdict["printsize_string"] = "0/0/0"
        else:
            self.thisdict["printsize_string"] = "0/0/0"
        if self._connect_progress_message !=None:
            self._connect_progress_message.setProgress(66)

        # Logger.log("e",mac_adress)
        # Logger.log("e",ip_adress)
            self._get_system_info = False
        self.updateInfoRequested.emit()

    def printer_info_update(self, response):
        state = response['result']['status']['print_stats']['state']
        extruder_tem = response['result']['status']['extruder']['temperature']
        extruder_tar = response['result']['status']['extruder']['target']
        heater_bed_tem = response['result']['status']['heater_bed']['temperature']
        heater_bed_tar = response['result']['status']['heater_bed']['target']
        homed_axes = response['result']['status']['toolhead']['homed_axes']
        x_location = response['result']['status']['toolhead']['position'][0]
        y_location = response['result']['status']['toolhead']['position'][1]
        z_location = response['result']['status']['toolhead']['position'][2]
        FilaSen ="1" if  response['result']['status']['filament_switch_sensor fila']['enabled'] else "0"
        e_location = response['result']['status']['toolhead']['position'][3]
        FanSpeed = response['result']['status']['output_pin fan0']['value']
        rapid_cooling_speed = response['result']['status']['output_pin fan2']['value']
        chamber_cooling_speed = response['result']['status']['output_pin fan1']['value']
        print_progress = response['result']['status']['display_status']['progress']
        self.thisdict["state"] = str(state)
        self.thisdict["E1Tem"] = str(int(extruder_tem))
        self.thisdict["E1TarTem"] = str(int(extruder_tar))
        self.thisdict["BedTem"] = str(int(heater_bed_tem))
        self.thisdict["BedTarTem"] = str(int(heater_bed_tar))
        self.thisdict["x_location"] = str("%.3f"%x_location)
        self.thisdict["y_location"] = str("%.3f"%y_location)
        self.thisdict["z_location"] = str("%.3f"%z_location)
        self.thisdict["homed_axes"] = str(homed_axes)
        self.thisdict["FilaSen"] = str(FilaSen)
        self.thisdict["print_progress"] = str("%d"%(print_progress*100)) +"%"
        self.thisdict["FanSpeed"] = str("%d"%(FanSpeed*100)) 
        self.thisdict["rapid_cooling_speed"] = str("%d"%(rapid_cooling_speed*100)) 
        self.thisdict["chamber_cooling_speed"] = str("%d"%(chamber_cooling_speed*100))
        # Logger.log("e",state) 
        if state == "printing":
            self._isPrinting = True
            self._isPause = False
        elif state == "paused":
            self._isPrinting = False
            self._isPause = True
        elif state == "standby":
            self._isPause = False
            self._isPrinting = False
        else:
            self._isPause = False
            self._isPrinting = False
        if self._connect_progress_message != None and not self._get_file_list and not self._get_system_info:
            self._connect_progress_message.setProgress(100)
            self._get_file_list = False
            self._connect_progress_message.hide()
            self._connect_progress_message = None
            self._update_timer.setInterval(3000)
        self.updateRequested.emit()

    def isBusy(self):
        return self._isPrinting or self._isPause 

    def isPrinting(self): 
        return self._isPrinting or self._ischanging

    def isPause(self): 
        return self._isPause

    def printer_file_list_parse(self, response):
        self.sdFiles = []
        for i in response['result']:
            Logger.log("d","Find file :"+i["path"])
            if i["path"].find(".") != -1 and i["path"].find(".") != 0:
                file_name = i["path"][:i["path"].rfind(".")]
                file_type = i["path"][i["path"].rfind(".") + 1:]
            else:
                file_name = i["path"][:i["path"].rfind(" ")]
                file_type = "File"
            file_name = file_name.replace("/","\\")
            # Logger.log("e",file_name)
            # Logger.log("e",file_type)
            self.sdFiles.append('/'.join([file_name, '+'.join([file_type, str(i["size"])])]))
        self.updateFileList.emit()
        if self._connect_progress_message !=None:
            self._connect_progress_message.setProgress(33)
            self._get_file_list = False
        self.setStateConnected.emit()

    def _onRequestError(self, reply: QNetworkReply, error) -> None:
        # Logger.log("e", repr(error))
        Logger.log("e",("There was a network error: {} {}").format(error, reply.errorString() if reply else ""))

        # message = Message(catalog.i18nc("@info:status", "There was a network error: {}").format(reply.errorString()[reply.errorString().find("server replied:")+15:] if reply else ""), 0, False)
        # message.setTitle("QIDI - Error")
        self.error_message.setText(catalog.i18nc("@info:status", "There was a network error: {}").format(reply.errorString()[reply.errorString().find("server replied:")+15:] if reply else ""))
        self.error_message.show()


    def encodeCmd(self,cmd):
        return cmd.encode(self._file_encode, 'ignore')
        
    def decodeCmd(self,cmd):
        return cmd.decode(self._file_encode,'ignore')

    _instance = None
    @classmethod
    def getInstance(cls, *args, **kwargs) -> "MKSConnect":
        if not MKSConnect._instance:
            MKSConnect._instance = cls()
        return MKSConnect._instance