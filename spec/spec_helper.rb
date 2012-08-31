require 'rubygems'
require 'bundler/setup'
Bundler.require(:test)
require 'kerbaldyn'

RSpec::Matchers.define :be_within_error do |err|
  chain :of do |expected|
    @expected = expected
  end

  match do |actual|
    actual.should be_within(err*@expected).of(@expected)
  end
end

{:two => 21.977895, :three => 370.398, :four => 15787.0, :five => 1744278.0, :six => 506797346}.each do |level, frac|
  err = 1.0 / frac.to_f
  RSpec::Matchers.define "be_within_#{level}_sigma_of".to_sym do |expected|
    match do |actual|
      actual.should be_within_error(err).of(expected)
    end
  end
end

class BeforeFactory

  def self.earth
    return Proc.new do
      # I looked up real values off of tables for the Earth as test data where possible.
      @name = 'Earth'
      @mass = 5.9736e24
      @radius = 6378.1e3
      @rotational_period = 86164.091
      @angular_velocity = 7.2921150e-5
      @volume = 1.08321e21
      @density = 5515.0
      @gravitational_parameter = 398600.4418e9 # 398600.4418e9 is on some tables, but other tables vary starting in the 4th digit!
      @surface_gravity = 9.780327
      @escape_velocity = 11.186e3
      @equitorial_velocity = 465.1
      @geostationary_orbit_radius = 42164e3
      @geostationary_orbit_altitude = 35786e3
      @geostationary_orbit_angular_velocity = 7.2921e-5
      @geostationary_orbit_velocity = 3074.6

      @options = {
        :mass => @mass,
        :radius => @radius,
        :rotational_period => @rotational_period
      }
      @planetoid = KerbalDyn::Planetoid.new(@name, @options)
    end
  end

end
