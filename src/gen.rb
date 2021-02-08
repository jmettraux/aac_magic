
require 'pp'


colours =
  File.readlines(File.join(__dir__, 'colours.md'))
    .drop_while { |l| ! l.start_with?('| colour ') }[2..-1]
    .take_while { |l| l.start_with?('| ') }
    .collect { |l| l.split(/\s*\|\s+/).select { |s| s.length > 0 } }
    .inject({}) { |h, (k, v)| h[k] = v; h }
#pp colours

forms =
  File.readlines(File.join(__dir__, 'forms.md'))
    .drop_while { |l| ! l.start_with?('| form ') }[2..-1]
    .take_while { |l| l.start_with?('| ') }
    .collect { |l| l.split(/\s*\|\s+/).select { |s| s.length > 0 } }
    .inject({}) { |h, (k, rad, rng, dur, spd)|
      h[k] = { radius: rad, range: rng, duration: dur, speed: spd }; h }
#pp forms

ranges =
  File.readlines(File.join(__dir__, 'forms.md'))
    .drop_while { |l| ! l.start_with?('| range ') }[2..-1]
    .take_while { |l| l.start_with?('| ') }
    .collect { |l| l.split(/\s*\|\s+/).select { |s| s.length > 0 } }
    .inject({}) { |h, (k, v)| h[k] = v; h }
#pp ranges

desclines =
  File.readlines(File.join(__dir__, 'spell_descriptions.md'))
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

File.open(File.join(__dir__, '_spells_descriptions.md'), 'wb') do |f|

  f.puts "\n# (SPELL DESCRIPTIONS)"
  f.puts
  f.puts "[CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode) for now."

  prod = colours.keys.product(forms.keys)
  f.puts
  f.puts "#{prod.count} potential spells."

  prod.each do |ck, fk|

    cfx = colours[ck]
    frm = forms[fk]
    rng = ranges[frm[:range]]
    nam = "#{ck} #{fk}"
    dsc = desclines[nam]

    f.puts "\n## #{nam}"
    f.puts
    f.puts "* **Casting Time:** 1 main action"
    f.puts "* **Range:** #{frm[:range]} (#{rng})"
    f.puts "* **Radius:** #{frm[:radius]}"
    f.puts "* **Duration:** #{frm[:duration]}"
    f.puts "* **Speed:** #{frm[:speed]}" if frm[:speed] && frm[:speed] != '0'
    f.puts
    f.puts "(#{cfx})"
    f.puts
  end
end

File.open(File.join(__dir__, 'spells.md'), 'wb') do |f|

  f.puts "\n# spells"
  f.puts
  f.puts "[CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode) for now."

  prod = colours.keys.product(forms.keys)
  f.puts
  f.puts "#{desclines.count} spells."
  f.puts

  prod.each do |ck, fk|

    cfx = colours[ck]
    frm = forms[fk]
    rng = ranges[frm[:range]]
    nam = "#{ck} #{fk}"
    dsc = desclines[nam]

    next unless dsc

    f.puts "\n## #{nam}"
    f.puts
    f.puts "* **Casting Time:** 1 main action"
    f.puts "* **Range:** #{frm[:range]} (#{rng})"
    f.puts "* **Radius:** #{frm[:radius]}"
    f.puts "* **Duration:** #{frm[:duration]}"
    f.puts "* **Speed:** #{frm[:speed]}" if frm[:speed] && frm[:speed] != '0'
    f.puts
    f.puts dsc.join('')
    f.puts
  end
end

