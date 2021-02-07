
require 'pp'


colours = %w[
  Black
  Red
  Scarlet
  Silver
  Gold
  Quartz
    ].sort

forms = %w[
  Hand
  Arrow
  Ball
  Hut
  Pole
  Shield
  Tunnel
  Well
    ].sort

spells = colours.product(forms).collect { |a| a.join(' ') }

pp spells
p spells.count

