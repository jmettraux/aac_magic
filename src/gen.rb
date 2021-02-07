
require 'pp'


colours = %w[
  Black
  Red
  Scarlet
  Silver
  Gold
  Quartz
  White
    ].sort

forms = %w[
  Arrow
  Ball
  Disk
  Finger
  Hut
  Pole
  Shield
  Tunnel
  Well
    ].sort

spells = colours.product(forms).collect { |a| a.join(' ') }

pp spells
p spells.count

