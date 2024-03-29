
from PyQt5.QtCore import Qt, QCoreApplication, QTimer
from PyQt5.QtGui import QPixmap, QColor, QFont, QPen, QPainter
from PyQt5.QtWidgets import QSplashScreen

from QD.Resources import Resources
from QD.Application import Application
from qidi import ApplicationMetadata

import time

class QIDISplashScreen(QSplashScreen):
    def __init__(self):
        super().__init__()
        self._scale = 0.7
        self._version_y_offset = 0  # when extra visual elements are in the background image, move version text down

        if ApplicationMetadata.IsEnterpriseVersion:
            splash_image = QPixmap(Resources.getPath(Resources.Images, "qidi_enterprise.png"))
            self._version_y_offset = 26
        else:
            splash_image = QPixmap(Resources.getPath(Resources.Images, "qidi.png"))

        self.setPixmap(splash_image)

        self._current_message = ""
        self._current_rate = 10
        self._loading_image_rotation_angle = 0

        self._to_stop = False
        self._change_timer = QTimer()
        self._change_timer.setInterval(50)
        self._change_timer.setSingleShot(False)
        self._change_timer.timeout.connect(self.updateLoadingImage)

        self._last_update_time = None

    def show(self):
        super().show()
        self._last_update_time = time.time()
        self._change_timer.start()

    def updateLoadingImage(self):
        if self._to_stop:
            return
        time_since_last_update = time.time() - self._last_update_time
        self._last_update_time = time.time()
        # Since we don't know how much time actually passed, check how many intervals of 50 we had.
        self._loading_image_rotation_angle -= 10 * (time_since_last_update * 1000 / 50)
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

        # Draw version text
        font = QFont()  # Using system-default font here
        font.setPixelSize(24)
        painter.setFont(font)
        painter.drawText(95, 50 + self._version_y_offset, round(330 * self._scale), round(230 * self._scale), Qt.AlignLeft | Qt.AlignTop, "V" + version[0])
        if len(version) > 1:
            font.setPixelSize(16)
            painter.setFont(font)
            painter.setPen(QColor(0, 0, 0, 0))
            painter.drawText(247, 105 + self._version_y_offset, round(330 * self._scale), round(255 * self._scale), Qt.AlignLeft | Qt.AlignTop, version[1])
        pen = QPen()
        pen.setWidth(10)
        pen.setColor(QColor(65, 155, 249, 255))
        painter.setPen(pen)
        painter.drawLine(0, 295, self._current_rate, 295)

        # Draw message text
        if self._current_message:
            font = QFont()  # Using system-default font here
            font.setPixelSize(13)
            pen = QPen()
            pen.setColor(QColor(0, 0, 0 ,255))
            painter.setPen(pen)
            painter.setFont(font)
            painter.drawText(190, 250, 250, 64, Qt.AlignLeft | Qt.AlignVCenter , self._current_message)

        painter.restore()
        super().drawContents(painter)

    def showMessage(self, message, *args, **kwargs):
        if self._to_stop:
            return

        self._current_message = message
        self._current_rate = self._current_rate + 40
        self.messageChanged.emit(message)
        QCoreApplication.flush()
        self.repaint()

    def close(self):
        # set stop flags
        self._to_stop = True
        self._change_timer.stop()
        super().close()
