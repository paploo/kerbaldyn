module KerbalDyn
  # The namespace for all orbital maneuvers
  module OrbitalManeuver
    # The base-class for all orbital maneuvers.
    class Base
      include Mixin::OptionsProcessor
      include Mixin::ParameterAttributes

      def initialize(initial_orbit, final_orbit, options={})
        # For now this is a safe thing to do, *way* in the future we may have to differentiate
        # between complex maneuvers to other systems and maneuvers within the system.
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
      #
      # The baseclass implementation is to sum the absolute values of the
      # deltas in the velocity list +delta_velocities+.
      def delta_velocity
        return self.delta_velocities.reduce(0) {|a,b| a.abs + b.abs}
      end

      # An alias to delta_velocity.
      def delta_v
        return self.delta_velocity
      end

      # Calculates the total time for completion.
      #
      # For some kinds of idealized maneuvers this may be meaningless, in which
      # case nil is returned.
      #
      # Subclasses should override this.
      def delta_time
        return nil
      end

      # An alias to delta_time.
      def delta_t
        return self.delta_time
      end

      # The list of velocity deltas.
      #
      # For most kinds of maneuvers, the signedness of the delta is meaningful.
      # For example, prograde burns are usually positive, and retrograde burns
      # are usually negative.
      #
      # Subclasses should override this.
      def delta_velocities
        return []
      end

    end
  end
end
