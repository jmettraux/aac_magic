
require 'pp'


puts

colour_table =
  File.readlines('src/_colours_in.md')
    .drop_while { |l| ! l.start_with?('| colour ') }
    .take_while { |l| l.start_with?('|') }
COLOURS =
  colour_table[2..-1]
    .collect { |l| l.split(/\s*\|\s+/).select { |s| s.length > 0 } }
    .inject({}) { |h, (k, v)| h[k] = v; h }
#pp COLOURS
puts ". %3d colours: %s" % [ COLOURS.count, COLOURS.keys.join(',') ]

FORMS =
  File.readlines('src/_forms_in.md')
    .drop_while { |l| ! l.start_with?('| form ') }[2..-1]
    .take_while { |l| l.start_with?('| ') }
    .collect { |l| l.split(/\s*\|\s+/).select { |s| s.length > 0 } }
    .inject({}) { |h, (k, dia, rng, dur, spd)|
      h[k] = { ct: 'MA', diameter: dia, range: rng, duration: dur, speed: spd }
      h }
#pp FORMS
puts ". %3d forms:   %s" % [ FORMS.count, FORMS.keys.join(',') ]

PROD = COLOURS.keys.product(FORMS.keys)
puts ". %3d potential spells" % PROD.count

EXTRA =
  File.readlines('src/_forms_in.md')
    .drop_while { |l| ! l.start_with?('| from   | move ') }[2..-1]
    .take_while { |l| l.start_with?('| ') }
    .collect { |l| l.split(/\s*\|\s+/).select { |s| s.length > 0 } }
    .inject({}) { |h, (k, mve, plg)| h[k] = { move: mve, prolong: plg }; h }
#pp EXTRA

DESCLINES =
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
#pp DESCLINES
puts '. %3d spells described' % DESCLINES.count
puts '. %3d spells to describe' % (PROD.count - DESCLINES.count)


File.open('src/_descriptions_out.md', 'wb') do |f|

  f.puts
  f.puts "# (SPELL DESCRIPTIONS)"
  f.puts
  f.puts "[CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode) for now."

  f.puts
  f.puts "#{PROD.count} potential spells,"
  f.puts "#{PROD.count - DESCLINES.count} spells to describe."

  PROD.each do |ck, fk|

    nam = "#{ck} #{fk}"

    next if DESCLINES[nam]

    cfx = COLOURS[ck]
    frm = FORMS[fk]
    cst = 'main action'
      #frm[:ct] == 'ma+ota' ?
      #'1 main action, then 1 on turn action' :
      #'main action'
    dsc = DESCLINES[nam]
    mov = EXTRA[fk][:move]
    plg = EXTRA[fk][:prolong]

    f.puts "\n## #{nam}"
    f.puts
    f.puts "* **Casting Time** #{cst}"
    f.puts "* **Range** #{frm[:range]}"
    f.puts "* **Diameter** #{frm[:diameter]}"
    f.puts "* **Duration** #{frm[:duration]}"
    f.puts "* **Speed** #{frm[:speed]}" if frm[:speed] && frm[:speed] != '0'
    f.puts "* **Move** #{mov}" if mov != '-'
    f.puts "* **Prolong** #{plg}" if plg != '-'
    f.puts
    f.puts "(#{cfx})"
    f.puts
  end
end


def write_spells(opts)

  File.open("src/#{opts[:fname]}", 'wb') do |f|

    f.puts
    f.puts "# spells"
    f.puts
    f.puts "[CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode) for now."

    f.puts
    f.puts "#{DESCLINES.count} spells."
    f.puts
    #f.puts "## COLOURS"
    #f.puts
    #f.puts colour_table
    #f.puts

    PROD.each do |ck, fk|

      cfx = COLOURS[ck]
      frm = FORMS[fk]
      cst = 'main action'
        #frm[:ct] == 'ma+ota' ?
        #'1 main action, then 1 on turn action' :
        #'main action'
      nam = "#{ck} #{fk}"
      dsc = DESCLINES[nam]
      mov = EXTRA[fk][:move]
      plg = EXTRA[fk][:prolong]

      next unless dsc

      f.puts "\n## #{nam}"
      f.puts
      f.puts "* **Casting Time** #{cst}"
      f.puts "* **Range** #{frm[:range]}"
      f.puts "* **Diameter** #{frm[:diameter]}"
      f.puts "* **Duration** #{frm[:duration]}"
      f.puts "* **Speed** #{frm[:speed]}" if frm[:speed] && frm[:speed] != '0'
      f.puts "* **Move** #{mov}" if mov != '-'
      f.puts "* **Prolong** #{plg}" if plg != '-'
      f.puts
      f.puts dsc.join('')
      if opts[:clear]
        f.puts "<!-- clear -->"
        f.puts
      end
      f.puts
    end
  end
end

write_spells(fname: 'spells.md')
#write_spells(fname: 'spells_clear.md', clear: true)

