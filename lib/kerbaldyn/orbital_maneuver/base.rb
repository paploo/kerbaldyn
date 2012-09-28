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


      # Returns an array of the orbits, including the initial and final orbit.
      #
      # Subclasses should override this method.
      def orbits
        return [initial_orbit, final_orbit]
      end

      # Returns the array of burn events.
      #
      # Subclasses should override this method, as most other values are derived
      # from it.
      def burn_events
        return @burn_events ||= []
      end

      # Returns true if the final orbit has a larger semimajor axis than the
      # initial orbit.
      def moving_to_higher_orbit?
        return final_orbit.semimajor_axis > initial_orbit.semimajor_axis
      end

      # Returns an array of the before/after burn even velocity pairs for each burn event.
      def velocities
        return self.burn_events.map {|be| [be.initial_velocity, be.final_velocity]}
      end

      # Returns an array of the velocity changes for each burn event.
      def delta_velocities
        return self.burn_events.map {|be| be.delta_velocity}
      end

      # Returns an array of the times of each maneuver.
      def times
        return self.burn_events.map {|be| be.time}
      end

      # Returns an array of the orbital radii for the burn events.
      def orbital_radii
        return self.burn_events.map {|be| be.orbital_radii}
      end

      # Returns an array of the mean anomaly at each maneuver.
      def  mean_anomalies
        return self.burn_events.map {|be| be.mean_anomaly}
      end

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
      alias_method :delta_v, :delta_velocity

      # Calculates the total time for completion.
      #
      # For some kinds of idealized maneuvers this may be meaningless, in which
      # case nil is returned.
      #
      # Subclasses should override this.
      def delta_time
        return self.times.last - self.times.first
      end

      # An alias to delta_time.
      def delta_t
        return self.delta_time
      end

      # Calculates the total mean anomaly covered during the maneuver.
      def delta_mean_anomaly
        return self.mean_anomalies.last - self.mean_anomalies.first
      end

      # Calculates the mean lead-angle for a given maneuver.
      #
      # For a target in a higher orbit, this is the mean anomaly ahead of you
      # that the target should be located at.
      def mean_lead_angle
        target_delta_mean_anomaly = self.delta_time * self.final_orbit.mean_angular_velocity
        return self.delta_mean_anomaly - target_delta_mean_anomaly
      end

      # The time elapsed such that--if started when the target is directly radial
      # from you (same true anomaly)--you would start your transfer orbit in order
      # to intercept.
      def mean_lead_time
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
        theta_lead = (self.mean_lead_angle % two_pi)
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

    end
  end
end
