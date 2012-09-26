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

    # A quick-reference system structure data structure.  Each parent body has a key with an array of children.  Subsequent hits are necessary for additional lookups.
    #SYSTEM_STRUCTURE = {:kerbol => [:moho, :eve, :kerbin, :duna, :jool], :eve => [:gilly], :kerbin => [:mun, :minmus], :duna => [:ike], :jool => [:laythe, :vall, :tylo, :bop]}.each do |primary, secondaries|

    # For data read in from data files, this private method DRYs the process.
    def self.make(planet_ref)
      # Get the data and dup it so we can muck with it.
      data = Data.fetch(:planet_data)[planet_ref][:orbit].dup
      # Get the primary/secondary body refs from it and then lookup to get the values.
      primary_body = Planetoid.send( data.delete(:primary_body) )
      secondary_body = Planetoid.send( data.delete(:secondary_body) )
      # Now construct the object.
      return self.new( primary_body, data.merge(:secondary_body => secondary_body) ).freeze
    end

    class << self
      private :make
    end

    # :category: Library Methods
    def self.kerbin
      return @kerbin ||= make(__method__)
    end

    # :category: Library Methods
    def self.mun
      return @mun ||= make(__method__)
    end

    # :category: Library Methods
    def self.minmus
      return @minmus ||= make(__method__)
    end

    # :category: Library Methods
    def self.moho
      return @moho ||= make(__method__)
    end

    # :category: Library Methods
    def self.eve
      return @eve ||= make(__method__)
    end

    # :category: Library Methods
    def self.gilly
      return @gilly ||= make(__method__)
    end

    # :category: Library Methods
    def self.duna
      return @duna ||= make(__method__)
    end

    # :category: Library Methods
    def self.ike
      return @ike ||= make(__method__)
    end

    # :category: Library Methods
    def self.jool
      return @jool ||= make(__method__)
    end

    # :category: Library Methods
    def self.laythe
      return @laythe ||= make(__method__)
    end

    # :category: Library Methods
    def self.vall
      return @vall ||= make(__method__)
    end

    # :category: Library Methods
    def self.tylo
      return @tylo ||= make(__method__)
    end

    # :category: Library Methods
    def self.bop
      return @bop ||= make(__method__)
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
    # This is NOT the KSP SOI, for it, use +kerbal_sphere_of_influence+
    def primary_body_sphere_of_influence
      return self.semimajor_axis * (self.primary_body.mass / self.secondary_body.mass)**(0.4)
    end

    # Returns the sphere of influence (SOI) for the secondary body in the context
    # of the two-body system.
    #
    # This is NOT the KSP SOI, for it, use +kerbal_sphere_of_influence+
    def secondary_body_sphere_of_influence
      return self.semimajor_axis * (self.secondary_body.mass / self.primary_body.mass)**(0.4)
    end
    alias_method :sphere_of_influence, :secondary_body_sphere_of_influence

    # The Hill Sphere radius.
    #
    # This is NOT the KSP SOI, for it, use +kerbal_sphere_of_influence+
    def hill_sphere_radius
      return self.periapsis * (self.secondary_body.mass / (3.0*self.primary_body.mass))**(2.0/3.0)
    end


    # KSP uses this alternate hill sphere radius I found on Wikipedia.
    def kerbal_sphere_of_influence
      return self.periapsis * (self.secondary_body.mass / self.primary_body.mass)**(1.0/3.0)
    end
    alias_method :kerbal_soi, :kerbal_sphere_of_influence


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

    # This is the velocity associated with the mean motion at the semimajor axis,
    # This works out to be the velocity of an object in a circular orbit with the same period.
    def mean_velocity
      return self.mean_motion * self.semimajor_axis
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

    # Instantiates a new orbit with the same period and semimajor axis, zero
    # inclination, and is circular.
    #
    # This is useful for idealizing orbits for rough calculations.
    #--
    # TODO: Figure out how to translate parameters such as mean anomaly and LAN.
    #++
    def circularize
      return self.class.new(primary_body, {
        :secondary_body => self.secondary_body,
        :radius => self.semimajor_axis,
        :inclination => 0.0
      })
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
