# This is a terrible hack script to just get this done as quickly as possible.
# The real solution is to alter the lua script I found online to output the
# information as a useful JSON hash, and then read that json file and analyze.

require 'json'
require 'debugger'

class String

  def underscore
    return self.downcase.gsub(/\s+/, '_')
  end

end

class Float

  def to_rad
    return self * Math::PI / 180.0
  end

end

class NilClass

  def underscore
    return nil
  end

  def to_rad
    return nil
  end

end

def parse(fp)
  data = {}
  entry = nil

  File.read(fp).each_line do |line|
    line = line.chomp
    next if line =~ /^[#]/
    next if line =~ /^\s*$/
    key, value = line.split(/\s+/, 2)

    if key == 'Nameshort'
      entry = {}
      data[value.underscore] = entry
    end

    entry[key] = translate(key, value)
  end

  #STDERR.puts "PARSED: #{data.length} entries."

  return data.sort {|(ak,av),(bk,bv)| av['Nameindex'] <=> bv['Nameindex']}
end

def translate(key, value)
  return value.gsub(',','.').split('.') if key=='Nameindex'

  typed_value = case value
                when "nil"
                 nil
                when /^[0-9.+-]+$/
                 value.to_f
                else
                 value.to_s
                end
end

PLANETOID_MAP = {
  :name => 'Nameshort',
  :gravitational_parameter => 'Gm',
  :radius => 'Radius',
  :rotational_period => 'RotationPeriod'
}

ORBIT_MAP = {
  :primary_body => lambda {|data| data['Refbodnameshort']=='Sun' ? 'kerbol' : data['Refbodnameshort'].underscore},
  :secondary_body => lambda {|data| data['Nameshort'].underscore},
  :semimajor_axis => 'a',
  :eccentricity => 'Ecc',
  :mean_anomaly => lambda {|data| data['Maae'].to_rad},
  :inclination => lambda {|data| data['Inc'].to_rad},
  :longitude_of_ascending_node => lambda {|data| data['Lan'].to_rad},
  :argument_of_periapsis => lambda {|data| data['Ape'].to_rad},
  :epoch => 'Epch'
}

TEST_MAP = {
  :name => 'Nameshort',
  :apoapsis => 'Apr',
  :periapsis => 'Per',
  :rotational_period => 'Sop',
  :specific_energy => 'Oe',
  :specific_angular_momentum => 'mag',
  :kerbal_sphere_of_influence => 'Hsoi'
}

# Given the data for a planet, and a map of kerbaldyn keys => script dump keys,
# give a filtered hash with keys mapped to kerbaldyn keys.
def map(data, map)
  return map.inject({}) do |h,(param,key)|
    h[param] = case key
               when Proc
                 key.call(data)
               else
                 data[key]
               end
    h
  end
end

# Returns a hash of data meant for the data file load.
def planet_data(data)
  data.inject({}) do |h,(name,datum)|
    h[name] = {}
    h[name][:planetoid] = map(datum, PLANETOID_MAP)
    h[name][:orbit] = map(datum, ORBIT_MAP)
    h
  end
end

# Returns a hash of data meant for the testing script load.
#
# This should be a separate file than the true data script so that updates to
# the data file can be managed separately to see how they affect testable
# parameters.
def test_data(data)
  data.inject({}) do |h,(name,datum)|
    h[name] = {}
    h[name][:planetoid] = map(datum, PLANETOID_MAP)
    h[name][:orbit] = map(datum, ORBIT_MAP.merge(TEST_MAP))
    h
  end
end

# Main.
def main(argv)
  fp = File.join( File.dirname(__FILE__), 'planet_data_0.17.txt' )
  data = parse(fp)

  case argv.first.downcase
  when 'planet'
    puts JSON.pretty_generate( planet_data(data) )
  when 'test'
    puts JSON.pretty_generate( test_data(data) )
  else
    STDERR.puts "Need to specify one of ['planet', 'test'] as first argument."
  end
end

main(ARGV)
