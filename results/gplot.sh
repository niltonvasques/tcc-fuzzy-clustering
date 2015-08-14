BASE=$1
gnuplot <<- EOF
set title "${BASE} base"
FCM = "#99ffff"; PCM = "#0072d5"; HEFCM = "#4672d5"; HEFSFCM = "#ff71d5";
set auto x
set yrange [0:100]
set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.9
set xtic scale 0
# 2, 3, 4, 5 are the indexes of the columns; 'fc' stands for 'fillcolor'
set term png
set output "${BASE}.png"
plot '${BASE}.dat' using 2:xtic(1) ti col fc rgb FCM, '' u 3 ti col fc rgb PCM, '' u 4 ti col fc rgb HEFCM, '' u 5 ti col fc rgb HEFSFCM
EOF
