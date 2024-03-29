# Copyright (c) 2015 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from PyQt5.QtCore import Qt, QEvent, QObject
from PyQt5.QtGui import QKeyEvent

from QD.InputDevice import InputDevice
from QD.Event import KeyEvent


class QtKeyDevice(InputDevice):
    """In between class that converts QT key events to QDTECH events."""

    def __init__(self):
        super().__init__()

    def handleEvent(self, event):
        if event.type() == QEvent.KeyPress:
            e = KeyEvent(KeyEvent.KeyPressEvent, self._qtKeyToQDKey(event.key()))
            self.event.emit(e)
        elif event.type() == QEvent.KeyRelease:
            e = KeyEvent(KeyEvent.KeyReleaseEvent, self._qtKeyToQDKey(event.key()))
            self.event.emit(e)

    def _qtKeyToQDKey(self, key):
        if key == Qt.Key_Shift:
            return KeyEvent.ShiftKey
        elif key == Qt.Key_Control:
            return KeyEvent.ControlKey
        elif key == Qt.Key_Alt:
            return KeyEvent.AltKey
        elif key == Qt.Key_Space:
            return KeyEvent.SpaceKey
        elif key == Qt.Key_Meta:
            return KeyEvent.MetaKey
        elif key == Qt.Key_Enter or key == Qt.Key_Return:
            return KeyEvent.EnterKey
        elif key == Qt.Key_Up:
            return KeyEvent.UpKey
        elif key == Qt.Key_Down:
            return KeyEvent.DownKey
        elif key == Qt.Key_Left:
            return KeyEvent.LeftKey
        elif key == Qt.Key_Right:
            return KeyEvent.RightKey
        elif key == Qt.Key_Minus:
            return KeyEvent.MinusKey
        elif key == Qt.Key_Underscore:
            return KeyEvent.UnderscoreKey
        elif key == Qt.Key_Plus:
            return KeyEvent.PlusKey
        elif key == Qt.Key_Equal:
            return KeyEvent.EqualKey

        return key
