module KerbalDyn
  class Orbit
    include Mixin::ParameterAttributes
    include Mixin::OptionsProcessor

    BASE_PARAMETERS = [:periapsis, :periapsis_velocity, :inclination, :longitude_of_ascending_node, :argument_of_periapsis, :mean_anomaly, :epoch]
    DEFAULT_OPTIONS = BASE_PARAMETERS.inject({}) {|opts,param| opts[param] = 0.0; opts}.merge(:secondary_body => Body::TEST_PARTICLE)

    # This is redundant to calling new with the option of :radius.
    def self.circular_orbit(primary_body, radius)
      return self.new(primary_body, :radius => radius)
    end

    def self.circular_orbit_of_period(primary_body, period)
      planetoid_angular_velocity = 2.0 * Math::PI / period
      radius = (primary_body.gravitational_parameter / planetoid_angular_velocity**2)**(1.0/3.0)
      return self.circular_orbit(primary_body, radius)
    end

    def self.geostationary_orbit(primary_body)
      return self.circular_orbit_of_period(primary_body, primary_body.rotational_period)
    end

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

    def kind
      e = self.eccentricity
      if( e < 0.0 )
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

    def closed?
      return self.eccentricity < 1.0
    end

    def open?
      return !self.closed?
    end

    def gravitational_parameter
      return self.primary_body.gravitational_parameter
    end

    def potential_energy(r)
      return -self.gravitational_parameter / r
    end

    def kinetic_energy(v)
      return 0.5 * v**2
    end

    def specific_energy
      return self.potential_energy(self.periapsis) + self.kinetic_energy(self.periapsis_velocity)
    end
    alias_method :energy, :specific_energy
    alias_method :vis_viva_energy, :specific_energy

    def specific_angular_momentum
      return self.periapsis * self.periapsis_velocity
    end
    alias_method :angular_momentum, :specific_angular_momentum

    def eccentricity
      c = (2.0 * self.specific_energy * self.specific_angular_momentum**2) / (self.gravitational_parameter**2)
      return Math.sqrt(1.0 + c)
    end

    def semimajor_axis
      if self.closed?
        return self.periapsis / (1.0 - self.eccentricity)
      else
        return self.periapsis / (self.eccentricity - 1.0)
      end
    end

    def semiminor_axis
      if self.closed?
        return self.semimajor_axis * Math.sqrt(1.0 - self.eccentricity**2)
      else
        return nil
      end
    end

    def period
      if self.closed?
        return 2.0 * Math::PI * Math.sqrt( self.semimajor_axis**3 / self.gravitational_parameter )
      else
        return nil
      end
    end

    def apoapsis
      if self.closed?
        return self.semimajor_axis * (1 + self.eccentricity)
      else
        return nil
      end
    end

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

    # This takes one of the following sets of parameters, derives periapsis and
    # periapsis_velocity, and then replaces the original keys with them.
    def replace_orbital_parameters(options)
      opts = options.dup

      if( options.include?(:periapsis) && options.include?(:periapsis_velocity) )
        return options
      elsif( options.include?(:periapsis) && options.include?(:apoapsis) )
        raise NotImplementedError
      elsif( options.include?(:eccentricity) && options.include(:semimajor_axis) )
        raise NotImplementedError
      elsif( options.include?(:radius) )
        opts[:periapsis] = opts.delete(:radius)
        opts[:periapsis_velocity] = Math.sqrt( self.gravitational_parameter / opts[:periapsis] )
      end

      return opts
    end

  end
end
