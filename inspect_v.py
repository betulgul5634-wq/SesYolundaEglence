import fitz
from rapidocr_onnxruntime import RapidOCR

doc = fitz.open('C:/Users/ASUS/.gemini/antigravity/brain/ffc530cc-181a-4ee6-9064-662cf989282f/.user_uploaded/media_1792859488799_1d38bb41.pdf')
ocr = RapidOCR()

pix = doc[86].get_pixmap(dpi=110) # 0-indexed 86 = page 87
res, _ = ocr(pix.tobytes())
for item in res:
    print(item[1])
