import os, logging, subprocess, sys, tempfile, time, urllib2
from datetime import datetime
from xml import sax
from ConfigParser import ConfigParser

date_format = '%Y%m%dT%H:%M:%S'

class Watchdog(object):

  def __init__(self, cfgfile):
    self.conf = self._read_conf(cfgfile)
    self.name = self._get_name()
    self.pid = self._get_pid()
    self._configure_logging()

  def ping(self):
    # check if we are enabled
    if not eval(self.conf.get('main', 'enabled')):
      logging.info('Watchdog disabled, exiting')
      return 0

    #lockfile = '/var/run/%s.lock' % self.name
    lockfile = '%s.lock' % self.name

    # check for another instance of the watchdog running
    if os.path.exists(lockfile):
      logging.info('Watchdog lock file %s exists, exiting' % lockfile)
      return 0

    # create the lock file
    open(lockfile, 'w').close()

    #  check if the process is running
    try:
      for check in self.load_checks():
        try:
          if not check.ok():
            # dump out the content
            check.dump()

            # restart
            logging.warning('Process %d NOT ok. Attempting to restart' % (self.pid))
            return self.restart()
        finally:
           check.close()

      logging.info('Process %d ok' % (self.pid))
    finally:
      # remove the lock file       
      os.remove(lockfile)

  def restart(self):
    startup = self.conf.get('main', 'start').split(' ')
    shutdown = self.conf.get('main', 'stop').split(' ')

    # first attempt to shut down cleanly
    subprocess.call(shutdown)    
    if self._check_pid():
      # could not shut down cleanly
      logging.warning('%d did not stop cleanly, killing manually' % self.pid)

      # send a "nice" kill signal
      subprocess.call(['kill', str(self.pid)])

      if self._check_pid():
        # kill -9
        subprocess.call(['kill', '-9', str(self.pid)])
    
        if self._check_pid():
          raise Exception('Unable to kill %d' % self.pid)

    # remove the pidfile
    pidfile = self.conf.get('main', 'pidfile')
    if os.path.exists(pidfile):
      logging.info('Removing pidfile %s' % pidfile)
      os.remove(pidfile)
     

    # start again
    logging.info('Restarting process')
    out = open('/dev/null', 'w')

    for x in range(2):
      subprocess.Popen(startup, stdout=out, stderr=out, 
        cwd=os.path.dirname(startup[0]))

      # give the new process some time to start
      time.sleep(5)

      # read pid from pidfile
      try:
        pid = self._get_pid()
        logging.info('Checking for new pid %d' % pid)
        if self._check_pid(3, pid):
          break 
        logging.warning('New pid %d not running' % pid)
      except:
        logging.exception()
        pass

      logging.info('Process restart failed, trying again')

    if self._check_pid(1, pid):
      logging.info('Process restarted with pid %d' % pid)
    else:
      logging.warning('Unable to restart process')
      raise Exception('Unable to restart process')

    if eval(self.conf.get('main', 'update_pid')):
      f = open(self.conf.get('main', 'pidfile'), 'w')      
      f.write(str(pid))
      f.close()


    # send notification 
    if eval(self.conf.get('main', 'email_notify')):
      self.notify_restart()

  def notify_restart(self):
    # check first the timestamp of the last email send
    now = datetime.now()
    timestamp = os.path.join(tempfile.gettempdir(), '%s.timestamp' % self.name)
    try: 
      tsf = open(timestamp) 
      last_sent = datetime.strptime(tsf.read(), date_format)
      tsf.close()
    except:
      last_sent = None

    spam_int = int(self.conf.get('email', 'spam_interval')) 
    if not last_sent or (now - last_sent).seconds / 60 > spam_int:
      logging.info('Sending email notification of restart') 
      self._send_notify(now)
    else:
      logging.info('Not sending email notification, last sent at %s' % str(last_sent))

    # update the timestamp regardless
    tsf = open(timestamp, 'w') 
    tsf.write(now.strftime(date_format))
    tsf.close()

  def _send_notify(self, timestamp):
    import smtplib, socket
    from email.mime.text import MIMEText
    from email.mime.multipart import MIMEMultipart

    smtp_host = self.conf.get('email', 'smtp_host')
    smtp_port = self.conf.get('email', 'smtp_port')

    try:
      if eval(self.conf.get('email', 'smtp_ssl')):
        server = smtplib.SMTP_SSL(smtp_host, smtp_port)
      else:
        server = smtplib.SMTP(smtp_host, smtp_port)

      server.login(self.conf.get('email', 'username'), 
        self.conf.get('email', 'password'))


      msg = MIMEMultipart()
      hostname = subprocess.Popen(['hostname'], stdout=subprocess.PIPE).communicate()
      msg['Subject'] = '%s on %s restarted at %s' % (self.name, hostname[0], str(timestamp))

      # attach the server log
      att = MIMEText(self._read_logfile(self.conf.get('main', 'server_log')))
      att.add_header('Content-Disposition', 'attachment; filename="server_log.txt"')
      msg.attach(att)

      # attach the watchdog log
      att = MIMEText(self._read_logfile(self.conf.get('logging','filename'), 100))
      att.add_header('Content-Disposition', 'attachment; filename="watchdog_log.txt"')
      msg.attach(att)

      from_addr = self.conf.get('email', 'from_addr')
      to_addr = self.conf.get('email', 'to_addr')

      server.sendmail(from_addr, [to_addr], msg.as_string())
      server.close()
    except Exception:
      logging.exception('Email notification of restart failed')

  def load_checks(self):
    # load all the checks
    checks = [PidCheck(self.pid)]
    base = self.conf.get('net', 'url')
    for check in self.conf.get('main', 'checks').split(','):
      if len(check.strip()) > 0:
        url = base + self.conf.get(check, 'path')
        checks.append(RequestCheck(url, self.conf.items(check)))
        
    # TODO: check the java heap
    return checks 

  def _check_pid(self, n=10, pid=None):
    pid = pid if pid else self.pid
    for i in range(n):
      if not subprocess.call(['ps', str(pid)], stdout=open('/dev/null', 'w')):
        time.sleep(1)
      else:
        return False
      
    return True

  def _read_conf(self, cfgfile):
    conf = ConfigParser()
    conf.read(cfgfile)
    return conf

  def _get_name(self):
    return self.conf.get('main', 'name')

  def _get_pid(self):
    pidfile = self.conf.get('main', 'pidfile')
    if not os.path.exists(pidfile): 
      raise Exception('PID file %s does not exist' % pidfile)

    pidfile = open(pidfile) 
    try:
      return int(pidfile.readline()) 
    finally: 
      pidfile.close()

  def _configure_logging(self):
    logging.basicConfig(filename=self.conf.get('logging', 'filename'), 
       level=logging.__dict__[self.conf.get('logging', 'level')],
       format='%(asctime)s %(message)s')

  def _read_logfile(self, logfile, n=500):
    if logfile and os.path.exists(logfile):
      logf = open(logfile)
      lines = ''.join(self._tail_file(logf, n))
      logf.close()
    else:
      lines = ''
    return lines
  
  def _tail_file(self, file, n):
    file.seek(0, 2)                         #go to end of file
    bytes_in_file = file.tell()             
    lines_found, total_bytes_scanned = 0, 0
    while n+1 > lines_found and bytes_in_file > total_bytes_scanned: 
        byte_block = min(1024, bytes_in_file-total_bytes_scanned)
        file.seek(-(byte_block+total_bytes_scanned), 2)
        total_bytes_scanned += byte_block
        lines_found += file.read(1024).count('\n')
    file.seek(-total_bytes_scanned, 2)
    line_list = list(file.readlines())
    return line_list[-n:]

