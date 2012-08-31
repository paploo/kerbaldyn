module KerbalDyn
  class Planetoid < Body
    # A module of derived parameters.  These depend on mass, radius,
    # and rotational period.
    module DerivedParameters

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

    end
  end
end
