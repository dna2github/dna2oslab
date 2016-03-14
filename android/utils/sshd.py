# compile python
# pip install twisted

#!/usr/bin/env python
#
# This file is part of rapidssh - http://bitbucket.org/gnotaras/rapidssh/
#
# rapidssh - A set of Secure Shell (SSH) server implementations in Python
#            using Twisted.conch, part of the Twisted Framework.
#
# Copyright (c) 2010 George Notaras - http://www.g-loaded.eu
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Initially based on the sshsimpleserver.py kindly published by:
# Twisted Matrix Laboratories - http://twistedmatrix.com
#
 
import sys
 
from twisted.conch.unix import UnixSSHRealm
from twisted.cred import portal
from twisted.cred.credentials import IUsernamePassword
from twisted.cred.checkers import ICredentialsChecker
from twisted.cred.error import UnauthorizedLogin
from twisted.conch.checkers import SSHPublicKeyDatabase
from twisted.conch.ssh import factory, userauth, connection, keys, session
from twisted.internet import reactor, defer
from twisted.python import log
from twisted.conch.checkers import UNIXPasswordDatabase

# Logging
# Currently logging to STDERR
log.startLogging(sys.stderr)
 
# Server-side public and private keys. These are the keys found in
# sshsimpleserver.py. Make sure you generate your own using ssh-keygen!

publicKey = 'ssh-rsa TODO: insert public key here'
 
privateKey = """-----BEGIN RSA PRIVATE KEY-----
TODO: insert private key here
-----END RSA PRIVATE KEY-----"""


class UnixSSHdFactory(factory.SSHFactory):
    publicKeys = {
        'ssh-rsa': keys.Key.fromString(data=publicKey)
    }
    privateKeys = {
        'ssh-rsa': keys.Key.fromString(data=privateKey)
    }
    services = {
        'ssh-userauth': userauth.SSHUserAuthServer,
        'ssh-connection': connection.SSHConnection
    }
 
# Components have already been registered in twisted.conch.unix
class StupidDatabase(UNIXPasswordDatabase):
    def requestAvatarId(self, credentials):
        return defer.succeed(credentials.username)


portal = portal.Portal(UnixSSHRealm())
#portal.registerChecker(PamPasswordDatabase())   # Supports PAM
#portal.registerChecker(SSHPublicKeyDatabase())  # Supports PKI
#portal.registerChecker(UNIXPasswordDatabase())
portal.registerChecker(StupidDatabase())
UnixSSHdFactory.portal = portal
 
if __name__ == '__main__':
    reactor.listenTCP(5022, UnixSSHdFactory())
    reactor.run()
