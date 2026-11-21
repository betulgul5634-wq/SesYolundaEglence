with open('mobile/lib/widgets/parent_report_sheet.dart', 'r', encoding='utf-8') as f:
    text = f.read()
print(f"parent_report_sheet length: {len(text)}")
idx = text.find('Widget build')
print(text[idx:idx+1500])
