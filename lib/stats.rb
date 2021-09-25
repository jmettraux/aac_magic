
puts

lines = File.readlines('src/_descriptions_in.md')
  .select { |l| l.match?(/^## .+/) }
  .collect { |l| l.strip[3..-1] }

colour_table =
  File.readlines('src/_colours_in.md')
    .drop_while { |l| ! l.start_with?('| colour ') }
    .take_while { |l| l.start_with?('|') }
effects =
  colour_table[2..-1]
    .collect { |l| l.split(/\s*\|\s+/).select { |s| s.length > 0 } }
    .inject({}) { |h, (k, v)| h[k] = v; h }

colours = lines
  .inject({}) { |h, l| c, f = l.split(' '); (h[c] ||= []) << l; h }
forms = lines
  .inject({}) { |h, l| c, f = l.split(' '); (h[f] ||= []) << l; h }

#pp lines
#pp colours
#pp effects
#pp forms

colours.each do |c, a|
  a = a.collect { |n| "#{c[0, 1]} #{n.split.last}" }
  puts ". %-10s: %8s : %2d : %s" % [ c, effects[c], a.count, a.join(', ') ]
end

puts

forms.each do |f, a|
  a = a.collect { |n| "#{n.split.first} #{f[0, 1]}" }
  puts ". %-7s: %2d : %s" % [ f, a.count, a.join(', ') ]
end

puts
puts "  #{lines.count} spells"

