module KerbalDyn

  # Planetoid is the superclass of any planetary object.  It is primarily used
  # to build existing planetoids via factory methods to calculate orbit
  # characteristics around the planetoid.
  class Planetoid

    def self.kerbin
      return @kerbin ||= self.new('Kerbin', 5.29e22, 600e3, :rotational_period => 6.0*3600.0)
    end

    def self.kerbol
      return @kerbol ||= self.new('Kerbol', 1.75e28, 65400e3)
    end

    # Metaprogramming method for setting physical parameters, which are
    # always of float type.
    def self.attr_param(*params)
      params.each do |param|
        attr_reader param

        setter_line = __LINE__ + 1
        setter = <<-METHOD
          def #{param}=(value)
            @#{param} = value && value.to_f
          end
        METHOD
        class_eval(setter, __FILE__, setter_line)
      end
    end

    def initialize(name, mass, radius, opts={})
      self.name = name

      self.mass = mass
      self.radius = radius

      opts.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    attr_param :mass, :radius, :rotational_period

    attr_reader :name

    def name=(name)
      @name = name && name.to_s
    end

    # Convert the given radius to an altitude.
    def radius_to_alt(r)
      return r - self.radius
    end

    # Convert the given altitude into a radius.
    def alt_to_radius(h)
      return self.radius + h
    end

    # Returns the gravtiational_parameter (G*M) of the planetoid.
    def gravitational_parameter
      KerbalDyn::G * self.mass
    end

    # Returns the gravitational accelaration at a given radius from the
    # center of the planet.
    def gravitational_acceleration(r)
      return self.gravitational_parameter / r**2
    end

    # Returns the gravitational force acting on an object of mass m at the given
    # radius from the center of the planet.
    def gravitational_force(m, r)
      return m * gravitational_acceleration(r)
    end

    # Returns the surface gravity (acceleration) of this planetoid.
    #
    # If a value is given, then this is used as the height above the surface
    # to calculate the gravity.
    def surface_gravity(h=0.0)
      return self.gravitational_acceleration( self.alt_to_radius(h) )
    end

    # The volume of the planetoid.
    def volume
      return (4.0/3.0) * Math::PI * self.radius**3
    end

    # The density of the planetoid.
    def density
      return self.mass / self.volume
    end

    # The rotational angular velocity of the planetoid.
    def rotational_velocity
      return 2.0 * Math::PI / self.rotational_period
    end

    # Equitorial linear velocity of the planetoid.
    #
    # If a value is gien, then this is used as the height above the surface for
    # the calculation.
    def equitorial_velocity(h=0.0)
      return self.rotational_velocity * (self.radius + h)
    end

    # Calculates the escape velocity of the planetoid.
    def escape_velocity
      return Math.sqrt( 2.0 * self.gravitational_parameter / self.radius )
    end

    # Calculates the velocity needed to maintain a circular orbit at a given radius.
    def circular_orbit_velocity(r)
      return Math.sqrt( self.gravitational_parameter / r )
    end

    # Calculates the angular velocity of a circular oribt at the given radius.
    def circular_orbit_angular_velocity(r)
      return self.circular_orbit_velocity(r) / r
    end

    # Calculates the period of a circular oribt at the given radius.
    def circular_orbit_period(r)
      return 2.0 * Math::PI / self.circular_orbit_angular_velocity(r)
    end

    # Calculates the velocity needed to maintain a circular orbit with the
    # given period.
    def circular_orbit_velocity_with_period(t)
      return self.circular_orbit_radius_with_period(t) * self.rotational_velocity
    end

    # Calculates the radius of the orbit with the given period.
    def circular_orbit_radius_with_period(t)
      omega = 2.0 * Math::PI / t
      return (self.gravitational_parameter / omega**2 )**(1.0/3.0)
    end

    # Calculates the orbital radius of the geostationary orbit.
    def geostationary_orbit_radius
      return self.circular_orbit_radius_with_period( self.rotational_period )
    end

    # Calculates the orbital <em>altitude</em> of the geostationary orbit.
    def geostationary_orbit_altitude
      return self.radius_to_alt( self.geostationary_orbit_radius )
    end

    # Calculates the linear velocity of the geostationary orbit.
    def geostationary_orbit_velocity
      return self.circular_orbit_velocity_with_period( self.rotational_period )
    end

    # Calculate the Hohmann transfter parameters going from an orbital radius
    # of h1 to an orbital radius of h2.
    def hohmann_transfer_orbit(r1, r2)
      # Get circular orbit velocities.
      vc1 = self.circular_orbit_velocity(r1)
      vc2 = self.circular_orbit_velocity(r2)

      # Calculate semi-major axis
      a = (r1 + r2) / 2.0

      # Calculate period of transfer
      t = 2 * Math::PI * Math.sqrt( a**3 / self.gravitational_parameter )

      # Calculate delta v's
      dv1 = (Math.sqrt(r2/a) - 1) * vc1
      dv2 = (1 - Math.sqrt(r1/a)) * vc2

      # Burn Parameters
      burn_one = {:from_velocity => vc1, :to_velocity => vc1+dv1, :delta_velocity => dv1, :radius => r1, :altitude => self.radius_to_alt(r1)}
      burn_two = {:from_velocity => vc2-dv2, :to_velocity => vc2, :delta_velocity => dv2, :radius => r2, :altitude => self.radius_to_alt(r2)}

      # Return
      return {:burn_one => burn_one, :burn_two => burn_two}
    end

    # Calculate the Hohmann transfer parameters going from an altitude of
    # h1 to an altitude of h2.
    def hohmann_transfer_orbit_by_altitude(h1, h2)
      return transfer_orbit( alt_to_radius(h1), alt_to_radius(h2) )
    end

    alias_method :m, :mass
    alias_method :r, :radius
    alias_method :t, :rotational_period
    alias_method :g, :surface_gravity
    alias_method :rho, :density
    alias_method :mu, :gravitational_parameter


    KERBIN = self.kerbin
    KERBOL = self.kerbol

  end
end
