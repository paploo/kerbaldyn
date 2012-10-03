module KerbalDyn
  module OrbitalManeuver
    # Encapsulates information about a burn event.
    class BurnEvent
      include Mixin::ParameterAttributes
      include Mixin::OptionsProcessor

      # Create a new burn event.
      #
      # The following parameters are expected to be given:
      # [initial_velocity] The velocity before the burn.
      # [final_velocity] The velocity after the burn.
      # [time] The time of the burn.
      # [orbital_radius] The orbital radius at the time of the burn.
      # [mean_anomaly] The mean anomaly at the time of the burn.
      #
      # The following parameters are optional.
      # [epoch] Used to offset the time.
      def initialize(options={})
        process_options(options, :epoch => 0.0)
      end

      # The velocity before burn.
      attr_parameter :initial_velocity

      # The velocity after the burn.
      attr_parameter :final_velocity

      # The time for the burn.
      attr_parameter :time

      # The epoch for when time is zero. (optional)
      attr_parameter :epoch

      # The orbital radius at the time of the burn.
      attr_parameter :orbital_radius

      # The mean anomaly at the time of the burn.
      attr_parameter :mean_anomaly

      # Returns the change in velocity for this maneuver.
      #
      # Note that the sign may be meaningful to the maneuver.  For example,
      # a retrograde burn is usually negative.
      def delta_velocity
        return self.final_velocity - self.initial_velocity
      end
      alias_method :delta_v, :delta_velocity

      # Gives the time of this event in epoch time if epoch was set.
      def epoch_time
        return time + epoch
      end

    end
  end
end
