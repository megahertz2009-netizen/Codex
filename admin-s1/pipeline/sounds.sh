R="-r 48000 -c 1"
sox -n $R br1.wav synth 3.5 sawtooth 55 fade q 0.02 3.5 3.2; sox -n $R br2.wav synth 3.5 sawtooth 55.6 fade q 0.02 3.5 3.2; sox -n $R br3.wav synth 3.5 sawtooth 110.3 fade q 0.02 3.5 3.0 vol 0.5
sox -m br1.wav br2.wav br3.wav -c 2 braam.wav lowpass 600 overdrive 12 reverb 40 gain -n -3
sox -n $R b1.wav synth 3 sine 42 fade q 0.003 3 2.9; sox -n $R b2.wav synth 0.25 brownnoise lowpass 300 fade q 0.001 0.25 0.24; sox -m b1.wav b2.wav -c 2 boom.wav gain -n -3
sox -n $R w.wav synth 0.9 pinknoise fade q 0.6 0.9 0.3 highpass 400 lowpass 6000; sox w.wav -c 2 whoosh.wav gain -n -8
sox -n $R st.wav synth 12 whitenoise highpass 800 lowpass 5000 vol 0.015; sox -n $R sq.wav synth 0.12 whitenoise highpass 1000 fade q 0.003 0.12 0.06 gain -n -12
sox -n $R d1.wav synth 100 brownnoise lowpass 140 tremolo 0.1 40; sox -n $R d2.wav synth 100 sine 49 tremolo 0.18 30; sox -m d1.wav d2.wav -c 2 bed.wav gain -n -26 fade t 3 100 5
ffmpeg -v error -y -i g1.mp3 -t 5.2 -af "afade=t=out:st=5.0:d=0.2" g1s.mp3
for f in g1s g2 bait base2; do ffmpeg -v error -y -i $f.mp3 -ar 48000 -ac 1 t_$f.wav; sox t_$f.wav r_$f.wav highpass 280 lowpass 3300 overdrive 5 gain -n -4; D=$(soxi -D r_$f.wav); sox st.wav s_$f.wav trim 0 $D; sox -m r_$f.wav s_$f.wav m_$f.wav; sox sq.wav m_$f.wav sq.wav -c 2 x_$f.wav gain -n -3; done
for f in vo2 vo3 vo4 n23 trap n22; do ffmpeg -v error -y -i $f.mp3 -ar 48000 -ac 1 t_$f.wav; sox t_$f.wav -c 2 x_$f.wav highpass 80 reverb 15 gain -n -3; done
sox -n $R lub.wav synth 0.17 sine 56 fade q 0.004 0.17 0.14; sox -n $R dub.wav synth 0.14 sine 47 fade q 0.004 0.14 0.11 vol 0.7; sox -n $R sil.wav trim 0 0.11
sox lub.wav sil.wav dub.wav -c 2 hb.wav lowpass 160 overdrive 8 gain -n -2
ffmpeg -v error -y -i gmA.mp3 -ar 48000 -ac 1 t_gm.wav; sox t_gm.wav -c 2 x_gm.wav pitch -50 highpass 90 lowpass 7500 reverb 30 50 70 gain -n -3
sox -n $R gl1.wav synth 0.45 whitenoise highpass 1200 lowpass 7000 tremolo 18 90 fade q 0.005 0.45 0.1; sox -n $R gl2.wav synth 0.45 square 60 tremolo 7 100 lowpass 2000 vol 0.3 fade q 0.005 0.45 0.1; sox -m gl1.wav gl2.wav -c 2 glitch.wav gain -n -6
sox x_gm.wav x_gm1.wav trim 0 2.45 fade t 0 2.45 0.15
sox x_gm.wav x_gm2.wav trim 2.6 fade t 0.02 0 0.3
