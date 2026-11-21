with open('mobile/lib/widgets/therapy_certificate_dialog.dart', 'r', encoding='utf-8') as f:
    text = f.read()
print(f"therapy_certificate_dialog length: {len(text)}")
idx = text.find('Widget build')
print(text[idx:idx+1500])
