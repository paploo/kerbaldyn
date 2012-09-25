module KerbalDyn

  # Planetoid is the superclass of any planetary object.  It is primarily used
  # to build existing planetoids via factory methods to calculate orbit
  # characteristics around the planetoid.
  #
  # Most interesting parameters are included through the DerivedParameters module.
  class Planetoid < Body

    # For data read in from data files, this private method DRYs the process.
    def self.make(planet_ref)
      data = Data.fetch(:planet_data)[planet_ref][:planetoid]
      name = data[:name]
      parameters = data.reject {|k,v| k == :name}
      return self.new(name, parameters).freeze
    end

    class << self
      private :make
    end

    # :category: Library Methods
    # The Kerbal Sun.
    def self.kerbol
      # TODO: Refactor to calculate these from data on-the-fly (need to output that kind of data first).
      #
      # Grav Parameter calculated from semimajor axis and velocity vector dumps via mu = a*v**2, and is good to around the 15th digit.
      # Radius calculated by subtracting Kerbin Apa from Apr in data dump
      return @kerbol ||= self.new('Kerbol', :gravitational_parameter => 1172332794832492300.0, :radius => 261600000).freeze
    end

    # :category: Library Methods
    #The Earth-like Homeworld.
    def self.kerbin
      return @kerbin ||= make(__method__)
    end

    # :category: Library Methods
    # The Moon equivalient; orbits Kerbin.
    def self.mun
      return @mun ||= make(__method__)
    end

    # :category: Library Methods
    # A small outter moon of Kerbin; no Solar System equivalent.
    def self.minmus
      return @minmus ||= make(__method__)
    end

    # :category: Library Methods
    # The inner planet (Mercury like)
    def self.moho
      return @moho ||= make(__method__)
    end

    # :category: Library Methods
    # The second planet (Venus like)
    def self.eve
      return @eve ||= make(__method__)
    end

    # :category: Library Methods
    # The asteroid moon of Gilly
    def self.gilly
      return @gilly ||= make(__method__)
    end

    # :category: Library Methods
    # The fourth planet (Mars like)
    def self.duna
      return @duna ||= make(__method__)
    end

    # :category: Library Methods
    # The moon of Duna
    def self.ike
      return @ike ||= make(__method__)
    end

    # :category: Library Methods
    # The fifth planet (Jupiter like)
    def self.jool
      return @jool ||= make(__method__)
    end

    # :category: Library Methods
    # The first moon of Jool, ocean moon with atmosphere
    def self.laythe
      return @laythe ||= make(__method__)
    end

    # :category: Library Methods
    # The second moon of Jool, ice moon
    def self.vall
      return @vall ||= make(__method__)
    end

    # :category: Library Methods
    # The third moon of Jool, rocky
    def self.tylo
      return @tylo ||= make(__method__)
    end

    # :category: Library Methods
    # The captured asteroid around Jool.
    def self.bop
      return @bop ||= make(__method__)
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

    # ===== Orbit Library Methods =====

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
