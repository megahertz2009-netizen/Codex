import sys, numpy as np
from PIL import Image
def fix_arr(im):
    im=im.astype(np.float32); R,G,B=im[...,0],im[...,1],im[...,2]; mx=np.maximum(G,B); d=R-mx
    core=(d>90)&(R>150)
    if core.sum()<3: return im.astype(np.uint8), 0
    ys,xs=np.nonzero(core); cy,cx=ys.mean(),xs.mean()
    h,w=R.shape; yy,xx=np.mgrid[0:h,0:w]; dist=np.sqrt((yy-cy)**2+(xx-cx)**2)
    win=dist<max(12,np.sqrt(core.sum()/np.pi)*4)
    glow=win&(d>30)&(R>70)
    r=max(3.0,np.sqrt(glow.sum()/np.pi))
    a=np.clip((r*1.65-dist)/(r*0.45),0,1)[...,None]
    Y=0.299*R+0.587*G+0.114*B
    L=20+230*np.power(np.clip(Y/255.0,0,1),4)
    new=np.stack([L*0.97,L*1.0,L*1.04],axis=2)
    out=im*(1-a)+new*a
    return np.clip(out,0,255).astype(np.uint8), r
if __name__=='__main__':
    for p in sys.argv[1:]:
        im=np.asarray(Image.open(p).convert('RGB')); out,r=fix_arr(im)
        Image.fromarray(out).save(p.replace('.png','_f.png')); print(p,'r=%.1f'%r)
