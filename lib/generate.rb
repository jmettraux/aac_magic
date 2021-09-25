
require 'pp'


puts

colour_table =
  File.readlines('src/_colours_in.md')
    .drop_while { |l| ! l.start_with?('| colour ') }
    .take_while { |l| l.start_with?('|') }
colours =
  colour_table[2..-1]
    .collect { |l| l.split(/\s*\|\s+/).select { |s| s.length > 0 } }
    .inject({}) { |h, (k, v)| h[k] = v; h }
#pp colours
puts ". %3d colours: %s" % [ colours.count, colours.keys.join(',') ]

forms =
  File.readlines('src/_forms_in.md')
    .drop_while { |l| ! l.start_with?('| form ') }[2..-1]
    .take_while { |l| l.start_with?('| ') }
    .collect { |l| l.split(/\s*\|\s+/).select { |s| s.length > 0 } }
    .inject({}) { |h, (k, ct, dia, rng, dur, spd)|
      h[k] = { ct: ct, diameter: dia, range: rng, duration: dur, speed: spd }
      h }
#pp forms
puts ". %3d forms:   %s" % [ forms.count, forms.keys.join(',') ]

prod = colours.keys.product(forms.keys)
puts ". %3d potential spells" % prod.count

ranges =
  File.readlines('src/_forms_in.md')
    .drop_while { |l| ! l.start_with?('| range ') }[2..-1]
    .take_while { |l| l.start_with?('| ') }
    .collect { |l| l.split(/\s*\|\s+/).select { |s| s.length > 0 } }
    .inject({}) { |h, (k, v)| h[k] = v; h }
#pp ranges

extra =
  File.readlines('src/_forms_in.md')
    .drop_while { |l| ! l.start_with?('| from   | move ') }[2..-1]
    .take_while { |l| l.start_with?('| ') }
    .collect { |l| l.split(/\s*\|\s+/).select { |s| s.length > 0 } }
    .inject({}) { |h, (k, mve, plg)| h[k] = { move: mve, prolong: plg }; h }
#pp extra

desclines =
  File.readlines('src/_descriptions_in.md')
    .inject([]) { |a, l|
      case l
      when /^## (.+)$/
        a << [ $1 ]
      when /^\* \*\*[CRDS].+:\*\* /
        # nothing
      else
        a.last << l if a.any? && (l != "\n" || a.last.length > 1)
      end
      a }
    .inject({}) { |h, a|
      aa = a[1..-1]; while aa.last == "\n"; aa.pop; end
      h[a[0]] = aa unless aa.length == 1 && aa[0].match?(/^\(.+\)\n$/)
      h }
#pp desclines
puts '. %3d spells described' % desclines.count
puts '. %3d spells to describe' % (prod.count - desclines.count)


File.open('src/_descriptions_out.md', 'wb') do |f|

  f.puts
  f.puts "# (SPELL DESCRIPTIONS)"
  f.puts
  f.puts "[CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode) for now."

  f.puts
  f.puts "#{prod.count} potential spells,"
  f.puts "#{prod.count - desclines.count} spells to describe."

  prod.each do |ck, fk|

    nam = "#{ck} #{fk}"

    next if desclines[nam]

    cfx = colours[ck]
    frm = forms[fk]
    cst =
      frm[:ct] == 'ma+ota' ?
      '1 main action, then 1 on turn action' :
      'main action'
    rng = ranges[frm[:range]]
    dsc = desclines[nam]
    mov = extra[fk][:move]
    plg = extra[fk][:prolong]

    f.puts "\n## #{nam}"
    f.puts
    f.puts "* **Casting Time:** #{cst}"
    f.puts "* **Range:** #{frm[:range]} (#{rng})"
    f.puts "* **Diameter:** #{frm[:diameter]}"
    f.puts "* **Duration:** #{frm[:duration]}"
    f.puts "* **Speed:** #{frm[:speed]}" if frm[:speed] && frm[:speed] != '0'
    f.puts "* **Move:** #{mov}" if mov != '-'
    f.puts "* **Prolong:** #{plg}" if plg != '-'
    f.puts
    f.puts "(#{cfx})"
    f.puts
  end
end


File.open('src/spells.md', 'wb') do |f|

  f.puts
  f.puts "# spells"
  f.puts
  f.puts "[CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode) for now."

  f.puts
  f.puts "#{desclines.count} spells."
  f.puts
  #f.puts "## colours"
  #f.puts
  #f.puts colour_table
  #f.puts

  prod.each do |ck, fk|

    cfx = colours[ck]
    frm = forms[fk]
    cst =
      frm[:ct] == 'ma+ota' ?
      '1 main action, then 1 on turn action' :
      'main action'
    rng = ranges[frm[:range]]
    nam = "#{ck} #{fk}"
    dsc = desclines[nam]
    mov = extra[fk][:move]
    plg = extra[fk][:prolong]

    next unless dsc

    f.puts "\n## #{nam}"
    f.puts
    f.puts "* **Casting Time:** #{cst}"
    f.puts "* **Range:** #{frm[:range]} (#{rng})"
    f.puts "* **Diameter:** #{frm[:diameter]}"
    f.puts "* **Duration:** #{frm[:duration]}"
    f.puts "* **Speed:** #{frm[:speed]}" if frm[:speed] && frm[:speed] != '0'
    f.puts "* **Move:** #{mov}" if mov != '-'
    f.puts "* **Prolong:** #{plg}" if plg != '-'
    f.puts
    f.puts dsc.join('')
    f.puts
  end
end

