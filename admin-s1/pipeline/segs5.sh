# Stage 2: new ending s6 (black + base radio -> АДМИН CAM surveillance feed -> hand clenches -> bloody title)
source ./lib.sh
python3 gen_scan.py
rm -f blood/f_*.png; (cd blood && NODE_PATH=$(npm root -g) node rb.js 82)
ffmpeg -y -v error -f lavfi -i color=c=black:s=1080x1920:r=24:d=3.6 -f lavfi -i anullsrc=r=48000:cl=stereo -t 3.6 -map 0:v -map 1:a $E e0.mp4
ffmpeg -y -v error -i cctv.mp4 -loop 1 -framerate 24 -t 3.0 -i scan.png -filter_complex_script cctv_fc.txt -map "[v]" -map 0:a -af "aresample=48000,aformat=channel_layouts=stereo,atrim=0:3.0,afade=t=out:st=2.9:d=0.1" -t 3.0 $E e1.mp4
cut hand.mp4 1.0 4.05 e2.mp4 "eq=saturation=0.9:contrast=1.04,vignette=angle=PI/5"
ffmpeg -y -v error -framerate 24 -i blood/f_%03d.png -f lavfi -i anullsrc=r=48000:cl=stereo -filter_complex "[0:v]noise=alls=6:allf=t,format=yuv420p,setsar=1[v]" -map "[v]" -map 1:a -t 3.4167 $E e3.mp4
join s6.mp4 e0.mp4 e1.mp4 e2.mp4 e3.mp4
