module KerbalDyn
  class Orbit
    include Mixin::ParameterAttributes
    include Mixin::OptionsProcessor

    BASE_PARAMETERS = [:periapsis, :periapsis_velocity, :inclination, :longitude_of_ascending_node, :argument_of_periapsis, :mean_anomaly, :epoch]
    DEFAULT_OPTIONS = BASE_PARAMETERS.inject({}) {|opts,param| opts[param] = 0.0; opts}.merge(:secondary_body => Body::TEST_PARTICLE)

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
      return self.new(:periapsis => periapsis, :periapsis_velocity => periapsis_escape_velocity)
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
    def primary_body_sphere_of_influence
      return self.semimajor_axis * (self.primary_body.mass / self.secondary_body.mass)**(0.4)
    end

    # Returns the sphere of influence (SOI) for the secondary body in the context
    # of the two-body system.
    def secondary_body_sphere_of_influence
      return self.semimajor_axis * (self.secondary_body.mass / self.primary_body.mass)**(0.4)
    end
    alias_method :sphere_of_influence, :secondary_body_sphere_of_influence

    # Orbit classification, returns one of :subelliptical, :circular, :elliptical,
    # :parabolic, or :hyperbolic.
    def kind
      e = self.eccentricity
      if( e < 0.0 )
        return :subelliptical
      elsif( e == 0.0 )
        return :circular
      elsif( e > 0.0 && e < 1.0 )
        return :elliptical
      elsif( e == 1.0 )
        return :parabolic
      else
        return :hyperbolic
      end
    end

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
    def potential_energy(r)
      return -self.gravitational_parameter / r
    end

    # THe specific kinetic energy for any given velocity.
    def kinetic_energy(v)
      return 0.5 * v**2
    end

    # The total specific energyy of the orbit; this is constant over the entire
    # orbit.
    def specific_energy
      return self.potential_energy(self.periapsis) + self.kinetic_energy(self.periapsis_velocity)
    end
    alias_method :energy, :specific_energy
    alias_method :vis_viva_energy, :specific_energy

    # The specific angular momentum for this orbit; this is constant over the
    # entire orbit.
    def specific_angular_momentum
      return self.periapsis * self.periapsis_velocity
    end
    alias_method :angular_momentum, :specific_angular_momentum

    # The orbit eccentricity.
    def eccentricity
      c = (2.0 * self.specific_energy * self.specific_angular_momentum**2) / (self.gravitational_parameter**2)
      return Math.sqrt(1.0 + c)
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
