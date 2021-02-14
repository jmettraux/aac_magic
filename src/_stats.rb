
puts

lines = File.readlines('src/_descriptions_in.md')
  .select { |l| l.match?(/^## .+/) }
  .collect { |l| l.strip[3..-1] }

colours = lines
  .inject({}) { |h, l| c, f = l.split(' '); (h[c] ||= []) << l; h }
forms = lines
  .inject({}) { |h, l| c, f = l.split(' '); (h[f] ||= []) << l; h }

#pp lines
#pp colours
#pp forms

colours.each do |c, a|
  puts ". %-10s: %2d : %s" % [ c, a.count, a.join(', ') ]
end

puts

forms.each do |f, a|
  puts ". %-7s: %2d : %s" % [ f, a.count, a.join(', ') ]
end

