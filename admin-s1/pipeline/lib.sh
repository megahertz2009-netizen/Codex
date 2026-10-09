set -e
cd /home/user/p8
E="-c:v libx264 -preset veryfast -crf 16 -pix_fmt yuv420p -r 24 -c:a aac -b:a 192k -ar 48000 -ac 2"
VF="scale=1080:1920:flags=lanczos,fps=24,format=yuv420p,setsar=1"
AF="aresample=48000,aformat=channel_layouts=stereo"
hasa(){ [ -n "$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$1")" ]; }
cut(){ local pre=""; [ -n "$5" ] && pre="$5,"; local fo; fo=$(python3 -c "print(round(max(0.0,$3-0.05),3))")
  if hasa "$1"; then
    ffmpeg -y -v error -ss $2 -t $3 -i "$1" -filter_complex "[0:v]${pre}$VF,trim=duration=$3,setpts=PTS-STARTPTS[v];[0:a]$AF,apad,atrim=0:$3,asetpts=PTS-STARTPTS,afade=t=in:d=0.015,afade=t=out:st=$fo:d=0.05[a]" -map "[v]" -map "[a]" -t $3 $E "$4"
  else
    ffmpeg -y -v error -ss $2 -t $3 -i "$1" -f lavfi -t $3 -i anullsrc=r=48000:cl=stereo -filter_complex "[0:v]${pre}$VF,trim=duration=$3,setpts=PTS-STARTPTS[v];[1:a]$AF,atrim=0:$3[a]" -map "[v]" -map "[a]" -t $3 $E "$4"
  fi; echo "cut $4 $(ffprobe -v error -show_entries format=duration -of csv=p=0 $4)"; }
join(){ local out=$1; shift; local ins=() fc="" i=0
  for f in "$@"; do ins+=(-i "$f"); fc="$fc[$i:v][$i:a]"; i=$((i+1)); done
  ffmpeg -y -v error "${ins[@]}" -filter_complex "${fc}concat=n=$i:v=1:a=1[v][a]" -map "[v]" -map "[a]" $E "$out"; echo "join $out $(ffprobe -v error -show_entries format=duration -of csv=p=0 $out)"; }
