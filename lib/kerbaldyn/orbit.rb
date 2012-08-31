module KerbalDyn
  class Orbit
    include Mixin::ParameterAttributeHelper

    BASE_PARAMETERS = [:semimajor_axis, :eccentricity, :inclination, :longitude_of_ascending_node, :argument_of_periapsis, :mean_anomaly, :epoch]

    def initialize(primary_planetoid, options={})
      self.semimajor_axis = semimajor_axis

      # Default all the base parameters to zero if not given.
      BASE_PARAMETERS.each do |param|
        next if param == :semimajor_axis # This is required and not in opts.
        self.send("#{param}=", opts.fetch(param, 0.0))
      end

      self.primary_planetoid = primary_planetoid
      self.secondary_planetoid = opts[:secondary_planetoid]
    end

    attr_parameter *BASE_PARAMETERS


    # The body being orbited (required)
    # Expected to be an instance of Planetoid.
    attr_accessor :primary_planetoid

    # The body in orbit (optional)
    # Expected to be an instance of Planetoid.
    attr_accessor :secondary_planetoid

    def kind
      e = self.eccintricity
      if( e < 0.0 )
        return :subelliptical
      elsif( e >= 0.0 && e < 1.0 )
        return :elliptical
      elsif( e == 1.0 )
        return :parabolic
      else
        return :hyperbolic
      end
    end

    def semiminor_axis
      return self.semimajor_axis * Math.sqrt(1.0 - self.eccentricity**2)
    end

    def semilatus_rectum
      return self.semimajor_axis * (1.0 - self.eccentricity**2)
    end

    def gravitational_parameter
      return self.primary_planetoid.gravitational_parameter
    end

    def period
      return 2.0 * Math::PI * Math.sqrt( self.semimajor_axis**3 / self.gravitational_parameter )
    end

    def angular_momentum
      return Math.sqrt( self.semilatus_rectum * self.gravitational_parameter )
    end

    def potential_energy(r)
      return -self.gravitational_parameter / r
    end

    def kinetic_energy(v)
      return 0.5 * v**2
    end

    def energy
      return -self.gravitational_parameter / (2*self.semimajor_axis)
    end
    alias_method :specific_orbital_energy, :energy
    alias_method :vis_viva_energy, :energy

    def apoapsis
      if self.kind == :elliptical
        return self.semimajor_axis * (1 + self.eccentricity)
      else
        return nil
      end
    end

    def periapsis
      if self.kind == :elliptical
        return self.semimajor_axis * (1 - self.eccentricity)
      else
        return self.semimajor_axis * (self.eccentricity - 1)
      end
    end

    def apoapsis_velocity
      if self.kind == :elliptical
        e = self.eccentricity
        k = self.gravitational_parameter / self.semimajor_axis
        return Math.sqrt( (1-e)/(1+e) * k )
      else
        return nil
      end
    end

    def periapsis_velocity
      e = self.eccentricity
      k = self.gravitational_parameter / self.semimajor_axis
      if self.kind == :elliptical
        return Math.sqrt( (1+e)/(1-e) * k )
      else
        raise NotImplementedError
      end
    end

  end
end
