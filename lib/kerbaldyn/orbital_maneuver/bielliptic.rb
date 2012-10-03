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
        options = {:transfer_radius => final_orbit.semimajor_axis}.merge(options)
        super(initial_orbit.circularize, final_orbit.circularize, options)
      end

      attr_accessor :transfer_radius
      private :transfer_radius=

      def initial_transfer_orbit
        r1 = self.initial_orbit.periapsis
        rt = self.transfer_radius
        return Orbit.new(self.initial_orbit.primary_body, :periapsis => [r1,rt].min, :apoapsis => [r1,rt].max)
      end

      def final_transfer_orbit
        r2 = self.final_orbit.periapsis
        rt = self.transfer_radius
        return Orbit.new(self.initial_orbit.primary_body, :periapsis => [r2,rt].min, :apoapsis => [r2,rt].max)
      end

      def orbits
        return [self.initial_orbit, self.initial_transfer_orbit, self.final_transfer_orbit.second, self.final_orbit]
      end

      def burn_events
        r1 = self.initial_orbit.periapsis
        r2 = self.final_orbit.periapsis
        rt = self.transfer_radius

        ito = self.initial_transfer_orbit
        v11, v12 = (rt >= r1) ? [ito.periapsis_velocity, ito.apoapsis_velocity] : [ito.apoapsis_velocity, ito.periapsis_velocity]

        fto = self.final_transfer_orbit
        v21, v22 = (rt < r2) ? [fto.periapsis_velocity, fto.apoapsis_velocity] : [fto.apoapsis_velocity, fto.periapsis_velocity]

        t1 = self.initial_transfer_orbit.period / 2.0
        t2 = self.final_transfer_orbit.period / 2.0

        return [
          BurnEvent.new(:initial_velocity => self.initial_orbit.mean_velocity, :final_velocity => v11, :time => 0.0, :orbital_radius => self.initial_orbit.semimajor_axis, :mean_anomaly => 0.0),
          BurnEvent.new(:initial_velocity => v12, :final_velocity => v21, :time => t1, :orbital_radius => self.transfer_radius, :mean_anomaly => Math::PI),
          BurnEvent.new(:initial_velocity => v22, :final_velocity => self.final_orbit.mean_velocity, :time => t1+t2, :mean_anomaly => 2.0 * Math::PI)
        ]
      end

    end
  end
end
