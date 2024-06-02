from ctypes import CDLL, CFUNCTYPE, c_int, c_char_p
from typing import Callable

class Peripherals:
  def __init__(self):
    self.libperipherals = CDLL('lib/libperipherals.dylib')

  def init_event_loop(self):
    self.libperipherals.initEventLoop()

  def create_key_listener(self, callback: Callable[[str, int], None]):
    self.key_listener = CFUNCTYPE(None, c_char_p, c_int)(callback)
    self.libperipherals.createKeyListener(self.key_listener)

peripherals = Peripherals()

peripherals.create_key_listener(lambda event, key: print(event.decode('utf8'), key))
peripherals.init_event_loop()
