from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

root = Path(r'd:\\projects\\Aximate\\integrations\\ripple\\desktop-windows\\assets')
root.mkdir(parents=True, exist_ok=True)

size = 1024
img = Image.new('RGBA', (size, size), (0,0,0,0))
d = ImageDraw.Draw(img)

center = size/2
for r in range(int(center), 0, -1):
    t = r/center
    c = (
        int(8 + (34-8)*(1-t)),
        int(145 + (211-145)*(1-t)),
        int(178 + (238-178)*(1-t)),
        255,
    )
    d.ellipse((center-r, center-r, center+r, center+r), fill=c)

ring = int(size*0.04)
d.ellipse((ring, ring, size-ring, size-ring), outline=(255,255,255,60), width=int(size*0.01))

text = 'R'
font = None
for name in [
    'C:/Windows/Fonts/segoeuib.ttf',
    'C:/Windows/Fonts/arialbd.ttf',
    'C:/Windows/Fonts/seguisb.ttf',
    'C:/Windows/Fonts/arial.ttf',
]:
    if Path(name).exists():
        font = ImageFont.truetype(name, int(size*0.62))
        break
if font is None:
    font = ImageFont.load_default()

bbox = d.textbbox((0,0), text, font=font)
tw, th = bbox[2]-bbox[0], bbox[3]-bbox[1]
x = (size - tw)/2
y = (size - th)/2 - size*0.03

shadow_off = int(size*0.02)
d.text((x+shadow_off, y+shadow_off), text, font=font, fill=(0,0,0,80))
d.text((x, y), text, font=font, fill=(240,253,255,255))

png_path = root / 'icon.png'
ico_path = root / 'icon.ico'
img.save(png_path)
img.save(ico_path, sizes=[(16,16),(24,24),(32,32),(48,48),(64,64),(128,128),(256,256)])
print('Wrote', png_path)
print('Wrote', ico_path)
