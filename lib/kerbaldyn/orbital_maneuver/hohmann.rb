module KerbalDyn
  module OrbitalManeuver
    # A special 2-burn orbital maneuver between two circular orbits.
    #
    # The first burn moves the opposite side of the orbit to the radius of
    # the destination orbit, and the second burn--done when reaching the destination
    # radius--moves the opposite side (where you started) to circularize your
    # orbit.
    class Hohmann < Base

      def initialize(initial_orbit, final_orbit, options={})
        raise ArgumentError, "Expected the initial orbit to be circular, but instead it is #{initial_orbit.classification}" unless initial_orbit.classification == :circular
        raise ArgumentError, "Expected the final orbit to be circular, but instead it is #{final_orbit.classification}" unless final_orbit.classification == :circular
        super
      end

      # The total delta velocity necessary.
      #
      # This is the sum of the <b>absolute values<b> of each burn's delta-v.
      def delta_velocity
        return delta_v1.abs + delta_v2.abs
      end

      # This is the period of the transfer orbit between the initial burn and
      # the final burn.  This should
      def delta_time
        return transfer_orbit.period / 2.0
      end

      # Returns true if we are moving into a higher orbit
      def moving_to_higher_orbit?
        return final_orbit.semimajor_axis > initial_orbit.semimajor_axis
      end

      # The elliptical orbit used to transfer from the initial_orbit to the
      # final_orbit.
      def transfer_orbit
        r1 = initial_orbit.semimajor_axis
        r2 = final_orbit.semimajor_axis
        periapsis = [r1,r2].min
        apoapsis = [r1,r2].max
        return Orbit.new(self.initial_orbit.primary_body, :periapsis => periapsis, :apoapsis => apoapsis)
      end

      # Delta-v for the first burn.  If this is positive, it is a prograde burn,
      # if it is negative, it is a retrograde burn.
      def delta_v1
        # We can use either periapsis or apoapsis velocity since the initial orbit is round, but periapsis is faster..
        return self.transfer_v1 - self.initial_orbit.periapsis_velocity
      end

      # Delta-v for the second burn.  If this is positive, it is a prograde burn,
      # if it is negative, it is a retrograde burn.
      def delta_v2
        # We can use either periapsis or apoapsis velocity since hte initial orbit is round, but periapsis is faster.
        return self.final_orbit.periapsis_velocity - self.transfer_v2
      end

      # Your transfer velocity in the initial orbit.
      def transfer_v1
        return self.moving_to_higher_orbit? ? self.transfer_orbit.periapsis_velocity : self.transfer_orbit.apoapsis_velocity
      end

      # Your transfer velocity in the final orbit.
      def transfer_v2
        return self.moving_to_higher_orbit? ? self.transfer_orbit.apoapsis_velocity : self.transfer_orbit.periapsis_velocity
      end

      # This lead angle for intercept of a body in the destination orbit.
      #
      # This is measured as the difference of your position from their position,
      # so zero degrees means you both have the same anomaly, and positive values
      # are tha anomaly angle they should lead you by.
      def lead_angle
        # This is the angle traversed by the target during the transfer orbit period,
        # with positive angles leading back in time further and further.
        target_angle_traversed = (Math::PI / Math.sqrt(8.0)) * Math.sqrt(self.radius_ratio + 1.0)**1.5
        # We when subtract this from 180.0, which is the start angel for us
        # relative to the meet-up time.
        return Math::PI - target_angle_traveresed
      end

      # This is the amount the relative anomaly changes per full orbit.
      # Positive values mean that the angle is getting larger so you are falling
      # behind the target, and negative values mean the angle is getting smaller
      # so you are gaining on the target.
      def relative_anomaly_change
        return 2.0 * Math::PI * (self.final_orbit.angular_velocity - self.initial_orbit.angular_velocity)
      end

      # The ratio of the destination orbit radius over the initial orbit radius.
      # Ratios greater than one are a move to a higher orbit.
      def radius_ratio
        return self.destination_orbit.semimajor_axis / self.initial_orbit.semimajor_axis
      end

    end
  end
end
