module KerbalDyn
  module OrbitalManeuver
    # A special 2-burn orbital maneuver between two circular orbits.
    #
    # Note that all orbits are circulairzed before being used.
    #
    # The first burn moves the opposite side of the orbit to the radius of
    # the destination orbit, and the second burn--done when reaching the destination
    # radius--moves the opposite side (where you started) to circularize your
    # orbit.
    #
    #--
    # TODO: To facilitate elliptical orbits, assume coplanar/coaxial, and take options to use periapsis, semimajor_axis, or apoapsis for each orbit.
    # TODO: ALWAYS use semimajor axis here, so that we can assume circular on lead angle and time; make another class for elliptics and eventually replace this as a subclass with default args.
    #++
    class Hohmann < Base

      def initialize(initial_orbit, final_orbit, options={})
        super(initial_orbit.circularize, final_orbit.circularize, options)
      end

      # The elliptical orbit used to transfer from the initial_orbit to the
      # final_orbit.
      def transfer_orbit
        r1 = self.initial_orbit.periapsis
        r2 = self.final_orbit.apoapsis
        # TODO: It should be the Orbit's job to min/max periapsis and apoapsis, and then set angles appropriately.
        return @transfer_orbit ||= Orbit.new(self.initial_orbit.primary_body, :periapsis => [r1,r2].min, :apoapsis => [r1,r2].max)
      end

      def orbits
        return [self.initial_orbit, self.transfer_orbit, self.final_orbit]
      end

      def burn_events
        vs = [self.transfer_orbit.periapsis_velocity, self.transfer_orbit.apoapsis_velocity]
        vs.reverse! if( initial_orbit.semimajor_axis > final_orbit.semimajor_axis )
        v1,v2 = vs

        return [
          BurnEvent.new(:initial_velocity => self.initial_orbit.mean_velocity, :final_velocity => v1, :time => 0.0, :orbital_radius => self.initial_orbit.semimajor_axis, :mean_anomaly => 0.0),
          BurnEvent.new(:initial_velocity => v2, :final_velocity => self.final_orbit.mean_velocity, :time => self.transfer_orbit.period/2.0, :orbital_radius => self.final_orbit.semimajor_axis, :mean_anomaly => Math::PI)
        ]
      end

    end
  end
end
