#!/usr/bin/python
import winrm,os,sys
import optparse


parser = optparse.OptionParser(usage="%prog", version="%prog 1.0")
parser.add_option("-u", "--username", dest="username", type="string",
                          default='vagrant', help="Please Enter Windows Username used to connect to winrm of remote server")
parser.add_option("-P", "--password", dest="password", type="string",
                          default='vagrant', help="please enter windows password used to connect to winrm of remote server")
parser.add_option("-n", "--hostname", dest="hostname", type="string",
                          default='localhost', help="please enter hostname or ip address to connec to winrm of remote server")
parser.add_option("-p", "--port", dest="port", type="string",
                          default='5985', help="please enter winrm port number default 5985")
parser.add_option("-c", "--command", dest="command", type="string",
                          default='@powershell $env:computername', help="Please Enter Powershell command to be executed on remote windows server")

def wrm(username,password,hostname,port,command):
    rms = winrm.Session(str(hostname + ':' + port), auth=(username, password))
    r = rms.run_cmd(command)
    if r.status_code  == 0:
       print(r.std_out)
    else:
       print(r.std_err)

def main(argv=None):
        global options
        if argv is None:
           argv = sys.argv
        (options, args) = parser.parse_args(args=argv[1:])
        username = options.username
        password = options.password
        hostname = options.hostname
        port     = options.port
        command  = options.command
        wrm(username,password,hostname,port,'@powershell $PSVersionTable.PSVersion')
        wrm(username,password,hostname,port,'@powershell Set-ExecutionPolicy unrestricted')
        wrm(username,password,hostname,port,command)

if __name__ == "__main__":
        sys.exit(main())

