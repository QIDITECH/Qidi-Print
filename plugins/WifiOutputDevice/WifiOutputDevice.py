import os.path

from QD.Application import Application
from QD.Logger import Logger
from QD.Message import Message
from QD.FileHandler.WriteFileJob import WriteFileJob
from QD.FileHandler.FileWriter import FileWriter
from QD.Scene.Iterator.BreadthFirstIterator import BreadthFirstIterator
from QD.OutputDevice.OutputDevice import OutputDevice
from QD.OutputDevice import OutputDeviceError
from qidi.Wifi.WifiSend import WifiSend
from qidi.Wifi.CBDConnect import CBDConnect
from qidi.Wifi.MKSConnect import MKSConnect

from QD.Resources import  Resources

from QD.i18n import i18nCatalog
catalog = i18nCatalog("qidi")

class WifiOutputDevice(OutputDevice):
    def __init__(self, device_id, device_name):
        super().__init__(device_id)

        self.setName(device_name)
        self.setShortDescription(catalog.i18nc("@action:button Preceded by 'Ready to'.", "Send to WIFI"))
        self.setDescription(catalog.i18nc("@item:inlistbox", "Send to WIFI {0}").format(device_name))
        self.setIconName("send_to_wifi")
        self.setPriority(2)
        self.file_name = ""
        self._writing = False
        self._stream = None

    def requestWrite(self, nodes, file_name = None, filter_by_machine = False, file_handler = None, **kwargs):
        self.file_name = file_name
        if self._writing:
            raise OutputDeviceError.DeviceBusyError()
        filter_by_machine = True # This plugin is intended to be used by machine (regardless of what it was told to do)

        # Formats supported by this application (File types that we can actually write)
        if file_handler:
            file_formats = file_handler.getSupportedFileTypesWrite()
        else:
            file_formats = Application.getInstance().getMeshFileHandler().getSupportedFileTypesWrite()

        if filter_by_machine:
            container = Application.getInstance().getGlobalContainerStack().findContainer({"file_formats": "*"})

            # Create a list from supported file formats string
            machine_file_formats = [file_type.strip() for file_type in container.getMetaDataEntry("file_formats").split(";")]

            # Take the intersection between file_formats and machine_file_formats.
            format_by_mimetype = {format["mime_type"]: format for format in file_formats}
            file_formats = [format_by_mimetype[mimetype] for mimetype in machine_file_formats if mimetype in format_by_mimetype]  # Keep them ordered according to the preference in machine_file_formats.

        if len(file_formats) == 0:
            Logger.log("e", "There are no file formats available to write with!")
            raise OutputDeviceError.WriteRequestFailedError(catalog.i18nc("@info:status", "There are no file formats available to write with!"))
        preferred_format = file_formats[0]

        # Just take the first file format available.
        if file_handler is not None:
            writer = file_handler.getWriterByMimeType(preferred_format["mime_type"])
        else:
            writer = Application.getInstance().getMeshFileHandler().getWriterByMimeType(preferred_format["mime_type"])

        extension = preferred_format["extension"]

        temp_file_name = Resources.getStoragePath(Resources.Resources, "data.gcode")
        try:
            Logger.log("d", "Writing to %s", file_name)
            # Using buffering greatly reduces the write time for many lines of gcode
            if preferred_format["mode"] == FileWriter.OutputMode.TextMode:
                self._stream = open(temp_file_name, "wt", buffering = 1, encoding = "utf-8")
            else: #Binary mode.
                self._stream = open(temp_file_name, "wb", buffering = 1)
            job = WriteFileJob(writer, self._stream, nodes, preferred_format["mode"])
            job.setFileName(temp_file_name)
            # job.progress.connect(self._onProgress)
            job.finished.connect(self._onFinished)

            # message = Message(catalog.i18nc("@info:progress Don't translate the XML tags <filename>!", "Saving to Removable Drive <filename>{0}</filename>").format(self.getName()), 0, False, -1, catalog.i18nc("@info:title", "Saving"))
            # message.show()

            self.writeStarted.emit(self)

            # job.setMessage(message)
            self._writing = True
            job.start()
        except PermissionError as e:
            Logger.log("e", "Permission denied when trying to write to %s: %s", file_name, str(e))
            raise OutputDeviceError.PermissionDeniedError(catalog.i18nc("@info:status Don't translate the XML tags <filename> or <message>!", "Could not save to <filename>{0}</filename>: <message>{1}</message>").format(file_name, str(e))) from e
        except OSError as e:
            Logger.log("e", "Operating system would not let us write to %s: %s", file_name, str(e))
            raise OutputDeviceError.WriteRequestFailedError(catalog.i18nc("@info:status Don't translate the XML tags <filename> or <message>!", "Could not save to <filename>{0}</filename>: <message>{1}</message>").format(file_name, str(e))) from e
        # self._stream.close()
        # wifisend = WifiSend.getInstance()
        # cbdConnect = CBDConnect.getInstance()
        # mksConnect = MKSConnect.getInstance()
        # firmware_manufacturers = wifisend.currentDeviceIP[-3:]
        # if firmware_manufacturers == "CBD":
            # cbdConnect.startSending(self.file_name, wifisend.currentDeviceIP)
        # else:
            # mksConnect.uploadfunc(self.file_name, wifisend.currentDeviceIP)
        
    def _onFinished(self, job):
        if self._stream:
            # Explicitly closing the stream flushes the write-buffer
            try:
                self._stream.close()
                self._stream = None
            except:
                Logger.logException("w", "An execption occured while trying to write to removable drive.")
                message = Message(catalog.i18nc("@info:status", "Could not save to removable drive {0}: {1}").format(self.getName(),str(job.getError())),
                                  title = catalog.i18nc("@info:title", "Error"))
                message.show()
                self.writeError.emit(self)
                return

        self._writing = False
        self.writeFinished.emit(self)
        if job.getResult():
            self.writeSuccess.emit(self)
        else:
            message = Message(catalog.i18nc("@info:status", "Could not save data.gcode").format(self.getName(), str(job.getError())), title = catalog.i18nc("@info:title", "Warning"))
            message.show()
            self.writeError.emit(self)
        job.getStream().close()
        wifisend = WifiSend.getInstance()
        cbdConnect = CBDConnect.getInstance()
        mksConnect = MKSConnect.getInstance()
        firmware_manufacturers = wifisend.currentDeviceIP[-3:]
        if firmware_manufacturers == "CBD":
            cbdConnect.startSending(self.file_name, wifisend.currentDeviceIP)
        else:
            mksConnect.uploadfunc(self.file_name, wifisend.currentDeviceIP)
        # job.getStream().close()