class PidCheck(object):
   def __init__(self, pid):
     self.pid = pid

   def ok(self):
     if subprocess.call(['ps', str(self.pid)], stdout=open('/dev/null', 'w')):
       logging.warning('Process %d is not running' % self.pid)      
       return False
     else:
       logging.info('Process %d is running' % self.pid)    
       return True 

   def dump(self):
     pass

   def close(self):
     pass

class RequestCheck(object):

   def __init__(self, url, conf):
     self.url = url
     self.conf = self._dict(conf)

   def ok(self):
     logging.warning('Checking url %s' % self.url)
     for x in range(0, 3): 
       try:
         self.response = urllib2.urlopen(self.url, timeout=10)
         if self.do_check():
           return True
         
         # pause before trying agaain 
         logging.warning('Check [%s] failed, retrying %d' % (self.url, x))
         time.sleep(2)
       except Exception:
         logging.exception('Failure connecting to %s' % self.url)

     return False 

   def do_check(self):
     # check the http code
     code = self.response.getcode()
     if code != 200:
       logging.warning('%s returned %d' % (self.url, code))
       return False 

     # check the mime type     
     mime = self.response.info().type
     if mime != self.conf['mime']:
       logging.warning('Expected mime type: %s, but got %s' % (
          self.conf['mime'], mime))
       return False

     # do some extended checks for XML
     if mime.endswith('xml') and self.conf['root']:
        class Handler(sax.handler.ContentHandler):
          def startElement(self, name, attrs):  
            if not hasattr(self, 'root'):
              self.root = name

        h = Handler()
        sax.parse(self.response, h)
        if h.root != self.conf['root']:
          logging.warning('Expected root element: %s, but got %s' % (
            self.conf['root'], h.root))
          return False

     return True

   def dump(self):
     if hasattr(self, 'response'):
       f = tempfile.mkstemp(suffix=self.conf.get('main', 'name'))[1]
       logging.info('Dumping output to %s' % f)

       f = open(f, 'w')
       for line in self.response:
         f.write(line)
       f.close()
        
   def close(self):    
     if hasattr(self, 'response'):
       self.response.close()

   def _dict(self, conf):
     d = {}
     for t in conf:
       d[t[0]] = t[1]
     return d

if __name__ == '__main__':
  len(sys.argv) > 1 or exit('Usage: %s <.ini file>' % sys.argv[0])
  dog = Watchdog(sys.argv[1])
  dog.ping()
