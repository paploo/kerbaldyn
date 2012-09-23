# This is a terrible hack script to just get this done as quickly as possible.
# The real solution is to alter the lua script I found online to output the
# information as a useful JSON hash, and then read that json file and analyze.

require 'json'
require 'debugger'


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
      data[value] = entry
    end

    entry[key] = value
  end

  STDERR.puts "PARSED: #{data.length} entries."

  return data
end

def planetoid_data(data)
  data.inject({}) do |pdata,(name,entry)|
    pdata[name.downcase.to_sym] = {
      :name => 'Nameshort',
      :gravitational_parameter => 'Gm',
      :radius => 'Radius',
      :rotational_period => 'RotationPeriod'
    }.inject({}) do |h,(param,key)|
      h[param] = param==:name ? entry[key] : entry[key].to_f
      h
    end
    pdata
  end
end

def print_planetoid_methods(data)
  planetoid_data(data).each do |k,v|
    puts ""
    puts "def self.#{k}"
    puts "  return @#{k} ||= #{v.inspect}.freeze"
    puts "end"
  end
end

def orbit_data(data)
  orb_data = data.inject({}) do |odata,(name,entry)|
    odata[name.downcase.to_sym] = {
      :semimajor_axis => 'a',
      :eccentricity => 'Ecc',
      :mean_anomaly => 'Maae',
      :inclination => 'Inc',
      :longitude_of_ascending_node => 'Lan',
      :argument_of_periapsis => 'Ape'
    }.inject({}) do |h,(param,key)|
      h[param] = entry[key].to_f
      h
    end
    odata
  end

  [:mean_anomaly, :inclination, :longitude_of_ascending_node, :argument_of_periapsis].each do |param|
    orb_data.each do |name,values|
      orb_data[name][param] = values[param].to_f * Math::PI/180.0
    end
  end

  orb_data
end

def print_orbit_data_hash(data)
  puts "{"
  orbit_data(data).each do |k,v|
    puts "  #{k.inspect} => #{v.inspect},"
  end
  puts "}"
end

def main
  fp = File.join( File.dirname(__FILE__), 'planet_data_0.17.txt' )
  data = parse(fp)

  puts 'PLANETOID METHODS'
  puts ''
  print_planetoid_methods(data)
  puts ''

  puts 'ORBIT DATA'
  puts ''
  print_orbit_data_hash(data)
  puts ''
end

main()
