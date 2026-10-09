# Final mix: burned-in subtitles (ASS), voice lines with radio FX, ducking, SFX, drone bed, loudnorm -14 LUFS.
import os, subprocess
def dur(f): return float(subprocess.check_output(['ffprobe','-v','error','-show_entries','format=duration','-of','csv=p=0',f]).decode().strip())
OUT=os.environ.get('OUT','final.mp4')
S=['s%d'%i for i in range(8)]; o={}; t=0.0
for s in S: o[s]=t; t+=dur(s+'.mp4')
T=dur('master.mp4'); print('offsets',{k:round(v,2) for k,v in o.items()},'T',T,flush=True)
NF=int(open('eye_nf.txt').read().strip()); EYE0=o['s0']+3.8+5.21; G0=EYE0+NF/24.0
def ts(x): return "%d:%02d:%05.2f"%(int(x//3600),int(x%3600//60),x%60)
q=0.12
BX=dur('bx.mp4'); print('BX',BX,flush=True)
s1,s2,s3,s4,s5,s6,s7=[o['s%d'%i] for i in range(1,8)]
P15='{\\an2\\pos(540,1500)}'
vo={'g1s':(0.9,'R',[(0.0+q,1.52+q,'«Север», приём…'),(1.94+q,2.8+q,'Ты на точке.'),(3.24+q,4.95+q,'Сигнал идёт прямо из-подо льда.')]),
'n22':(6.35,'H',[(0.0,2.5,'Принял. Вижу метку. Иду.')]),
'g2':(s1+1.55,'R',[(0.0+q,2.0+q,'«Север»! «Север», ответь!'),(2.1+q,3.5+q,'Медведи вышли на лёд!'),(3.65+q,4.4+q,'Слышишь меня?!'),(4.7+q,6.5+q,'Уходи оттуда! Беги!')]),
'vo2':(s1+8.3,'H',[(0.0,1.5,'Не оглядывайся…'),(1.8,3.5,'Только не оглядывайся…')]),
'vo3':(s3-1.6,'H',[(1.6,3.2,P15+'Промок насквозь…'),(3.2,4.5,P15+'…а тепло не уходит.')]),
'n23':(s4+2.3,'H',[(0.0,1.2,'Что это?..')]),
'bait':(s4+7.27,'R',[(0.0+q,0.7+q,'«Север»!'),(0.85+q,2.95+q,'Это не маяк… это приманка!'),(3.15+q,4.5+q,'Они идут на сигнал!'),(4.6+q,5.6+q,'Уходи оттуда!')]),
'trap':(s4+19.1,'H',[(0.0,1.1,'Это ловушка…')]),
'vo4':(s5+1.5,'H',[(0.0,0.9,'Ну давай…'),(1.5,2.4,'…иди сюда.')]),
'base2':(s6+0.35,'R',[(0.0+q,0.7+q,'«Север»!'),(0.92+q,2.4+q,'«Север», ты меня слышишь?'),(2.56+q,3.1+q,'Ответь!')]),
'gm1':(s6+4.2,'C',[(0.0,2.3,'ПЕРВОЕ ИСПЫТАНИЕ ПРОЙДЕНО')]),
'gm2':(s6+10.95,'C',[])}
H="[Script Info]\nScriptType: v4.00+\nPlayResX: 1080\nPlayResY: 1920\nWrapStyle: 0\nScaledBorderAndShadow: yes\n\n[V4+ Styles]\nFormat: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding\nStyle: R,Montserrat,70,&H0096E6FF,&H0096E6FF,&H00000000,&H78000000,-1,-1,0,0,100,100,0,0,1,4,2,2,90,90,540,204\nStyle: H,Montserrat,72,&H00FFFFFF,&H00FFFFFF,&H00000000,&H78000000,-1,0,0,0,100,100,0,0,1,4,2,2,90,90,540,204\nStyle: C,Montserrat,58,&H001A1AE0,&H001A1AE0,&H00000000,&H96000000,-1,0,0,0,100,100,6,0,1,3,2,2,90,90,540,204\nStyle: L,Montserrat,46,&H00FFFFFF,&H00FFFFFF,&H00000000,&H64000000,-1,0,0,0,100,100,6,0,1,2,1,8,90,90,300,204\n\n[Events]\nFormat: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\n"
with open('subs.ass','w') as f:
    f.write(H)
    f.write("Dialogue: 1,%s,%s,L,,0,0,0,,{\\an5\\pos(540,740)\\fad(400,400)}СЕВЕРНЫЙ ПОЛЮС\\N{\\fs36\\b0}90° с. ш.\n"%(ts(1.5),ts(3.7)))
    for k,(st,sty,lines) in vo.items():
        for a,b,x in lines: f.write("Dialogue: 0,%s,%s,%s,,0,0,0,,%s\n"%(ts(st+a),ts(st+b),sty,x))
P="apad=whole_dur=%.3f"%T; ins=['-i','master.mp4']; fc=''; n=1; VOL=[]
for k,(st,sty,lines) in vo.items():
    ins+=['-i','x_%s.wav'%k]; d=int(st*1000); fc+="[%d:a]aresample=48000,aformat=channel_layouts=stereo,adelay=%d|%d,%s[v%d];"%(n,d,d,P,n); VOL.append('[v%d]'%n); n+=1
fc+="".join(VOL)+"amix=inputs=%d:duration=first:dropout_transition=0,volume=%d,volume=1.35,asplit=2[vob1][vob2];"%(len(VOL),len(VOL))
fc+="[0:a]aresample=48000,aformat=channel_layouts=stereo,%s[nat];[nat][vob1]sidechaincompress=threshold=0.03:ratio=5:attack=15:release=350[natd];"%P
sfx=[('braam.wav',[(s1,0.55),(s1+9.3,0.4),(s2+2.876+BX+0.8,0.65),(s2+12.9+BX,0.45),(s4+14.47,0.5),(s5+0.1,0.6)]),
     ('boom.wav',[(G0+1.2,0.55),(s2+15.4+BX,0.6),(s4+6.17,0.8),(s5+4.8,0.7),(s6+0.05,0.9),(s6+10.8,0.85),(s7,0.6)]),
     ('whoosh.wav',[(s1-0.3,0.5),(s2-0.3,0.5),(s3-0.3,0.5),(s4-0.3,0.5),(s5-0.3,0.5),(s4+18.43-0.3,0.45),(G0+0.6,0.4)]),
     ('glitch.wav',[(s6+3.5,0.9)]),
     ('hb.wav',[(s6+7.1,0.9),(s6+7.9,0.95),(s6+8.7,1.0),(s6+9.5,1.0),(EYE0+0.3,0.9),(EYE0+1.15,0.95),(EYE0+1.95,1.0),(EYE0+2.7,1.0)])]
L=['[natd]','[vob2]']
for fn,ev in sfx:
    tag=fn[:2]
    ins+=['-i',fn]; fc+="[%d:a]aresample=48000,aformat=channel_layouts=stereo,asplit=%d"%(n,len(ev))+"".join('[%s%d]'%(tag,i) for i in range(len(ev)))+";"
    for i,(st,vv) in enumerate(ev):
        d=int(max(0,st)*1000); fc+="[%s%d]volume=%.2f,adelay=%d|%d,%s[e%d_%d];"%(tag,i,vv,d,d,P,n,i); L.append('[e%d_%d]'%(n,i))
    n+=1
ins+=['-i','bed.wav']; fc+="[%d:a]aresample=48000,aformat=channel_layouts=stereo,volume=0.6,atrim=0:%.3f,%s[bed];"%(n,T,P); L.append('[bed]')
fc+="".join(L)+"amix=inputs=%d:duration=first:dropout_transition=0,volume=%d,alimiter=limit=0.9,loudnorm=I=-14:TP=-1.5:LRA=11,atrim=0:%.3f[aout];"%(len(L),len(L),T)
fc+="[0:v]vignette=angle=PI/5,eq=contrast=1.03:saturation=1.02,noise=alls=4:allf=t,subtitles=subs.ass:fontsdir=/home/user/.fonts,format=yuv420p[vout]"
cmd=['ffmpeg','-y','-v','error']+ins+['-filter_complex',fc,'-map','[vout]','-map','[aout]','-t','%.3f'%T,'-c:v','libx264','-preset','medium','-crf','18','-profile:v','high','-pix_fmt','yuv420p','-r','24','-c:a','aac','-b:a','192k','-ar','48000','-movflags','+faststart',OUT]
subprocess.check_call(cmd); print('FINAL_OK',OUT,flush=True)
