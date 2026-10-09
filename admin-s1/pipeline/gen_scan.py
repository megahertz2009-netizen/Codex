# Scanline overlay for the surveillance-camera shot.
from PIL import Image, ImageDraw
im=Image.new('RGBA',(1080,1920),(0,0,0,0)); d=ImageDraw.Draw(im)
for y in range(0,1920,4): d.line([(0,y),(1079,y)],fill=(0,0,0,46))
im.save('/home/user/p8/scan.png'); print('scan ok')
