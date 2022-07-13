# Copyright (c) 2017 Ultimaker B.V.
# Uranium is released under the terms of the LGPLv3 or higher.

from PyQt5.QtCore import Qt, QCoreApplication, QTimer
from PyQt5.QtGui import QPixmap, QColor, QFont, QPen, QPainter
from PyQt5.QtWidgets import QSplashScreen

from UM.Resources import Resources
from UM.Application import Application


class CuraSplashScreen(QSplashScreen):
    def __init__(self):
        super().__init__()
        self._scale = 0.7

        splash_image = QPixmap(Resources.getPath(Resources.Images, "qidi.png"))
        self.setPixmap(splash_image)

        self._current_message = ""
        self._current_rate = 32

        self._loading_image_rotation_angle = 0

        self._to_stop = False
        self._change_timer = QTimer()
        self._change_timer.setInterval(50)
        self._change_timer.setSingleShot(False)
        self._change_timer.timeout.connect(self.updateLoadingImage)

    def show(self):
        super().show()
        self._change_timer.start()

    def updateLoadingImage(self):
        if self._to_stop:
            return

        self._loading_image_rotation_angle -= 10
        self.repaint()

    # Override the mousePressEvent so the splashscreen doesn't disappear when clicked
    def mousePressEvent(self, mouse_event):
        pass

    def drawContents(self, painter):
        if self._to_stop:
            return

        painter.save()
        painter.setPen(QColor(0, 0, 0, 255))
        painter.setRenderHint(QPainter.Antialiasing)
        painter.setRenderHint(QPainter.Antialiasing, True)

        version = Application.getInstance().getVersion().split("-")
        buildtype = Application.getInstance().getBuildType()
        if buildtype:
            version[0] += " (%s)" % buildtype

        # draw version text
        font = QFont()  # Using system-default font here
        font.setPixelSize(20)
        painter.setFont(font)
        painter.drawText(160, 80, 330 * self._scale, 230 * self._scale, Qt.AlignLeft | Qt.AlignTop, "V" + version[0])
        if len(version) > 1:
            font.setPixelSize(16)
            painter.setFont(font)
            painter.setPen(QColor(200, 200, 200, 255))
            painter.drawText(247, 105, 330 * self._scale, 255 * self._scale, Qt.AlignLeft | Qt.AlignTop, version[1])
        painter.setPen(QColor(0, 0, 0, 255))

        # draw the loading Line
        pen = QPen()
        pen.setWidth(10)
        pen.setColor(QColor(205, 205, 205, 255))
        painter.setPen(pen)
        painter.drawLine(32, 324, 522, 324)
        
        pen = QPen()
        pen.setWidth(10)
        pen.setColor(QColor(65, 155, 249, 255))
        painter.setPen(pen)
        painter.drawLine(32, 324, self._current_rate, 324)

        # draw message text
        if self._current_message:
            font = QFont()  # Using system-default font here
            font.setFamily("Microsoft yahei")
            font.setPixelSize(14)
            pen = QPen()
            pen.setColor(QColor(0, 0, 0, 255))
            painter.setPen(pen)
            painter.setFont(font)
            painter.drawText(32, 272, 522, 64,
                             Qt.AlignHCenter | Qt.AlignVCenter,
                             self._current_message)

        painter.restore()
        super().drawContents(painter)

    def showMessage(self, message, *args, **kwargs):
        if self._to_stop:
            return

        self._current_message = message
        self._current_rate = self._current_rate + 70
        self.messageChanged.emit(message)
        QCoreApplication.flush()
        self.repaint()

    def close(self):
        # set stop flags
        self._to_stop = True
        self._change_timer.stop()
        super().close()
