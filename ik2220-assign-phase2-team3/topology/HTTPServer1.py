from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
from SocketServer import ThreadingMixIn
import threading
import SocketServer

class ThreadingServer (ThreadingMixIn, HTTPServer)
	pass
class Handler(BaseHTTPRequestHandler)
	def _set_headers(self):
		self.send_response(200)
		self.send_header('Content-type', 'text/html')
		self.end_headers()

	def do_PUT(self):
		print("=============Data was PUT!=============")
		self._set_headers()
		print self.headers
		length = self.headers['Content-Length']

		data = self.rfile.read(int(length))
		print data
		self.wfile.write('<html><body><h1>PUT method success!</h1></body></html>')

	def do_POST(self)
		length = int(self.headers['Content-Length'])
		data = self.rfile.read(length)
		self._set_headers()
		self.wfile.write("<html><body><h1>POST method success!</h1><pre>" + data + "</pre></body></html>")

	def do_GET(self):
		self._set_headers()
		self.wfile.write("<html><body><h1>GET method success! Hello!</h1></body></html>")

def run(server_class = ThreadingServer, handler_class = Handler, port = 80):
	server_addr = ('100.0.0.40', port)
	httpd = server_class(server_addr, handler_class)
	print('HTTP server starting...')
	httpd.serve_forever()

if __name__ == '__main__':
	from sys import argv

	if len(argv) == 2:
		run(port = int(argv[1]))
	else:
		run()