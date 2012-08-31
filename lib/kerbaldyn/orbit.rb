module KerbalDyn
  class Orbit
    include Mixin::ParameterAttributeHelper

    BASE_PARAMETERS = [:semimajor_axis, :eccentricity, :inclination, :longitude_of_ascending_node, :argument_of_periapsis, :mean_anomaly, :epoch]

    def initialize(primary_planetoid, semimajor_axis, opts={})
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

    def semiminor_axis
      return self.semimajor_axis * Math.sqrt(1.0 - self.eccentricity**2)
    end

    def semilatus_rectum
      return self.semimajor_axis * (1.0 - self.eccentricity**2)
    end

    def gravitational_parameter
      if( secondary_planetoid )
        return KerbalDyn::G * (self.primary_planetoid.mass + self.secondary_planetoid.mass)
      else
        return self.primary_planetoid.gravitational_parameter
      end
    end

    def period
      return 2.0 * Math::PI * Math.sqrt( self.semimajor_axis**3 / self.gravitational_parameter )
    end

  end
end
