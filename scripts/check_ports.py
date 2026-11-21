import urllib.request

for port in [8000, 8080]:
    try:
        r = urllib.request.urlopen(f"http://127.0.0.1:{port}/")
        print(f"Port {port}: OK ({r.status})")
    except Exception as e:
        print(f"Port {port}: ERROR ({e})")
