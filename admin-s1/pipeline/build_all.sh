# Full rebuild of the current version (v12) from scratch inside the Higgsfield sandbox.
# Copy this whole folder to /home/user/p8 first, then: cd /home/user/p8 && bash build_all.sh > build.log 2>&1   (run in background, ~6-8 min)
set -e
cd /home/user/p8
bash dl.sh
bash fonts.sh
NODE_PATH=$(npm root -g) node gfx/render.js
{ bash sounds.sh 2>&1 | grep -v -i warn; true; }
bash segs.sh
bash segs5.sh
BXS=0 BXD=1.55 bash segs7.sh
OUT=final.mp4 python3 final.py
ffmpeg -y -v error -i final.mp4 -c:v libx264 -preset faster -crf 23 -maxrate 9M -bufsize 18M -pix_fmt yuv420p -c:a copy -movflags +faststart light.mp4
for f in final.mp4 light.mp4; do ffprobe -v error -show_entries format=duration,size -of compact $f; done
echo BUILD_ALL_OK
