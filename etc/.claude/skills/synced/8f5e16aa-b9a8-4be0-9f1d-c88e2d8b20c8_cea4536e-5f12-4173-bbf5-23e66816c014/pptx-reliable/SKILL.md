---
name: pptx-reliable
description: "python-pptxでpptxを生成するときに使うスキル。画像を埋め込む前にJPEG圧縮する手順が書いてある。大きなPNG画像をそのまま埋め込むとMac/Keynoteで開けなくなる問題を防ぐ。python-pptxでスライドを作るとき、スクリーンショットや画像を含むとき、pptxが開けないと言われたときにトリガーすること。"
---

# python-pptx 画像埋め込みルール

python-pptxで画像（特にスクリーンショット）を埋め込むと、Mac/Keynote/QuickLookで「Failed to Load Document」になることがある。原因は画像サイズ。

## やること

画像を埋め込む前に、必ずJPEG圧縮する。

```python
from PIL import Image
import os

def compress_image(src_path, max_width=1200, quality=75):
    img = Image.open(src_path)
    if img.width > max_width:
        ratio = max_width / img.width
        img = img.resize((max_width, int(img.height * ratio)), Image.LANCZOS)
    if img.mode in ('RGBA', 'P'):
        bg = Image.new('RGB', img.size, (255, 255, 255))
        if img.mode == 'RGBA':
            bg.paste(img, mask=img.split()[3])
        else:
            bg.paste(img)
        img = bg
    elif img.mode != 'RGB':
        img = img.convert('RGB')
    out = src_path.rsplit('.', 1)[0] + '_compressed.jpg'
    img.save(out, 'JPEG', quality=quality)
    return out

# 使い方
compressed = compress_image("/path/to/screenshot.png")
slide.shapes.add_picture(compressed, Inches(x), Inches(y), Inches(w), Inches(h))
```

PNGをそのまま `add_picture()` に渡さない。それだけ。
