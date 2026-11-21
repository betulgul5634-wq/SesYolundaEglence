import docx

doc_p = 'C:/Users/ASUS/.gemini/antigravity/brain/ffc530cc-181a-4ee6-9064-662cf989282f/.user_uploaded/media_1795044520345_6a836f37.docx'
doc = docx.Document(doc_p)

print(f"Total Paragraphs: {len(doc.paragraphs)}")
print(f"Total Tables: {len(doc.tables)}")

for i, p in enumerate(doc.paragraphs):
    text = p.text.strip()
    if text:
        style_name = p.style.name if p.style else 'None'
        print(f"[{i:02d}] ({style_name}): {text}")
