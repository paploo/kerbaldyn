module KerbalDyn
  module Part
    class LiquidFuelEngine < Base
      SurfaceGravity = 9.8072 # Determined experimentally.

      def max_thrust
        return self['maxThrust'].to_f
      end
      alias_method :thrust, :max_thrust

      def min_thrust
        return self['minThrust'].to_f
      end

      def isp
        return self['Isp'].to_f
      end

      def vac_isp
        return self['vacIsp'].to_f
      end

      def heat_production
        return self['heatProduction'].to_f
      end

      # Calculated mass fuel flow.
      #
      # To calculate the fuel flow in liters, one must multiply by 1000.0 and
      # divide by the fuel tank density
      def mass_flow_rate
        return self.max_thrust / (self.isp * SurfaceGravity)
      end

      # Calculated mass fuel flow.
      def vac_mass_flow_rate
        return self.max_thrust / (self.vac_isp * SurfaceGravity)
      end

      # This is the volume-wise fuel flow.  Multiply by 1000.0 to get liters/s
      # instead of m^3/s.
      #
      # It needs a fuel tank to calculate from, as fuel densities vary by
      # tank.
      def fuel_consumption(tank)
        return self.mass_flow_rate / tank.fuel_density
      end

      # This is the volume-wise fuel flow.  Multiply by 1000.0 to get liters/s
      # instead of m^3/s.
      #
      # It needs a fuel tank to calculate from, as fuel densities vary by
      # tank.
      def vac_fuel_consumption(tank)
        return self.vac_mass_flow_rate / tank.fuel_density
      end

      def thrust_vectored?
        return self['thrustVectoringCapable'].to_s.downcase == 'true'
      end

      def gimbal_range
        return self['gimbal_range'].to_s
      end

    end
  end
end
