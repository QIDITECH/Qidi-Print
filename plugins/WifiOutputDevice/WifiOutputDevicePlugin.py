import threading
import time
from QD.Logger import Logger
from QD.OutputDevice.OutputDevicePlugin import OutputDevicePlugin
from . import WifiOutputDevice
from qidi.Wifi.WifiSend import WifiSend
from QD.i18n import i18nCatalog
catalog = i18nCatalog("qidi")

class WifiOutputDevicePlugin(OutputDevicePlugin):
    def __init__(self):
        super().__init__()

        self._update_thread = threading.Thread(target = self._updateThread)
        self._update_thread.setDaemon(True)
        self._check_updates = True

    def start(self):
        wifisend = WifiSend.getInstance()
        self._update_thread.start()

    def stop(self):
        self._check_updates = False
        self._update_thread.join()

    def _updateThread(self):
        addtime = False
        while self._check_updates:
            wifisend = WifiSend.getInstance()
            result = wifisend.FullNameIPList
            if (str(result).find("/") != -1) :
                if not addtime :
                    self.getOutputDeviceManager().addOutputDevice(WifiOutputDevice.WifiOutputDevice('', ''))
                    addtime = True
            else:
                self.getOutputDeviceManager().removeOutputDevice('')
                addtime = False
            time.sleep(5)

