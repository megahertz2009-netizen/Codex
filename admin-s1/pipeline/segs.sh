# Stage 1 (v7 base): builds every segment s0..s7. Later stages (segs5.sh, segs7.sh) replace s1,s2,s3,s4,s6.
source ./lib.sh
# s0: helicopter with АДМИН + POV tracker + walk/face + crash zoom into the eye (red removed) + eye macro with the bear reflection
cut h.mp4 0 3.8 a0.mp4
cut q0.mp4 3.79 5.21 a1.mp4
mkdir -p ey; rm -f ey/e_*.png ey/f_*.png
ffmpeg -y -v error -ss 9.0 -i q0.mp4 -t 1.05 -vf "scale=1080:1920,fps=24" ey/e_%03d.png
python3 - <<'PY'
import glob, sys, numpy as np
sys.path.insert(0,'/home/user/p8')
from PIL import Image
from fixeye import fix_arr
fs=sorted(glob.glob('/home/user/p8/ey/e_*.png'))
for p in fs:
    out,r=fix_arr(np.asarray(Image.open(p).convert('RGB'))); Image.fromarray(out).save(p.replace('/e_','/f_'))
print('eyefix',len(fs))
PY
NF=$(ls ey/f_*.png | wc -l); echo $NF > eye_nf.txt
ED=$(python3 -c "print(round($NF/24,4))"); EF=$(python3 -c "print(round($NF/24-0.12,4))")
ffmpeg -y -v error -framerate 24 -i ey/f_%03d.png -ss 9.0 -t $ED -i q0.mp4 -filter_complex "[0:v]$VF[v];[1:a]$AF,apad,atrim=0:$ED,afade=t=out:st=$EF:d=0.12[a]" -map "[v]" -map "[a]" -t $ED $E a2.mp4
cut g.mp4 0 2.75 a3.mp4
join s0.mp4 a0.mp4 a1.mp4 a2.mp4 a3.mp4
cut q1.mp4 0 15.05 s1.mp4
cut old2.mp4 0.55 1.45 b0.mp4 "crop=528:940:276:980,scale=1080:1920:flags=lanczos,unsharp=5:5:0.6:5:5:0.0"
cut a.mp4 3.0 1.4 b1.mp4
cut old2.mp4 3.9 3.64 b2.mp4
cut w.mp4 4.0 11.05 b3.mp4
join s2.mp4 b0.mp4 b1.mp4 b2.mp4 b3.mp4
ffmpeg -y -v error -ss 2.6 -t 3.45 -i f.mp4 -filter_complex "[0:v]setpts=PTS-STARTPTS,setpts=1.176*PTS,framerate=fps=24,scale=1080:1920:flags=lanczos,format=yuv420p,setsar=1,trim=duration=4.05[v];[0:a]$AF,atempo=0.85,apad,atrim=0:4.05,afade=t=in:d=0.02,afade=t=out:st=3.95:d=0.1[a]" -map "[v]" -map "[a]" -t 4.05 $E s3.mp4
cut q3.mp4 7.34 5.26 c0.mp4
cut b.mp4 0 9.2 c1.mp4
cut q4.mp4 0 3.96 c2.mp4
cut t.mp4 0 6.05 c3.mp4
join s4.mp4 c0.mp4 c1.mp4 c2.mp4 c3.mp4
cut q4.mp4 6.95 7.65 s5.mp4
ffmpeg -y -v error -f lavfi -i color=c=black:s=1080x1920:r=24:d=10.6 -loop 1 -framerate 24 -t 5.0 -i heli_edit.png -f lavfi -t 10.6 -i anullsrc=r=48000:cl=stereo -filter_complex "[1:v]scale=1080:-2,crop=1080:1920,zoompan=z='1+0.0011*on':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=1080x1920:fps=24,eq=saturation=0.22:brightness=-0.07:contrast=1.06,vignette=angle=PI/4,noise=alls=12:allf=t,fade=in:st=0:d=0.8,fade=out:st=4.2:d=0.8,setpts=PTS-STARTPTS+1.6/TB[h];[0:v][h]overlay=eof_action=pass,format=yuv420p,setsar=1[v]" -map "[v]" -map 2:a -t 10.6 $E s6.mp4
ffmpeg -y -v error -loop 1 -framerate 24 -i gfx/title.png -f lavfi -i anullsrc=r=48000:cl=stereo -vf "scale=1080:1920,fade=in:st=0:d=0.4,format=yuv420p,setsar=1" -map 0:v -map 1:a -t 2.6 $E s7.mp4
for s in s0 s1 s2 s3 s4 s5 s6 s7; do echo "file '$s.mp4'"; done > list.txt
ffmpeg -y -v error -f concat -safe 0 -i list.txt -c copy master.mp4
echo SEGS_OK $(ffprobe -v error -show_entries format=duration -of csv=p=0 master.mp4)
