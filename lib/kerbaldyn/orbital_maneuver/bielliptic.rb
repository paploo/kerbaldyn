module KerbalDyn
  module OrbitalManeuver
    class Bielliptic < Base

      # A special 3-burn orbital maneuver between two circular orbits through
      # the transfer_radius options.
      #
      # Note that all orbits are circularized before being used.
      #
      # The first burn moves from the initial orbit to the transfer radius,
      # the second burn (at the transfer radius) moves the periapsis of the
      # transfer orbit to the final orbit.  The thrid burn circularizes
      # to the final orbit.
      def initialize(initial_orbit, final_orbit, options={})
        @transfer_radius = options.fetch(:transfer_radius, final_orbit.semimajor_axis)
        super(initial_orbit.circularize, final_orbit.circularize, options)
      end

      attr_reader :transfer_radius

      def transfer_orbits
        r1 = initial_orbit.semimajor_axis
        r2 = final_orbit.semimajor_axis
        rt = self.transfer_radius
        return [
          Orbit.new(self.initial_orbit.primary_body, :periapsis => [r1,rt].min, :apoapsis => [r1,rt].max),
          Orbit.new(self.initial_orbit.primary_body, :periapsis => [r2,rt].min, :apoapsis => [r2,rt].max)
        ]
      end

      # An array of the transfer burn delta-v values.
      #
      # The first burn is for leaving your initial circular orbit, and the
      # second is for entering the new circular orbit.
      #
      # Note that positive values are prograde burns, and negative values
      # are retrograde burns.
      def delta_velocities
        return [
          self.transfer_velocities[0] - self.initial_orbit.mean_velocity,
          self.transfer_velocities[1] - self.transfer_velocities[0],
          self.final_orbit.mean_velocity - self.transfer_velocities[1]
        ]
      end

      # These are the target velocities you should have at the completion of
      # each burn.
      def transfer_velocities
        return [
          self.first_transfer_moving_to_higher_orbit? ? self.transfer_orbit.first.periapsis_velocity : self.transfer_orbit.first.apoapsis_velocity,
          self.second_transfer_moving_to_higher_orbit? ? self.transfer_orbit.last.periapsis_velocity : self.transfer_orbit.last.apoapsis_velocity,
          self.second_transfer_moving_to_higher_orbit? ? self.transfer_orbit.last.apoapsis_velocity : self.transfer_orbit.last.periapsis_velocity
        ]
      end

      def moving_to_higher_orbit?
        return final_orbit.semimajor_axis > initial_orbit.semimajor_axis
      end

      def first_transfer_moving_to_higher_orbit?
        return self.transfer_radius > initial_orbit.semimajor_axis
      end

      def second_transfer_moving_to_higher_orbit?
        return self.transfer_radius < final_orbit.semimajor_axis
      end

    end
  end
end
