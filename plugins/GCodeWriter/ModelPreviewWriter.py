from QD.Mesh.MeshWriter import MeshWriter
from qidi.Snapshot import Snapshot
from qidi.Utils.Threading import call_on_qt_thread
from QD.Logger import Logger
from QD.Scene.SceneNode import SceneNode #For typing.
from QD.Application import Application
from QD.i18n import i18nCatalog
catalog = i18nCatalog("qidi")
from . import utils

import re
from io import StringIO, BufferedIOBase #To write the g-code to a temporary buffer, and for typing.
from typing import cast, List

class ModelPreviewWriter(MeshWriter):
    def __init__(self):
        super().__init__(add_to_recent_files = False)
        self._global_container_stack = None
        self._snapshot = None

    @call_on_qt_thread
    def write(self,stream: BufferedIOBase, nodes: List[SceneNode], mode = MeshWriter.OutputMode.BinaryMode) -> bool:
        gcode_textio = StringIO() #We have to convert the g-code into bytes.        success = gcode_writer.write(gcode_textio, None)
        self._createSnapshot()
        try:
            w=self._snapshot.width()
        except:
            return False
        result = self.modify(gcode_textio.getvalue())
        stream.write(result)
        Logger.log("i", "ModelPreviewWriter done")
        return True

    def modify(self, in_data):
        self._global_container_stack = Application.getInstance().getGlobalContainerStack()
        if self._global_container_stack:
            container = self._global_container_stack.findContainer({ "board": "*" })
            board = container.getMetaDataEntry("board")
            if board =="MKS":
                model_preview = container.getMetaDataEntry("model_preview")
                if model_preview :
                    Logger.log("d","model_preview size :" + str(model_preview))
                else:
                    model_preview = [[380,380],[210,210]]
                    Logger.log("d","cannot find model_preview , change model_preview size :" + str(model_preview))
                image = utils.take_screenshot()
                temp_in_data =utils.add_screenshot(image, model_preview[0][0], model_preview[0][1], ";gimage:")
                temp_in_data +=utils.add_screenshot(image, model_preview[1][0], model_preview[1][1], ";simage:")
                time_data = self.insert_time_infos(temp_in_data)
            else:
                temp_in_data = self.generate_image_code(self._snapshot)
                temp_in_data += "\n"
                temp_in_data += in_data
                time_data = self.insert_time_infos(temp_in_data)
        else:
            temp_in_data = self.generate_image_code(self._snapshot)
            temp_in_data += "\n"
            temp_in_data += in_data
            time_data = self.insert_time_infos(temp_in_data)
        return time_data

    def insert_time_infos(self, gcode_data):
        return_data=gcode_data
        return return_data

    def _createSnapshot(self, *args):
        Logger.log("i", "Creating qidi thumbnail image ...")
        try:
            self._snapshot = Snapshot.snapshot(width = 300, height = 300)
        except Exception:
            Logger.logException("w", "Failed to create snapshot image")
            self._snapshot = None

    def generate_image_code(self, image,startX=0, startY=0, endX=300, endY=300):
        MAX_PIC_WIDTH_HEIGHT = 320
        width = image.width()
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
            scale = MAX_PIC_WIDTH_HEIGHT / max_edge
        if scale != 1.0:
            width = int(width * scale)
            height = int(height * scale)
            startX = int(startX * scale)
            startY = int(startY * scale)
            endX = int(endX * scale)
            endY = int(endY * scale)
            image = image.scaled(width, height)
        res_list = []
        for i in range(startY, endY):
            for j in range(startX, endX):
                res_list.append(image.pixel(j, i))

        index_pixel = 0
        pixel_num = 0
        pixel_data = ''
        pixel_string=""
        pixel_string+=('M4010 X%d Y%d\n' % (endX - startX, endY - startY))
        last_color = -1
        mask = 32
        unmask = ~mask
        same_pixel = 1
        color = 0
        for j in res_list:
            #Logger.log("e",j)
            a = j >> 24 & 255
            if not a:
                r = g = b = 255
            else:
                r = j >> 16 & 255
                g = j >> 8 & 255
                b = j & 255
            color = (r >> 3 << 11 | g >> 2 << 5 | b >> 3) & unmask
            if last_color == -1:
                last_color = color
            elif last_color == color and same_pixel < 4095:
                same_pixel += 1
            elif same_pixel >= 2:
                pixel_data += '%04x' % (last_color | mask)
                pixel_data += '%04x' % (12288 | same_pixel)
                pixel_num += same_pixel
                last_color = color
                same_pixel = 1
            else:
                pixel_data += '%04x' % last_color
                last_color = color
                pixel_num += 1
            if len(pixel_data) >= 180:
                pixel_string+=("M4010 I%d T%d '%s'\n" % (index_pixel, pixel_num, pixel_data))
                pixel_data = ''
                index_pixel += pixel_num
                pixel_num = 0

        if same_pixel >= 2:
            pixel_data += '%04x' % (last_color | mask)
            pixel_data += '%04x' % (12288 | same_pixel)
            pixel_num += same_pixel
            last_color = color
            same_pixel = 1
        else:
            pixel_data += '%04x' % last_color
            last_color = color
            pixel_num += 1
        pixel_string+=("M4010 I%d T%d '%s'\n" % (index_pixel, pixel_num, pixel_data))
        return pixel_string