#!/usr/bin/python
import xmlrpclib, sys

ip = "127.0.0.1"
port = "10000"
server = xmlrpclib.Server("http://" + ip + ":" + port + "/xm.rem")
res = True 
try:
  res &= "right" in server.localproxy("sys:link.GetNeighbors")
  res &= "left" in server.localproxy("sys:link.GetNeighbors")
except:
  res = False
print res
sys.exit(res)