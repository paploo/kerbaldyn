module KerbalDyn
  # The superclass for all Planetoid and Satellite instances.
  class Body
    include Mixin::ParameterAttributes
    include Mixin::OptionsProcessor
    
    # Options default.  (Unlisted options will be nil)
    DEFAULT_OPTIONS = {
      :mass => 0.0,
      :bounding_sphere_radius => 0.0,
      :angular_velocity => 0.0
    }

    def self.test_particle
      return self.new("Test Particle", :mass => 0.0, :bounding_sphere_radius => 0.0)
    end

    # Initialize this body with the given name and options.
    def initialize(name, options={})
      @name = name
      process_options(options, DEFAULT_OPTIONS)
    end

    # The mass of the body.
    attr_parameter :mass

    # The bounding sphere radius
    attr_parameter :bounding_sphere_radius

    # The angluar velocity around the axis of rotation.
    attr_parameter :angular_velocity

    # The name of the body.
    attr_accessor :name

    # Sets the name of the body.
    def name=(name)
      @name = name && name.to_s
    end

    TEST_PARTICLE = self.test_particle
  end
end
