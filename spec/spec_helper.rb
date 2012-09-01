require 'rubygems'
require 'bundler/setup'
Bundler.require(:test)
require 'kerbaldyn'

RSpec::Matchers.define :be_within_error do |err|
  chain :of do |expected|
    @expected = expected
  end

  match do |actual|
    actual.should be_within( (err*@expected).abs ).of(@expected)
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

  # I looked up real values off of tables for the Earth as test data where possible.
  def self.earth
    return Proc.new do
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

      @options = {
        :mass => @mass,
        :radius => @radius,
        :rotational_period => @rotational_period
      }
      @planetoid = KerbalDyn::Planetoid.new(@name, @options)
    end
  end

  # I looked up values from tables where possible.
  def self.earth_geostationary_orbit
    return Proc.new do
      @geostationary_orbit_radius = 42164e3
      @geostationary_orbit_altitude = 35786e3
      @geostationary_orbit_angular_velocity = 7.2921e-5
      @geostationary_orbit_velocity = 3074.6
      @orbital_radius = @geostationary_orbit_radius
      @orbital_period = @rotational_period
      @orbital_velocity = @geostationary_orbit_velocity
      @orbital_kinetic_energy = 4726582.58 # Computed
      @orbital_potential_energy = -9453572.75875 # Computed
      @orbital_angular_momentum = 129640229204 # Computed using an alternative formula from a different source.
      @orbit = KerbalDyn::Orbit.new(@planetoid, :radius => @orbital_radius)
    end
  end

  # A third party transfer to geosynchronous orbit from 300km alt example that
  # can be used for the basis of elliptical orbit tests.
  def self.geostationary_transfer_orbit
    return Proc.new do
      @periapsis = 6678e3
      @apoapsis = 42164e3
      @periapsis_velocity = 10150
      @apoapsis_velocity = 1610
      @eccentricity = 0.72655
      @semimajor_axis = 24421e3
      @orbit = KerbalDyn::Orbit.new(@planetoid, :periapsis => @periapsis, :apoapsis => @apoapsis)
    end
  end

  # A pre-calculated and verified parabloic escape orbit from earth.
  def self.earth_escape_orbit
    return Proc.new do
      @periapsis = 6678e3
      # I used the calculated gavitational parameter for better precision,
      # since this is a "critical" orbit between elliptical and hyperbolc orbits.
      @escape_velocity = Math.sqrt( 2.0 * @planetoid.gravitational_parameter / @periapsis )
      @orbit = KerbalDyn::Orbit.new(@planetoid, :periapsis => @periapsis, :periapsis_velocity => @escape_velocity)
    end
  end

  def self.earth_hyperbolic_orbit
    return Proc.new do
      @periapsis = 6678e3
      @periapsis_velocity = 20000
      @eccentricity = 5.701 #Precomputed
      @orbit = KerbalDyn::Orbit.new(@planetoid, :periapsis => @periapsis, :periapsis_velocity => @periapsis_velocity)
    end
  end

end
