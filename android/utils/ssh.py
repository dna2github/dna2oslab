# compile python
# pip install paramiko
import getpass
from optparse import OptionParser 
from sshcore import Connection

def dumpLines(lines):
    if lines is None:
        return
    for line in lines:
        if len(line) == 0:
            pass
        elif line[-1] == '\n':
            line = line[0:-1]
        print line

parser = OptionParser()
parser.add_option(                            
    "-H", "--host", dest="hostname", default="127.0.0.1",
    help="The SSH server host name, default is 127.0.0.1") 
parser.add_option(
    "-p", "--port", dest="port", default="22",
    help="The SSH port number, default is 22")
parser.add_option(
    "-u", "--user", dest="username",
    help="The SSH login user name")
(options, args) = parser.parse_args()

if options.username is None or len(options.username) == 0:
    raise ValueError("User name should not be empty")

conn = None
passwd = None
i = 3
while i > 0:
    try:
        passwd = getpass.getpass("password: ")
        conn = Connection(options.hostname, options.username, password=passwd, port=int(options.port))
        break
    except Exception as e:
        print str(e)
        print "Permission denied, please try again."
        i = i - 1

while True:
    line = raw_input("! %s@%s # " % (options.username, options.hostname))
    if line is None:
        break

    args = line.split(" ")
    cmd = args[0]
    n = len(args)
    if cmd == ":exit" and n == 1:
        # :exit for quit
        break
    elif cmd == ":push" and n == 3:
        # :put scp local remote
        conn.put(args[1], args[2])
    elif cmd == ":pull" and n == 3:
        # :pull scp remote local
        conn.get(args[1], args[2])
    else:
        # command, e.g. ps -ef | grep python
        dumpLines(conn.execute(line))

conn.close()
