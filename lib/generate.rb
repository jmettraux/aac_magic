
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
    .drop_while { |l| ! l.start_with?('| name ') }[2..-1]
    .take_while { |l| l.start_with?('| ') }
    .collect { |l| l.split(/\s*\|\s+/).select { |s| s.length > 0 } }
    .inject({}) { |h, (k, ct, dia, rng, dur, spd, ctl, mov, prl)|
      h[k] = {
        ct: ct, diameter: dia, range: rng, duration: dur, speed: spd,
        control: ctl, move: mov, prolong: prl }
      h }
#pp FORMS
puts ". %3d forms:   %s" % [ FORMS.count, FORMS.keys.join(',') ]

PROD = COLOURS.keys.product(FORMS.keys)
puts ". %3d potential spells" % PROD.count

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
    cst =
      frm[:ct] == 'MA+OTA' ?
      '1 main action, then 1 on turn action' :
      'main action'
    dsc = DESCLINES[nam]
    ctl = frm[:control]
    mov = frm[:move]
    plg = frm[:prolong]

    f.puts "\n## #{nam}"
    f.puts
    f.puts "* **Casting Time** #{cst}"
    f.puts "* **Range** #{frm[:range]}"
    f.puts "* **Diameter** #{frm[:diameter]}"
    f.puts "* **Duration** #{frm[:duration]}"
    f.puts "* **Speed** #{frm[:speed]}" if frm[:speed] && frm[:speed] != '0'
    f.puts "* **Control** <= #{ctl}" if ctl != '-'
    f.puts "* **Move** #{mov}" if mov != '-'
    f.puts "* **Prolong** #{plg}" if plg != '-'
    f.puts
    f.puts "(#{cfx})"
    f.puts
  end
end

KEYS = {
  casting_time: 'Casting Time',
  range: 'Range',
  diameter: 'Diameter',
  duration: 'Duration',
  control: 'Control',
  speed: 'Speed',
  move: 'Move',
  prolong: 'Prolong' }
COMPACT_KEYS = {
  casting_time: 'Cst',
  range: 'Rng',
  diameter: 'Dia',
  duration: 'Dur',
  control: 'Ctl',
  speed: 'Spd',
  move: 'Mov',
  prolong: 'Prol' }

def increase(count, maxes)

  a, b = count.chars.collect(&:to_i)
  b = b + 1
  if b > maxes[1]
    a = a + 1
    b = 1
  end

  "#{a}#{b}"
end

def write_spells(opts)

  cpt = opts[:compact]
  div = opts[:div]
  dic = opts[:dice]

  ks = cpt ? COMPACT_KEYS : KEYS

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

    number = '10'

    PROD.each do |ck, fk|

      cfx = COLOURS[ck]
      frm = FORMS[fk]
      cst =
        frm[:ct] == 'MA+OTA' ?
        '1 main action, then 1 on turn action' :
        'main action'
      dia = frm[:diameter]
      nam = "#{ck} #{fk}"
      dsc = DESCLINES[nam]
      ctl = frm[:control]
      mov = frm[:move]
      plg = frm[:prolong]

      next unless dsc

      number = increase(number, [ 6, 8 ])

      f.puts "<!-- <div.spell> -->" if div
      if dic
        #f.puts "\n## ~~#{number}~~ #{nam}"
        f.puts "\n## #{nam} ~~#{number}~~"
      else
        f.puts "\n## #{nam}"
      end
      f.puts "* **#{ks[:casting_time]}** #{cst}"
      f.puts "* **#{ks[:range]}** #{frm[:range]}"
      f.puts "* **#{ks[:diameter]}** #{dia}" if cpt != true || dia != '-'
      f.puts "* **#{ks[:duration]}** #{frm[:duration]}"
      f.puts "* **#{ks[:speed]}** #{frm[:speed]}" if frm[:speed] && frm[:speed] != '0'
      f.puts "* **#{ks[:control]}** <= #{ctl}" if ctl != '-'
      f.puts "* **#{ks[:move]}** #{mov}" if mov != '-'
      f.puts "* **#{ks[:prolong]}** #{plg}" if plg != '-'
      f.puts
      f.puts dsc.join('')
      f.puts "\n<!-- </div> -->" if div
      f.puts
    end
  end
end

write_spells(fname: 'spells.md')
write_spells(fname: 'spells_aa.md', compact: true, div: true, dice: true)

