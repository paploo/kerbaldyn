module KerbalDyn
  # The namespace for all orbital maneuvers
  module OrbitalManeuver
    # The base-class for all orbital maneuvers.
    class Base
      include Mixin::OptionsProcessor
      include Mixin::ParameterAttributes

      def initialize(initial_orbit, final_orbit, options={})
        raise ArgumentError, "Expected the initial and final orbit to orbit the same body." unless initial_orbit.primary_body == final_orbit.primary_body
        self.initial_orbit = initial_orbit
        self.final_orbit = final_orbit
        process_options(options)
      end

      # The orbit you are starting at.
      attr_accessor :initial_orbit

      # The orbit you are going to maneuver into.
      attr_accessor :final_orbit

      # Calculates the total delta-v for this maneuver.
      #
      # This is always a positive quantity that relates the total amount of
      # velocity change necessary, and hence a sense of the total amount of
      # fuel used during the maneuver.
      def delta_velocity
        raise NotImplementedError, "#{__method__} not implemented on #{self.class.name}."
      end

      # An alias to delta_velocity.
      #
      # Implemented as a method to be sure to invoke the subclass' implementation
      # of delta_v.
      def delta_v
        return self.delta_velocity
      end

      # Calculates the total time for completion.
      #
      # For some kinds of idealized maneuvers this may be meaningless, in which
      # case nil is returned.
      def delta_time
        return nil
      end

      # An alias to delta_time.
      #
      # Implemented as a method to be sure to invoke the subclass' implementation
      # of delta_time.
      def delta_t
        return self.delta_time
      end

    end
  end
end
