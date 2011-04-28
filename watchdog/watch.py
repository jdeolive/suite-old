import time
from watchdog import Watchdog

while True:
  dog = Watchdog('watchdog.ini')
  dog.ping()
  time.sleep(10)

