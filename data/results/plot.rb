#!/usr/bin/env ruby
#
base = ARGV[0]

pcm = { }
fcm = { }
classifiers = []
result = %x( grep 'Correctly Classified Instances' -r --include=*.weka | grep #{base} )
lines = result.split("\n")
lines.each do |line|
  tp = %x( echo #{line} | awk '{print $5}')
  tp.sub!("\n","")
  cluster = %x(echo #{line} | cut -f1 -d-) 
  classifier = %x(echo #{line} | cut -f2 -d/ | cut -f1 -d.)
  classifier.sub!("\n","")
  cluster.sub!("\n","")
  #puts "#{classifier} - #{cluster} - #{tp}"

  classifiers.push(classifier)

  if cluster == "fcm" 
    fcm[classifier] = tp
  elsif cluster == "pcm" 
    pcm[classifier] = tp
  end
end
max_knn = "KNN1"
max_knn_tp = 0
classifiers.uniq.each do |c|
  if c.include?("KNN")
    avg = pcm[c].to_f + fcm[c].to_f
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
  file.write "Title FCM PCM\n"
  classifiers.uniq.each do |c|
    file.write "#{c} #{fcm[c]} #{pcm[c]}\n"
  end
end
system( "./gplot.sh #{base}")
system( "eog #{base}.png" )

