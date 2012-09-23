module KerbalDyn
  # The primary class for encapsulating an orbit around a primary body.
  # At this time orbits are simplified to only consider the mass of the primary
  # body, thus the orbit of the secondary body is around the center-of-mass of
  # the primary body.  This approximation works well for the Kerbal universe.
  class Orbit
    include Mixin::ParameterAttributes
    include Mixin::OptionsProcessor

    # A list of the independent parameters that define an orbit for this class.
    BASE_PARAMETERS = [:periapsis, :periapsis_velocity, :inclination, :longitude_of_ascending_node, :argument_of_periapsis, :mean_anomaly, :epoch]

    # A map of default values for initialization parameters.
    DEFAULT_OPTIONS = BASE_PARAMETERS.inject({}) {|opts,param| opts[param] = 0.0; opts}.merge(:secondary_body => Body::TEST_PARTICLE)

    # This is an internal factory data structure and hsould not be used.
    #
    # Orbital data output from in-game data dump via the planet_data.lua Autom8 script.
    # NOTE: In the future I may have JSON data files hold this information.
    ORBITAL_PARAMETERS = {
      :kerbin => {:semimajor_axis=>13599840256.0, :eccentricity=>0.0, :mean_anomaly=>3.1400001049041752, :inclination=>0.0, :longitude_of_ascending_node=>0.0, :argument_of_periapsis=>0.0},
      :duna => {:semimajor_axis=>20726155264.0, :eccentricity=>0.0509999990463257, :mean_anomaly=>3.1400001049041752, :inclination=>0.0010471975277899085, :longitude_of_ascending_node=>2.3649211364523164, :argument_of_periapsis=>0.0},
      :moho => {:semimajor_axis=>5263138304.0, :eccentricity=>0.200000002980232, :mean_anomaly=>3.1400001049041752, :inclination=>0.12217304763960307, :longitude_of_ascending_node=>1.2217304763960306, :argument_of_periapsis=>0.2617993877991494},
      :eve => {:semimajor_axis=>9832684544.0, :eccentricity=>0.00999999977648258, :mean_anomaly=>3.1400001049041752, :inclination=>0.03665191262740527, :longitude_of_ascending_node=>0.2617993877991494, :argument_of_periapsis=>0.0},
      :jool => {:semimajor_axis=>68773560320.0, :eccentricity=>0.0500000007450581, :mean_anomaly=>0.10000000149011617, :inclination=>0.022759093795545936, :longitude_of_ascending_node=>0.9075712110370514, :argument_of_periapsis=>0.0},
      :vall => {:semimajor_axis=>43152000.0, :eccentricity=>0.0, :mean_anomaly=>0.8999999761581429, :inclination=>0.0, :longitude_of_ascending_node=>0.0, :argument_of_periapsis=>0.0},
      :laythe => {:semimajor_axis=>27184000.0, :eccentricity=>0.0, :mean_anomaly=>3.1400001049041752, :inclination=>0.0, :longitude_of_ascending_node=>0.0, :argument_of_periapsis=>0.0},
      :tylo => {:semimajor_axis=>68500000.0, :eccentricity=>0.0, :mean_anomaly=>3.1400001049041752, :inclination=>0.00043633231950044, :longitude_of_ascending_node=>0.0, :argument_of_periapsis=>0.0},
      :bop => {:semimajor_axis=>104500000.0, :eccentricity=>0.234999999403954, :mean_anomaly=>0.8999999761581429, :inclination=>0.2617993877991494, :longitude_of_ascending_node=>0.17453292519943295, :argument_of_periapsis=>0.4363323129985824},
      :gilly => {:semimajor_axis=>31500000.0, :eccentricity=>0.550000011920929, :mean_anomaly=>0.8999999761581429, :inclination=>0.20943951023931953, :longitude_of_ascending_node=>1.3962634015954636, :argument_of_periapsis=>0.17453292519943295},
      :ike => {:semimajor_axis=>3200000.0, :eccentricity=>0.0299999993294477, :mean_anomaly=>1.7000000476837156, :inclination=>0.00349065855600352, :longitude_of_ascending_node=>0.0, :argument_of_periapsis=>0.0},
      :mun => {:semimajor_axis=>12000000.0, :eccentricity=>0.0, :mean_anomaly=>1.7000000476837156, :inclination=>0.0, :longitude_of_ascending_node=>0.0, :argument_of_periapsis=>0.0},
      :minmus => {:semimajor_axis=>47000000.0, :eccentricity=>0.0, :mean_anomaly=>0.8999999761581429, :inclination=>0.10471975511965977, :longitude_of_ascending_node=>1.361356816555577, :argument_of_periapsis=>0.6632251157578452},
    }

    #{:kerbol => [:moho, :eve, :kerbin, :duna, :jool], :eve => [:gilly], :kerbin => [:mun, :minmus], :duna => [:ike], :jool => [:laythe, :vall, :tylo, :bop]}.each do |primary, secondaries|
    #  secondaries.each do |secondary|
    #    # TODO: Dynamically build methods
    #  end
    #end

    # This is an internal factory method and should not be used.
    def self.orbit_factory(primary, secondary)
      self.new( Planetoid.send(primary), ORBITAL_PARAMETERS[secondary].merge(:secondary_body => Planetoid.send(secondary)) ).freeze
    end

    def self.kerbol_kerbin
      return @kerbol_kerbin ||= orbit_factory(:kerbol, :kerbin)
    end

    def self.kerbin_mun
      return @kerbin_mun ||= orbit_factory(:kerbin, :mun)
    end

    def self.kerbin_minmus
      return @kerbin_minmus ||= orbit_factory(:kerbin, :minmus)
    end

    def self.kerbol_moho
      return @kerbol_moho ||= orbit_factory(:kerbol, :moho)
    end

    def self.kerbol_eve
      return @kerbol_eve ||= orbit_factory(:kerbol, :eve)
    end

    def self.eve_gilly
      return @eve_gilly ||= orbit_factory(:eve, :gilly)
    end

    def self.kerbol_duna
      return @kerbol_duna ||= orbit_factory(:kerbol, :duna)
    end

    def self.duna_ike
      return @duna_ike ||= orbit_factory(:duna, :ike)
    end

    def self.kerbol_jool
      return @kerbol_jool ||= orbit_factory(:kerbol, :jool)
    end

    def self.jool_laythe
      return @jool_laythe ||= orbit_factory(:jool, :laythe)
    end

    def self.jool_vall
      return @jool_vall ||= orbit_factory(:jool, :vall)
    end

    def self.jool_tylo
      return @jool_tylo ||= orbit_factory(:jool, :tylo)
    end

    def self.jool_bop
      return @jool_bop ||= orbit_factory(:jool, :bop)
    end

    # Convenience method for creating a circular orbit about the given body.
    # This is redundant to calling new with the option of :radius.
    def self.circular_orbit(primary_body, radius)
      return self.new(primary_body, :radius => radius)
    end

    # Convenience method for creating a circular orbit of a given period around
    # a given body.
    def self.circular_orbit_of_period(primary_body, period)
      planetoid_angular_velocity = 2.0 * Math::PI / period
      radius = (primary_body.gravitational_parameter / planetoid_angular_velocity**2)**(1.0/3.0)
      return self.circular_orbit(primary_body, radius)
    end

    # Convenience method for creating a geostationary orbit around the given body.
    def self.geostationary_orbit(primary_body)
      return self.circular_orbit_of_period(primary_body, primary_body.rotational_period)
    end

    # Convenience method for creating an escape orbit around the given body.
    def self.escape_orbit(primary_body, periapsis)
      periapsis_escape_velocity = Math.sqrt(2.0 * primary_body.gravitational_parameter / periapsis)
      return self.new(primary_body, :periapsis => periapsis, :periapsis_velocity => periapsis_escape_velocity)
    end

    def self.hohmann_transfer_parameters(initial_orbit, target_orbit)
    end

    def self.bielliptic_transfer_parameters(initial_orbit, target_orbit)
    end

    def self.inclination_change_parameters(initial_orbit, target_orbit)
    end

    def initialize(primary_body, options={})
      # Set the primary planetoid
      self.primary_body = primary_body

      # Set the periapsis and periapsis_velocity from the options
      replaced_options = replace_orbital_parameters(options)

      # Default all the base parameters to zero if not given.
      process_options(replaced_options, DEFAULT_OPTIONS)
    end

    attr_parameter *BASE_PARAMETERS


    # The body being orbited (required)
    # Expected to be an instance of Planetoid.
    attr_accessor :primary_body

    # The body in orbit (optional)
    # Expected to be an instance of Planetoid.
    attr_accessor :secondary_body

    # Returns the sphere of influence (SOI) for the primary body in the context
    # of the two-body system.
    #
    # This is NOT the KSP SOI, for it, use +kerbal_soi+
    def primary_body_sphere_of_influence
      return self.semimajor_axis * (self.primary_body.mass / self.secondary_body.mass)**(0.4)
    end

    # Returns the sphere of influence (SOI) for the secondary body in the context
    # of the two-body system.
    #
    # This is NOT the KSP SOI, for it, use +kerbal_soi+
    def secondary_body_sphere_of_influence
      return self.semimajor_axis * (self.secondary_body.mass / self.primary_body.mass)**(0.4)
    end
    alias_method :sphere_of_influence, :secondary_body_sphere_of_influence

    # The Hill Sphere radius.
    #
    # This is NOT the KSP SOI, for it, use +kerbal_soi+
    def hill_sphere_radius
      return self.periapsis * (self.secondary_body.mass / (3.0*self.primary_body.mass))**(2.0/3.0)
    end


    # KSP uses this alternate hill sphere radius I found on Wikipedia.
    def kerbal_soi
      return self.semimajor_axis * (self.secondary_body.mass / self.primary_body.mass)**(1.0/3.0)
    end


    # Orbit classification, returns one of :subelliptical, :circular, :elliptical,
    # :parabolic, or :hyperbolic.
    #
    # Because of how floats work, a delta is given for evaluation of "critical"
    # points such as circular and elliptical orbits.  The default value is 1e-9,
    # however other values may be given.
    def classification(delta=0.000000001)
      e = self.eccentricity
      if( e.abs < delta )
        return :circular
      elsif( (e-1.0).abs < delta )
        return :parabolic
      elsif( e > 0.0 && e < 1.0 )
        return :elliptical
      elsif( e > 1.0 )
        return :hyperbolic
      elsif( e < 0.0 )
        return :subelliptical
      end
    end
    alias_method :kind, :classification

    # Returns true if the orbit is a closed orbit (eccentricity < 1)
    def closed?
      return self.eccentricity < 1.0
    end

    # Returns false if the orbit is closed.
    def open?
      return !self.closed?
    end

    # Returns the gravitational parameter for this orbit.
    # Note that this currently is G*M rather than G*(M+m).
    def gravitational_parameter
      return self.primary_body.gravitational_parameter
    end

    # The specific potential energy for any given orbit radius.
    def specific_potential_energy(r)
      return -self.gravitational_parameter / r
    end

    # The specific kinetic energy for any given velocity.
    def specific_kinetic_energy(v)
      return 0.5 * v**2
    end

    # The total specific energyy of the orbit; this is constant over the entire
    # orbit.
    def specific_energy
      return self.specific_potential_energy(self.periapsis) + self.specific_kinetic_energy(self.periapsis_velocity)
    end
    alias_method :vis_viva_energy, :specific_energy

    # The specific angular momentum for this orbit; this is constant over the
    # entire orbit.
    def specific_angular_momentum
      return self.periapsis * self.periapsis_velocity
    end
    alias_method :angular_momentum, :specific_angular_momentum

    # The orbit eccentricity.
    def eccentricity
      return (self.periapsis * self.periapsis_velocity**2 / self.gravitational_parameter) - 1
    end

    # The orbit semimajor-axis.
    def semimajor_axis
      if self.closed?
        return self.periapsis / (1.0 - self.eccentricity)
      else
        return self.periapsis / (self.eccentricity - 1.0)
      end
    end

    # The orbit semiminor_axis, if the eccentricity is less than one.
    def semiminor_axis
      if self.closed?
        return self.semimajor_axis * Math.sqrt(1.0 - self.eccentricity**2)
      else
        return nil
      end
    end

    # The orbital period, if the eccentricity is less than one.
    def period
      if self.closed?
        return 2.0 * Math::PI * Math.sqrt( self.semimajor_axis**3 / self.gravitational_parameter )
      else
        return nil
      end
    end

    # This is the mean angular velocity (angle change per unit time) for this orbit.
    def mean_angular_velocity
      if self.closed?
        return 2.0 * Math::PI / self.period
      else
        return nil
      end
    end

    # This is the mean angular velocity (angle change per unit time) for this orbit.
    #
    # This simply calls +mean_angular_velocity+ on self.
    def mean_motion
      return self.mean_angular_velocity
    end

    # The apoapsis radius, if the eccentricity is less than one.
    def apoapsis
      if self.closed?
        return self.semimajor_axis * (1 + self.eccentricity)
      else
        return nil
      end
    end

    # The apoapsis velocity, if the eccentricity is less than one.
    def apoapsis_velocity
      if self.closed?
        e = self.eccentricity
        k = self.gravitational_parameter / self.semimajor_axis
        return Math.sqrt( (1-e)/(1+e) * k )
      else
        return nil
      end
    end

    private

    # This takes one several sets of base parameters, and derives the periapsis
    # and periapsis_velocity, and then replaces the original keys with them.
    #
    # This is helper method for initialization.
    def replace_orbital_parameters(options)
      # We don't want to mutate the options hash they passed in.
      opts = options.dup

      if( opts.include?(:periapsis) && opts.include?(:periapsis_velocity) )
        return opts
      elsif( opts.include?(:periapsis) && opts.include?(:apoapsis) )
        rp = opts[:periapsis]
        ra = opts.delete(:apoapsis)
        opts[:periapsis_velocity] = Math.sqrt( (2.0 * ra)/(ra+rp) * (self.gravitational_parameter / rp) )
      elsif( opts.include?(:eccentricity) && opts.include?(:semimajor_axis) )
        e = opts.delete(:eccentricity)
        a = opts.delete(:semimajor_axis)
        mu = self.gravitational_parameter
        opts[:periapsis] = rp = a*(1-e)
        opts[:periapsis_velocity] = Math.sqrt( (e+1)*mu/rp )
      elsif( opts.include?(:radius) )
        opts[:periapsis] = opts.delete(:radius)
        # This is a special case of the equation used for apoapsis/periapsis configuration, where they are equal.
        opts[:periapsis_velocity] = Math.sqrt( self.gravitational_parameter / opts[:periapsis] )
      end

      return opts
    end

  end
end
