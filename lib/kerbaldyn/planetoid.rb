module KerbalDyn

  # Planetoid is the superclass of any planetary object.  It is primarily used
  # to build existing planetoids via factory methods to calculate orbit
  # characteristics around the planetoid.
  #
  # Most interesting parameters are included through the DerivedParameters module.
  class Planetoid < Body

    def self.kerbol
      # Grav Parameter calculated from semimajor axis and velocity vector dumps via mu = a*v**2, and is good to around the 15th digit.
      # Radius calculated by subtracting Apa from Apr in data dump
      return @kerbol ||= self.new('Kerbol', :gravitational_parameter => 1172332794832492300.0, :radius => 261600000).freeze
    end

    def self.kerbin
      return @kerbin ||= self.new('Kerbin', :gravitational_parameter => 3531600000000.0, :radius => 600000.0, :rotational_period => 21600.0).freeze
    end

    def self.mun
      return @mun ||= self.new('Mun', :gravitational_parameter => 65138397520.7806, :radius => 200000.0, :rotational_period => 138984.376574476).freeze
    end

    def self.minmus
      return @minmus ||= self.new('Minmus', :gravitational_parameter => 1765800026.31247, :radius => 60000.0, :rotational_period => 40400).freeze
    end

    def initialize(name, options={})
      super
    end

    alias_parameter :radius, :bounding_sphere_radius

    # Returns the gravtiational_parameter (G*M) of the planetoid.
    def gravitational_parameter
      Constants::G * self.mass
    end

    # Sets the gravitational parameter (G*M) by deriving the mass and setting it.
    def gravitational_parameter=(mu)
      self.send(:mass=, mu / Constants::G)
    end
    private :gravitational_parameter=

    # The rotational period of this body around its axis.
    def rotational_period
      return 2.0 * Math::PI / self.angular_velocity
    end

    # Set the rotational period of this body.
    def rotational_period=(period)
      self.angular_velocity = period && (2.0 * Math::PI / period)
    end

    # Returns the gravitational accelaration at a given radius from the
    # center of the planet.
    def gravitational_acceleration(r)
      return self.gravitational_parameter / r**2
    end

    # Returns the surface gravity (acceleration) of this planetoid.
    #
    # If a value is given, then this is used as the height above the surface
    # to calculate the gravity.
    def surface_gravity(h=0.0)
      return self.gravitational_acceleration( self.radius + h )
    end

    # The volume of the planetoid.
    def volume
      return (4.0/3.0) * Math::PI * self.radius**3
    end

    # The density of the planetoid.
    def density
      return self.mass / self.volume
    end

    # Equitorial linear velocity of the planetoid.
    #
    # If a value is gien, then this is used as the height above the surface for
    # the calculation.
    def equitorial_velocity(h=0.0)
      return self.angular_velocity * (self.radius + h)
    end

    # Equitorial linear velocity of the planetoid.
    #
    # If a value is gien, then this is used as the height above the surface for
    # the calculation.
    def equitorial_velocity(h=0.0)
      return self.angular_velocity * (self.radius + h)
    end

    # Calculates the escape velocity of the planetoid.
    def escape_velocity
      return Math.sqrt( 2.0 * self.gravitational_parameter / self.radius )
    end

    # ===== Orbit Factory Methods =====

    def geostationary_orbit
      return Orbit.geostationary_orbit(self)
    end

    def circular_orbit(radius)
      return Orbit.circular_orbit(self, radius)
    end

    def circular_orbit_of_period(period)
      return Orbit.circular_orbit_of_period(self, period)
    end

    def escape_orbit(periapsis)
      return Orbit.escape_orbit(self, periapsis)
    end

    def self.orbit(options={})
      return Orbit.new(self, options)
    end

    # ===== ALIASES =====

    alias_method :m, :mass
    alias_method :r, :radius
    alias_method :t, :rotational_period
    alias_method :g, :surface_gravity
    alias_method :rho, :density
    alias_method :mu, :gravitational_parameter

  end
end
