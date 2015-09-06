#!/usr/bin/env ruby
#
base = ARGV[0]
experiment = ARGV[1]

clusters = { }

classifiers = []
result = %x( grep 'Correctly Classified Instances' -r --include=*.weka #{experiment} | grep #{base} )
# results-hefcm-hefsfcm-fcm/hefcm-opinosis/NB.weka:Correctly Classified Instances          32               62.7451 %
lines = result.split("\n")
lines.each do |line|
  tp = %x( echo #{line} | awk '{print $5}')
  tp.sub!("\n","")
  cluster = %x(echo #{line} | cut -f2 -d/ | cut -f1 -d-) 
  classifier = %x(echo #{line} | cut -f3 -d/ | cut -f1 -d.)
  classifier.sub!("\n","")
  cluster.sub!("\n","")
  puts "#{classifier} - #{cluster} - #{tp}"

  classifiers.push(classifier)

  if clusters[cluster].nil?
    clusters[cluster] = {}
  end

  clusters[cluster][classifier] = tp

end
max_knn = "KNN1"
max_knn_tp = 0
classifiers.uniq.each do |c|
  if c.include?("KNN")
    avg = 0
    clusters.keys.each do |k|
      avg += clusters[k][c].to_f
    end
    if avg > max_knn_tp
      max_knn_tp = avg
      max_knn = c
    end
  end
end

classifiers.uniq.each do |c|
  if c.include?("KNN") and c != max_knn
    classifiers.delete(c)
  end
end

#puts "Title\t #{classifiers.uniq.map{|c| c+"\t"}.join}"
#puts "FCM\t #{fcm.values.map{|v| v+"\t"}.join}"
#puts "PCM\t #{pcm.values.map{|v| v+"\t"}.join}"

File.open("#{base}.dat", 'w') do |file|
  title = "Title"
  clusters.keys.sort.each do |cluster|
    title += " #{cluster.upcase}"
  end
  title += "\n"
  file.write title 
  
  classifiers.uniq.each do |c|
    file.write "#{c}"
    clusters.keys.sort.each do |cluster|
      file.write " #{clusters[cluster][c]}"
    end
    file.write "\n"
  end
end
#system( "./gplot.sh #{base}")
#FCM = "#99ffff"; PCM = "#0072d5"; HEFCM = "#4672d5"; HEFSFCM = "#ff71d5"; HFCM = "#99ffff"; HPCM = "#0072d5";
#, '' u 4 ti col fc rgb HEFCM, '' u 5 ti col fc rgb HEFSFCM, '' u 6 ti col fc rgb HFCM, '' u 7 ti col fc rgb HPCM
#plot '#{base}.dat' using 2:xtic(1) ti "HFCM" linecolor rgb "#AAAAAA", '' u 3 ti "HPCM" linecolor rgb "#333333"
%x( 
gnuplot <<- EOF
set title "#{base} base"
HFCM = "#aaaaaa"; HPCM = "#333333";
set auto x
set yrange [0:120]
set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.9
set xtic scale 0
# 2, 3, 4, 5 are the indexes of the columns; 'fc' stands for 'fillcolor'
set term png
set output "#{base}.png"
plot '#{base}.dat' using 2:xtic(1) ti col linecolor rgb "#AAAAAA", '' u 3 ti col linecolor rgb "#333333"
EOF
)
#system( "eog #{base}.png" )

