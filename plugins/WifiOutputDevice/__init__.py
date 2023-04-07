from . import WifiOutputDevicePlugin


def getMetaData():
    return {
    }

def register(app):
    return { "output_device": WifiOutputDevicePlugin.WifiOutputDevicePlugin()}
