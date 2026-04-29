import re
import sys
from pathlib import Path

pdf_path = Path(__file__).parent / 'PrincessIvyFetizanan_Mockup_ACtivity3.figma.pdf'
if not pdf_path.exists():
    print('PDF not found:', pdf_path)
    sys.exit(1)

data = pdf_path.read_bytes()

stream_re = re.compile(b"stream\r?\n(.*?)\r?\nendstream", re.S)
found = 0
outdir = Path(__file__).parent
for i, m in enumerate(stream_re.finditer(data), 1):
    chunk = m.group(1)
    if chunk.startswith(b'\xff\xd8\xff'):
        fname = outdir / f'extracted_{i:03d}.jpg'
        fname.write_bytes(chunk)
        print('Wrote', fname.name)
        found += 1
    elif chunk.startswith(b'\x89PNG\r\n\x1a\n'):
        fname = outdir / f'extracted_{i:03d}.png'
        fname.write_bytes(chunk)
        print('Wrote', fname.name)
        found += 1

print('Done. Found', found, 'image(s).')
