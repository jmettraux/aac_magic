
puts

spells = {}
name = nil

File.readlines('src/_descriptions_in.md').each do |l|

  if l.match(/^## (.+)/)
    name = $1
  elsif name && l.match(/^[^\s*]/)
    spells[name] = l.strip
    name = nil
  end
end

w = spells.keys.collect(&:length).max

spells.each do |k, v|
  puts "* %-#{w + 1}s %s" % [ k + ':', v ]
end

