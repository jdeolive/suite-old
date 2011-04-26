import time
from watchdog import Watchdog

while True:
  dog = Watchdog('watchdog.conf')
  dog.ping()
  time.sleep(5)

