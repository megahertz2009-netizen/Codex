# Stage 3 (v12 fixes after QA): rebuilds s1, s2, s3, s4 and the hand shot in s6, then the master.
source ./lib.sh
BXS=${BXS:-0}; BXD=${BXD:-1.55}
# s1: shorter bear stare, chase graded to overcast, face trimmed after "Беги!", jump hang sped up 2x
cut q1.mp4 0 2.0 d0.mp4
cut q1.mp4 3.2 4.13 d1.mp4 "eq=saturation=0.62:contrast=0.92:gamma=1.03,colorbalance=rs=-0.06:gs=-0.02:bs=0.06:rh=-0.05:bh=0.05"
cut q1.mp4 7.33 2.13 d2.mp4
cut q1.mp4 10.535 1.125 d3.mp4
ffmpeg -y -v error -ss 11.66 -t 3.39 -i q1.mp4 -filter_complex "[0:v]setpts=PTS-STARTPTS,setpts=0.5*PTS,$VF,trim=duration=1.695,setpts=PTS-STARTPTS[v];[0:a]$AF,atempo=2.0,apad,atrim=0:1.695,asetpts=PTS-STARTPTS,afade=t=out:st=1.645:d=0.05[a]" -map "[v]" -map "[a]" -t 1.695 $E d4.mp4
join s1.mp4 d0.mp4 d1.mp4 d2.mp4 d3.mp4 d4.mp4
# s2: entry -> side in parka -> NEW he rips the parka off -> v1 plunge (empty parka behind him) -> bear tears parka (brightened) -> climb out -> bear with torn parka (reds removed) -> ice collapse (morph frames cut) -> white
cut bxraw.mp4 $BXS $BXD bx.mp4
cut w.mp4 4.0 3.25 b3a.mp4 "eq=gamma=1.2:brightness=0.02,huesaturation=saturation=-0.6:colors=r+m"
cut w.mp4 7.25 2.95 b3b.mp4
cut w.mp4 10.2 2.69 b3c.mp4 "huesaturation=saturation=-0.85:colors=r+m"
cut w.mp4 13.54 1.51 b3d.mp4 "fade=out:st=1.2:d=0.3:color=white"
join s2.mp4 b0.mp4 b1.mp4 bx.mp4 b2.mp4 b3a.mp4 b3b.mp4 b3c.mp4 b3d.mp4
# s3: steam, start when he is already rising, slight slow-mo without frame blending, in from white
ffmpeg -y -v error -ss 3.5 -t 2.55 -i f.mp4 -filter_complex "[0:v]setpts=PTS-STARTPTS,setpts=1.1765*PTS,fps=24,scale=1080:1920:flags=lanczos,fade=in:st=0:d=0.3:color=white,format=yuv420p,setsar=1,trim=duration=3.0[v];[0:a]$AF,atempo=0.85,apad,atrim=0:3.0,afade=t=in:d=0.02,afade=t=out:st=2.9:d=0.1[a]" -map "[v]" -map "[a]" -t 3.0 $E s3.mp4
# s4: keep the search walk with the tracker after he climbs out (client prefers it); olive cuff and golden light neutralised
cut q3.mp4 7.34 5.26 c0.mp4 "huesaturation=saturation=-0.8:colors=y+g,eq=saturation=0.8:gamma=0.97,colorbalance=rs=-0.05:gs=-0.01:bs=0.05"
join s4.mp4 c0.mp4 c1.mp4 c2.mp4 c3.mp4
# s6: hand sleeve to neutral grey
cut hand.mp4 1.0 4.05 e2.mp4 "huesaturation=saturation=-0.85:colors=y+g,eq=saturation=0.9:contrast=1.04,vignette=angle=PI/5"
join s6.mp4 e0.mp4 e1.mp4 e2.mp4 e3.mp4
for s in s0 s1 s2 s3 s4 s5 s6 s7; do echo "file '$s.mp4'"; done > list.txt
ffmpeg -y -v error -f concat -safe 0 -i list.txt -c copy master.mp4
echo SEGS_OK $(ffprobe -v error -show_entries format=duration -of csv=p=0 master.mp4)
