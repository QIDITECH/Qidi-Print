from qidi.QIDIApplication import QIDIApplication
from QD.Math.Vector import Vector
from QD.Application import Application
from QD.Scene.Iterator.DepthFirstIterator import DepthFirstIterator
from qidi.Snapshot import Snapshot
from PyQt5.QtCore import Qt
import os
from ctypes import *
from QD.Logger import Logger
import binascii
import platform
from QD.Platform import Platform
from array import array
from QD.i18n import i18nCatalog
from QD.Message import Message
import random
from . import PicEncode1
def getRect():
    left = None
    front = None
    right = None
    back = None
    for node in DepthFirstIterator(Application.getInstance().getController().getScene().getRoot()):
        if node.getBoundingBoxMesh():
            if not left or node.getBoundingBox().left < left:
                left = node.getBoundingBox().left
            if not right or node.getBoundingBox().right > right:
                right = node.getBoundingBox().right
            if not front or node.getBoundingBox().front > front:
                front = node.getBoundingBox().front
            if not back or node.getBoundingBox().back < back:
                back = node.getBoundingBox().back
    if not (left and front and right and back):
        return 0
    result = max((right - left), (front - back))
    return result


# def add_screenshot(img, width, height, img_type):
#     result = ""
#     b_image = img.scaled(width, height, Qt.KeepAspectRatio)
#     b_image.save(os.path.abspath("")+"\\test_"+str(width)+"_.png")
#     img.save(os.path.abspath("") + "\\testb_" + str(width) + "_.png")
#     img_size = b_image.size()
#     result += img_type
#     datasize = 0
#     for i in range(img_size.height()):
#         for j in range(img_size.width()):
#             pixel_color = b_image.pixelColor(j, i)
#             r = pixel_color.red() >> 3
#             g = pixel_color.green() >> 2
#             b = pixel_color.blue() >> 3
#             rgb = (r << 11) | (g << 5) | b
#             strHex = "%x" % rgb
#             if len(strHex) == 3:
#                 strHex = '0' + strHex[0:3]
#             elif len(strHex) == 2:
#                 strHex = '00' + strHex[0:2]
#             elif len(strHex) == 1:
#                 strHex = '000' + strHex[0:1]
#             if strHex[2:4] != '':
#                 result += strHex[2:4]
#                 datasize += 2
#             if strHex[0:2] != '':
#                 result += strHex[0:2]
#                 datasize += 2
#             if datasize >= 50:
#                 datasize = 0
#         # if i != img_size.height() - 1:
#         result += '\rM10086 ;'
#         if i == img_size.height() - 1:
#             result += "\r"
#     return result

def add_screenshot(img, width, height, img_type):
    # Logger.log("d", "add_screenshot." +  platform.system())
    # if Platform.isOSX():
        # pDll = CDLL(os.path.join(os.path.dirname(__file__), "libColPic.dylib"))
    # elif Platform.isLinux():
        # pDll = CDLL(os.path.join(os.path.dirname(__file__), "libColPic.so"))
    # else:
        # pDll = CDLL(os.path.join(os.path.dirname(__file__), "ColPic_X64.dll"))

    result = ""
    b_image = img.scaled(width, height, Qt.KeepAspectRatio)
    # b_image.save(os.path.abspath("")+"\\test_py_"+str(width)+"_.png")
    # img.save(os.path.abspath("") + "\\testb_" + str(width) + "_.png")
    img_size = b_image.size()
    color16 = array('H')
    fromcolor16 = array('H')
    try:
        for i in range(img_size.height()):
            for j in range(img_size.width()):
                pixel_color = b_image.pixelColor(j, i)
                r = pixel_color.red() >> 3
                g = pixel_color.green() >> 2
                b = pixel_color.blue() >> 3
                a = pixel_color.alpha()
                if a == 0:
                    r = 239 >> 3
                    g = 243 >> 2
                    b = 247 >> 3
                rgb = (r << 11) | (g << 5) | b
                color16.append(rgb)
        fromcolor16 = color16.tobytes()
        # outputdata = array('B',[0]*img_size.height()*img_size.width()).tobytes()
        outputdata = bytearray(img_size.height()*img_size.width()*10)
        # resultInt = pDll.ColPic3EncodeStr(fromcolor16, img_size.height(), img_size.width(), outputdata, img_size.height()*img_size.width(), 1024)
        resultInt = PicEncode1.ColPic_EncodeStr(color16, img_size.height(), img_size.width(), outputdata, img_size.height()*img_size.width()*10, 1024)
        data0 = str(outputdata).replace('\\x00', '')
        astr = ''
        for i in range(len(outputdata)):
            if (outputdata[i] != 0):
                astr += chr(outputdata[i])
        os.remove(os.path.abspath("")+"\\cut_image_.png")
    except Exception as e:
        Logger.log("d", "Exception == " + str(e))
    
    # return result + '\n'
    return  '\n' + img_type + astr + '\n' + '\n'

def take_screenshot():
    cut_image = Snapshot.snapshot(width = 900, height = 900)
    cut_image.save(os.path.abspath("")+"\\cut_image_.png")
    return cut_image

#RGB转16进制
def rgbtohex(r, g, b):
    
    text = '#' + ''.join([hex(i)[-2:].replace('x','0') for i in list(map(int, [r, g, b]))])
    
    return text
