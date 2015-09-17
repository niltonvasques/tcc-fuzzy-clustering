
bases = [
  "newyork",
 "opinosis",
 "garmin",
 "nsf",
 "iaarticles",
 "newsgroup",
 "wap",
 "reuters",
 "hitech"]

#$clusters = ["HFCM", "HPCM"]
$clusters = ["FCM", "PCM"]

def write_table(file, hfcm, hpcm)
  file.write %q[
      \begin{table}[H]
      \caption{Comparisson}
      \centering
      \begin{tabular}{ |c|c| } 
      \hline
  ]
  file.write "#{$clusters[0]} & #{$clusters[1]} \\\\"
  file.write %q[
      \hline
  ]
  file.write "#{hfcm} & #{hpcm} \\\\\n"
  file.write %q[
      \hline
      \end{tabular}
      \end{table}
  ]
end

def draw_end(file)
  file.write %s(

    \end{multicols}

    \end{document}
  ) 
end

def handle_hierarchy(file, b)
  points = {}
  points[$clusters[0]] = 0
  points[$clusters[1]] = 0

  charts = ""
  5.times do |x|
    img = "#{b}-level-#{x}" 
    charts += "\\includegraphics[width=8cm]{#{img}}\n" if File.exist?("#{img}.png")
    dat_file = File.readlines("#{img}.dat")
    inner_points = {}
    inner_points[$clusters[0]] = 0
    inner_points[$clusters[1]] = 0
    clusters_values = dat_file[0].split(" ")
    dat_file.size.times do |j|
      unless dat_file[j].nil?
        values = dat_file[j].split(" ")
        #    puts values
        if values[1].to_f > values[2].to_f
          inner_points[clusters_values[1]] += 1 
        elsif values[1].to_f < values[2].to_f
          inner_points[clusters_values[2]] += 1 
        end
      end
    end
    value1 = clusters_values[1].nil? ? 0 : inner_points[clusters_values[1]]
    value2 = clusters_values[2].nil? ? 0 : inner_points[clusters_values[2]]
    #puts "#{value1} v1 #{value2} v2"
    if value1 > value2 
      points[clusters_values[1]] += 1 
    elsif value1 < value2 
      points[clusters_values[2]] += 1 
    end
    #puts "#{hfcm_level} hfcm_level x #{hpcm_level} hpcm_level"
  end
  write_table(file, points[$clusters[0]], points[$clusters[1]])
  file.write charts
end

def handle_clustering(file, b)
  charts = ""
  img = "#{b}" 
  charts += "\\includegraphics[width=8cm]{#{img}}\n" if File.exist?("#{img}.png")
  dat_file = File.readlines("#{img}.dat")
  file.write charts
end



system "cp article_2.tex results.tex"

File.open("results.tex", "a+") do |file|
  system "rm -Rf *.png"

  bases.each do |b|
    if $clusters[0] == "HFCM" or $clusters[1] == "HFCM"
      5.times do |x|
        system "./plot.rb #{b}-level-#{x} ."
      end
    else
        system "./plot.rb #{b} ."
    end
  end

  puts "find . -name \\*.png -size 0 | xargs rm"
  system "find . -name \\*.png -size 0 | xargs rm"

  bases.each do |b|
    file.write "\\section{#{b.capitalize}}\n\n"
    if $clusters[0] == "HFCM" or $clusters[1] == "HFCM"
      handle_hierarchy(file, b)
      file.write "\\newpage\n\n"
    else
      handle_clustering(file, b)
    end
  end
  draw_end(file)
end

system "pdflatex results.tex"
system "evince results.pdf"
