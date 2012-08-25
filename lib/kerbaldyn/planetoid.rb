require_relative 'planetoid/derived_parameters'
require_relative 'planetoid/data'

module KerbalDyn

  # Planetoid is the superclass of any planetary object.  It is primarily used
  # to build existing planetoids via factory methods to calculate orbit
  # characteristics around the planetoid.
  #
  # Most interesting parameters are included through the DerivedParameters module.
  class Planetoid

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

    # Include the derived parameters based on mass, radius, and rotational period.
    include DerivedParameters


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

    include Data

    # Data for the planet Kerbin.
    # Equivalent to calling the class factory method.
    KERBIN = self.kerbin

    # Data for the sun of Kerbol.
    # Equivalent to calling the class factory method.
    KERBOL = self.kerbol

    # Data for the moon of Mun.
    # Equivalent to calling the class factory method.
    MUN = self.mun

    # Data for the moon of Minmus.
    # Equivalent to calling the class factory method.
    MINMUS = self.minmus
  end
end
