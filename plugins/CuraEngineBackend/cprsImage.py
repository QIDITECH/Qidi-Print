# -*- coding:gbk -*-
#截图合成数据的接口
import time
import traceback
from PyQt5.QtWidgets import QApplication

from UM.View.GL.OpenGL import OpenGL
import threading



#检测图片的有效区域
#输入是个QImage
def detectImageValidRange(image):
    # image.save('detectImage.png')
    EXPAND_PIXEL = 25                   #往四周扩大的像素个数
    FIX_WIDTH_HEIGTH_RATIO = True       #约束比例为1:1

    width =  image.width()
    height = image.height()
    startX = 99999999
    startY = 99999999
    endX = 0
    endY = 0


    for i in range(height):
        validPixelDetect = False
        for j in range(width):
            pix = image.pixel(j, i)
            if(pix > 0 and pix != 0xffffffff):
                validPixelDetect = True
                if(startX > j):
                    startX = j
                if(endX < j):
                    endX = j
        if(validPixelDetect):
            if (startY > i):
                startY = i
            if (endY < i):
                endY = i

    if (FIX_WIDTH_HEIGTH_RATIO and endX >= startX):          #在至少找到一个有交像素的前题下处理
        if(endY - startY)  > (endX - startX):
            diff = ((endY - startY)  - (endX - startX))/2
            startX -= diff
            endX += diff
        else:
            diff = ((endX - startX) - (endY - startY))/2
            startY -= diff
            endY += diff

    ###############扩边#######################
    startX -= EXPAND_PIXEL
    endX += EXPAND_PIXEL
    startY -= EXPAND_PIXEL
    endY += EXPAND_PIXEL


    if(startX < 0):
        startX = 0
    if(endX >= width):
        endX = width - 1

    if (startY < 0):
        startY = 0
    if (endY >= height):
        endY = height - 1

    if(endX < startX):
        startX = endX
    if (endY < startY):
        startY = endY
    print("pixel range:",startX,'-',endX,'  ',startY,'-',endY)
    return int(startX),int(startY),int(endX),int(endY)


#将图片有效区域转换成gcode
#输入是个QImage
def genImageGcode(image, startX = 0,startY = 0,endX = 100,endY = 100):
    MAX_PIC_WIDTH_HEIGHT = 320                  #最大的像素不要超过这个，因为屏幕的分辨率目前最高只480*320,太高的分辨率并无太多实质意义，
    # image.save('genImageGcode.png')
    width =  image.width()
    height = image.height()

    if endX > width:
        endX = width
    if endY > height:
        endY = height

    scale = 1.0

    max_edge = endY - startY
    if max_edge < endX - startX:
        max_edge = endX - startX
    if max_edge > MAX_PIC_WIDTH_HEIGHT:
        scale = MAX_PIC_WIDTH_HEIGHT/max_edge

    if scale != 1.0:
        width = int(width*scale)
        height = int(height * scale)
        startX = int(startX * scale)
        startY = int(startY * scale)
        endX = int(endX * scale)
        endY = int(endY * scale)

        image = image.scaled(width, height)


    res_list = []
    print('StartY:',startY," endY:",endY)
    for i in range(startY,endY):
        for j in range(startX,endX):
            res_list.append(image.pixel(j, i))


    index_pixel = 0
    pixel_num = 0
    pixel_data = ""
    pixel_string = ""
    pixel_string += "M4010 X%d Y%d\n" % (endX - startX, endY - startY)
    last_color = -1
    mask = 1 << 5
    unmask = ~mask
    same_pixel = 1
    color = 0
    for j in res_list:
            a = (j>>24)&0xff
            if not a:               #背景透明
                r = g = b = 0xff
            else:
                r = (j >> 16) & 0xff
                g = (j >> 8) & 0xff
                b = (j) & 0xff
            color = ((((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3))) & unmask
            # color = (2*((j[0] >> 4 << 12)|(j[1] >> 3 << 6)|(j[2] >> 4 << 1 )))&unmask
            if (last_color == -1):
                last_color = color
            elif last_color == color and same_pixel < 0xfff:
                same_pixel += 1
            else:
                if (same_pixel >= 2):
                    pixel_data += "%04x" % (last_color | mask)  # value max is 127
                    pixel_data += "%04x" % (0x3000 | same_pixel)
                    pixel_num += same_pixel
                    last_color = color
                    same_pixel = 1
                else:
                    pixel_data += "%04x" % (last_color)
                    last_color = color
                    pixel_num += 1

            if len(pixel_data) >= 180:
                pixel_string += "M4010 I%d T%d '%s'\n" % (index_pixel, pixel_num, pixel_data)
                pixel_data = ""
                index_pixel += pixel_num
                pixel_num = 0

    if (same_pixel >= 2):
        pixel_data += "%04x" % (last_color | mask)  # value max is 127
        pixel_data += "%04x" % (0x3000 | same_pixel)
        pixel_num += same_pixel
        last_color = color
        same_pixel = 1
    else:
        pixel_data += "%04x" % (last_color)
        last_color = color
        pixel_num += 1
    pixel_string += "M4010 I%d T%d '%s'\n" % (index_pixel, pixel_num, pixel_data)
    return pixel_string


