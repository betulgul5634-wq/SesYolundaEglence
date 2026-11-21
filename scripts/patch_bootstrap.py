file_path = 'mobile/build/web/flutter_bootstrap.js'
with open(file_path, 'r', encoding='utf-8') as f:
    js = f.read()

# Inject into _flutter.buildConfig
if '"useLocalCanvasKit":true' not in js:
    js = js.replace('"engineRevision":', '"useLocalCanvasKit":true,"engineRevision":')

# Inject config into _flutter.loader.load({
target = '_flutter.loader.load({\n  serviceWorkerSettings:'
replacement = '_flutter.loader.load({\n  config: {\n    canvasKitBaseUrl: "canvaskit/",\n    useLocalCanvasKit: true\n  },\n  serviceWorkerSettings:'

if 'canvasKitBaseUrl: "canvaskit/"' not in js:
    js = js.replace(target, replacement)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(js)

print("SUCCESS: Checked and patched flutter_bootstrap.js for local CanvasKit")
