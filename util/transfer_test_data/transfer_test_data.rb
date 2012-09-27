require 'kerbaldyn'

require 'debugger'

class Array

  def deltas
    debugger
    return [] if self.length < 2
    return (1...self.length).map do |i|
      self[i] - self[i-1]
    end
  end

  def delta_pairs
    return self.map {|x0,x1| x1-x0}
  end

  def cumulatives(initial=0.0)
    return self.inject([initial]) {|a,x| a << a.last+x}
  end

end

def puts_tabular(data, opts={})
  width = opts.fetch(:width, 18)
  line = data.map do |o|
    case o
    when Float
      "%0.12g" % o
    when nil
      'nil'
    else
      o.to_s
    end
  end.map {|s| s.to_s.rjust(width)}.join(', ')

  puts line
end

SQRT2 = Math.sqrt(2.0)
PI = Math::PI
PI2 = 2.0 * Math::PI

PLANET = KerbalDyn::Planetoid.new('Base', :gravitational_parameter => 2.0**12, :radius => 2.0)


puts "TABLES"
puts ""

puts_tabular [:k, :r, :v_per, nil, nil, :T]
0.upto(12).each do |k|
  next unless k%2==0
  orbit = KerbalDyn::Orbit.new(PLANET, :radius => 2.0**k)
  puts_tabular [k, orbit.periapsis, orbit.periapsis_velocity, nil, nil, orbit.period]
end

puts ""

puts_tabular [:k, :r_per, :v_per, :r_ap, :v_ap, :T]
0.upto(12).each do |k|
  orbit = KerbalDyn::Orbit.new(PLANET, :periapsis => 16.0, :apoapsis => 2.0**k)
  puts_tabular [k, orbit.periapsis, orbit.periapsis_velocity, orbit.apoapsis, orbit.apoapsis_velocity, orbit.period]
end

puts ""

puts_tabular [:k, :r_per, :v_per, :r_ap, :v_ap, :T]
0.upto(12).each do |k|
  orbit = KerbalDyn::Orbit.new(PLANET, :periapsis => 2.0**k, :apoapsis => 64.0)
  puts_tabular [k, orbit.periapsis, orbit.periapsis_velocity, orbit.apoapsis, orbit.apoapsis_velocity, orbit.period]
end

puts ""
puts "SELECTED"
puts ""


# We consider several transfers from the initial orbit to the final orbit:
# Hohmann: Leave the initial and go to the final.
# Bielliptic Low: We leave the initial, go to a *lower* altitude, and then come up.
# Bielliptic Med: We leave the initial, go to an *intermediate* altitude, and then come the rest of hte way up.
# Bielliptic Hi: We leave the initial, go to a *higH* altitude, and then come down; this is the classical version.

INIT_R = 16.0
FINL_R = 64.0

orbits = {}

puts_tabular [:k, :r_per, :v_per, :r_ap, :v_ap, :T]
{
  :initial  => [INIT_R, INIT_R],
  :final    => [FINL_R, FINL_R],
  :hohmann  => [INIT_R, FINL_R],
  :bi_low_1 => [INIT_R,    4.0],
  :bi_low_2 => [4.0,    FINL_R],
  :bi_mid_1 => [INIT_R,   32.0],
  :bi_mid_2 => [32.0,   FINL_R],
  :bi_hig_1 => [INIT_R,  256.0],
  :bi_hig_2 => [256.0,  FINL_R]
}.each do |name,(r1,r2)|
  orbit = KerbalDyn::Orbit.new(PLANET, :periapsis => [r1,r2].min, :apoapsis => [r1,r2].max)
  data = {:name => name, :per => orbit.periapsis, :per_v => orbit.periapsis_velocity, :apo => orbit.apoapsis, :apo_v => orbit.apoapsis_velocity, :period => orbit.period}
  orbits[name] = data
  puts_tabular data.values
end

puts ""
puts "DELTA_V"
puts ""

{
  :hohmann_up => [ [orbits[:initial][:per_v], orbits[:hohmann][:per_v]], [orbits[:hohmann][:apo_v], orbits[:final][:apo_v]] ],
  :hohmann_down => [ [orbits[:final][:per_v], orbits[:hohmann][:apo_v]], [orbits[:hohmann][:per_v], orbits[:initial][:apo_v]] ],
  :bi_low_up =>  [ [orbits[:initial][:per_v], orbits[:bi_low_1][:apo_v]], [orbits[:bi_low_1][:per_v], orbits[:bi_low_2][:per_v]], [orbits[:bi_low_2][:apo_v], orbits[:final][:per_v]] ],
  :bi_mid_up =>  [ [orbits[:initial][:per_v], orbits[:bi_mid_1][:per_v]], [orbits[:bi_mid_1][:apo_v], orbits[:bi_mid_2][:per_v]], [orbits[:bi_mid_2][:apo_v], orbits[:final][:per_v]] ],
  :bi_high_up => [ [orbits[:initial][:per_v], orbits[:bi_hig_1][:per_v]], [orbits[:bi_hig_1][:apo_v], orbits[:bi_hig_2][:apo_v]], [orbits[:bi_hig_2][:per_v], orbits[:final][:per_v]] ]
}.each do |name, velocities|
  puts name
  puts velocities.inspect
  puts_tabular velocities.delta_pairs
  puts velocities.delta_pairs.inject(0) {|s,x| s + x.abs}
end

# TODO: Re-implement the orbital meneuvers to give a list of velocity pairs at various maneuver points; This can be used to derive the deltas and the total.
# TODO: Additionally, an array of the radiuses for the maneuvers should be given.
# TODO: Lastly, and array of the times of maneuvers (as well as the deltas between them derived from the array) should be given.


puts ""
puts "TIME"
puts ""

{
  :hohmann => [ orbits[:hohmann][:period] / 2.0 ],
  :bi_low => [ orbits[:bi_low_1][:period] / 2.0, orbits[:bi_low_2][:period] / 2.0 ],
  :bi_mid => [ orbits[:bi_mid_1][:period] / 2.0, orbits[:bi_mid_2][:period] / 2.0 ],
  :bi_hig => [ orbits[:bi_hig_1][:period] / 2.0, orbits[:bi_hig_2][:period] / 2.0 ]
}.each do |name, delta_t|
  puts name
  puts delta_t.inspect
  puts_tabular delta_t.cumulatives
end

