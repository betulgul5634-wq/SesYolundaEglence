import http.server
import socketserver
import os
import requests

PORT = 8080
BACKEND_URL = "http://127.0.0.1:8000"
DIRECTORY = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "mobile", "build", "web")

class CustomHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE')
        self.send_header('Access-Control-Allow-Headers', '*')
        self.send_header('Access-Control-Max-Age', '86400')
        self.end_headers()

    def proxy_to_backend(self, method):
        target_url = f"{BACKEND_URL}{self.path}"
        headers = {k: v for k, v in self.headers.items() if k.lower() not in ['host', 'content-length']}
        data = None
        if 'Content-Length' in self.headers:
            content_length = int(self.headers['Content-Length'])
            data = self.rfile.read(content_length)

        try:
            resp = requests.request(
                method=method,
                url=target_url,
                headers=headers,
                data=data,
                stream=True,
                allow_redirects=False,
                timeout=30
            )
            self.send_response(resp.status_code)
            for k, v in resp.headers.items():
                if k.lower() not in ['transfer-encoding', 'content-encoding', 'content-length', 'access-control-allow-origin']:
                    self.send_header(k, v)
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE')
            self.send_header('Access-Control-Allow-Headers', '*')
            self.send_header('Content-Length', str(len(resp.content)))
            self.end_headers()
            self.wfile.write(resp.content)
        except Exception as e:
            self.send_response(502)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(f"Proxy Error: {e}".encode())

    def do_GET(self):
        if self.path.startswith('/api/') or self.path in ['/docs', '/openapi.json']:
            self.proxy_to_backend('GET')
        else:
            super().do_GET()

    def do_POST(self):
        if self.path.startswith('/api/'):
            self.proxy_to_backend('POST')
        else:
            self.send_error(404, "Not Found")

    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        super().end_headers()

    def guess_type(self, path):
        if path.endswith('.wasm'):
            return 'application/wasm'
        if path.endswith('.js'):
            return 'application/javascript'
        if path.endswith('.json'):
            return 'application/json'
        return super().guess_type(path)

    def copyfile(self, source, outputfile):
        try:
            super().copyfile(source, outputfile)
        except (ConnectionResetError, ConnectionAbortedError, BrokenPipeError):
            pass

    def log_message(self, format, *args):
        pass

class ThreadedTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    daemon_threads = True
    allow_reuse_address = True

    def handle_error(self, request, client_address):
        pass

if __name__ == '__main__':
    with ThreadedTCPServer(("0.0.0.0", PORT), CustomHandler) as httpd:
        print(f"Serving Flutter Web with API reverse-proxy on all interfaces at http://0.0.0.0:{PORT}")
        httpd.serve_forever()
