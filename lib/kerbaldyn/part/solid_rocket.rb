module KerbalDyn
  module Part
    class SolidRocket < Base
      include Mixin::FuelTank

      def thrust
        return self['thrust'].to_f
      end

      def heat_production
        return self['heatProduction'].to_f
      end

      # The fuel consumption in m^3/s
      #
      # To convert to liters/second, multiply by 1000
      def fuel_consumption
        return self['fuelConsumption'].to_f / 1000.0
      end

      def burn_time
        return self.capacity / self.fuel_consumption
      end

    end
  end
end
