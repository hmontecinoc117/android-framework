from PIL import Image, ImageDraw, ImageFont
import os, json

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, 'assets')
IMAGES = os.path.join(ASSETS, 'images')
DATA = os.path.join(ASSETS, 'data')

os.makedirs(os.path.join(IMAGES, 'shapes'), exist_ok=True)
os.makedirs(os.path.join(IMAGES, 'vehicles'), exist_ok=True)
os.makedirs(os.path.join(IMAGES, 'animals'), exist_ok=True)
os.makedirs(DATA, exist_ok=True)

size = (800, 800)

# Circle
img = Image.new('RGBA', size, (0,0,0,0))
d = ImageDraw.Draw(img)
d.ellipse((150,150,650,650), fill=(255,200,0,255))
img.save(os.path.join(IMAGES, 'shapes', 'circle.png'))

# Square
img = Image.new('RGBA', size, (0,0,0,0)); d = ImageDraw.Draw(img)
d.rectangle((150,150,650,650), fill=(0,150,255,255))
img.save(os.path.join(IMAGES, 'shapes', 'square.png'))

# Triangle
img = Image.new('RGBA', size, (0,0,0,0)); d = ImageDraw.Draw(img)
d.polygon([(400,120),(700,650),(100,650)], fill=(0,255,150,255))
img.save(os.path.join(IMAGES, 'shapes', 'triangle.png'))

# Vehicles (simple silhouettes)
for name in ['car','train','plane']:
    img = Image.new('RGBA', size, (255,255,255,0))
    d = ImageDraw.Draw(img)
    d.rectangle((120,320,680,520), fill=(120,120,200,255))
    d.ellipse((160,520,260,620), fill=(20,20,20,255))
    d.ellipse((540,520,640,620), fill=(20,20,20,255))
    img.save(os.path.join(IMAGES, 'vehicles', f'{name}.png'))

# Animals (text placeholders)
font = ImageFont.load_default()
animals = ["perro","gato","pajaro","vaca","oveja","burro","raton","leon","mono","zorro"]
for a in animals:
    img = Image.new('RGBA', (800, 200), (255,255,255,0))
    d = ImageDraw.Draw(img)
    d.text((20,60), a.upper(), fill=(0,0,0,255), font=font)
    img.save(os.path.join(IMAGES, 'animals', f'{a}.png'))

with open(os.path.join(DATA, 'animals.json'), 'w', encoding='utf-8') as f:
    json.dump({"animals": animals}, f, ensure_ascii=False, indent=2)

# Placeholders válidos para evitar errores de import
def simple_card(color=(220,220,220,255), text='CARD'):
    img = Image.new('RGBA', (512, 512), (255,255,255,0))
    d = ImageDraw.Draw(img)
    d.rectangle((32,32,480,480), fill=color, outline=(0,0,0,255), width=8)
    d.text((180,240), text, fill=(0,0,0,255), font=font)
    return img

card_back = simple_card(color=(180,180,240,255), text='BACK')
card_back.save(os.path.join(IMAGES, 'card_back.png'))

placeholder_card = simple_card(color=(240,200,200,255), text='CARD')
placeholder_card.save(os.path.join(IMAGES, 'placeholder_card.png'))

placeholder_puzzle = Image.new('RGBA', (512, 512), (240,240,240,255))
d = ImageDraw.Draw(placeholder_puzzle)
d.line((0,256,512,256), fill=(150,150,150,255), width=6)
d.line((256,0,256,512), fill=(150,150,150,255), width=6)
placeholder_puzzle.save(os.path.join(IMAGES, 'placeholder_puzzle.png'))

print('Assets generated under features/godot/assets/')
