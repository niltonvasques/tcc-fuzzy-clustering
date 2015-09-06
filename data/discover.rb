#!/bin/env ruby

output = "/tmp/bases"
folders = %x(find . -iname discover.names | xargs -n 1 dirname )

folders = folders.split("\n")

puts folders

folders.each do |f|
  f.sub!("./","")
  out = "#{output}/#{f}"
  %x(mkdir -p #{output}/#{f})
  cp = "cp #{f}/discover.names #{out}/discover.names"
  puts cp
  system cp
  cp = "cp #{f}/discover.data #{out}/discover.data"
  puts cp
  system cp
end

