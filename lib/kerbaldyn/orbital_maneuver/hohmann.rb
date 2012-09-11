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
        # Easy calculation:
        # theta_f1 = theta_01 + Math::PI        (The "spaceship" will travel 180 degrees during the transfer)
        # theta_f2 = theta_02 + omega_2*delta_t (The target body will travel omega_2*delta_t during the transfer)
        #
        # theta_f1 = theta_f2                   (They must both be at the same final place for an incercept)
        # delta_theta := theta_02 - theta_01
        #
        # Therefore: delta_theta = Math::PI - omega_2*delta_t
        return Math::PI - self.final_orbit.mean_angular_velocity * self.delta_time

        # Another solution involves the same logic, but using periods, and gives
        # rise to the following analytic solution:
        #
        # This is the angle traversed by the target during the transfer orbit period,
        # with positive angles leading back in time further and further.
        rp_over_ra = 1.0 / self.radius_ratio
        target_angle_traversed = (Math::PI / Math.sqrt(8.0)) * (rp_over_ra + 1.0)**1.5
        # We when subtract this from 180.0, which is the start angel for us
        # relative to the meet-up time.
        return Math::PI - target_angle_traversed
      end

      # The time elapsed such that--if started when the target is directly radial
      # from you (same true anomaly)--you would start your transfer orbit in order
      # to intercept.
      def lead_time
        # theta_f1 = theta_01 + omega_1*t
        # theta_f2 = theta_02 + omega_2*t
        # theta_f2 - theta_f1 = theta_lead  (After time t, we want to achieve lead angle)
        # theta_02 - theta_01 = 0           (When we start the clock, we want no separation)
        #
        # Thefefore: theta_lead = (omega_2 - omega_1) * t
        #
        # We also have to find the offset (n*2*pi) to the lead angle that will lead to the
        # first positive time.  This depends on wether delta_omega is positive or
        # negative.
        delta_omega = self.final_orbit.mean_angular_velocity - self.initial_orbit.mean_angular_velocity

        two_pi = 2.0*Math::PI
        theta_lead = (self.lead_angle % two_pi)
        theta_lead = (delta_omega>0.0) ? theta_lead : (theta_lead-two_pi)

        return theta_lead / delta_omega
      end

      # For every full cycle of the initial orbit (2pi radians), the final orbit
      # covers either less than 2pi radians (if it is bigger) or more than 2pi radians
      # (if it is smaller) in the same amount of time.  The relative_delta_anomaly
      # is the change difference covered.
      #
      # If it is positive, then the initial orbit is slower,
      # If it is zero, then they are in lock-step,
      # If it is negative, then the initial orbit is faster.
      #
      # Note that for a large orbit ratio, going from the lower to higher orbit
      # will have a very negative anomaly close to -2pi (the target didn't move much
      # much , while you did your rotation), while going from a higher to lower
      # orbit has a high positive number (the target did a lot of laps while you
      # were waiting for it.
      def relative_anomaly_delta
        initial_orbit_anomaly = 2.0 * Math::PI
        final_orbit_anomaly = 2.0 * Math::PI * (self.initial_orbit.period / self.final_orbit.period)
        return final_orbit_anomaly - initial_orbit_anomaly
      end

      # The ratio of the destination orbit radius over the initial orbit radius.
      # Ratios greater than one are a move to a higher orbit.
      def radius_ratio
        return self.final_orbit.semimajor_axis / self.initial_orbit.semimajor_axis
      end

      # The ratio of the destination orbit period to the initial orbit period.
      # If it is greater than 1, then the destination orbit is lower.
      def period_ratio
        return self.final_orbit.period / self.initial_orbit.period
      end

    end
  end
end
