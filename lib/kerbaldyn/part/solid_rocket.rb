module KerbalDyn
  module Part
    class SolidRocket < Base

      # ===== FUEL TANK METHODS =====
      # TODO: These are the same as for a fuel tank, so should go into a side module.

      # Fuel capacity in m^3 to match mks requirement,
      # even though the game seems to display liters.
      #
      # Note that 1 m^3 = 1000 liters
      def fuel
        return self['internalFuel'].to_f / 1000.0
      end
      alias_method :internal_fuel, :fuel
      alias_method :capacity, :fuel

      def dry_mass
        return self['dryMass'].to_f
      end

      # The mass of the fuel.
      def fuel_mass
        return self.mass - self.dry_mass
      end

      # Calculated density in kg/m^3.
      #
      # Note that 1 m^3 = 1000 liters
      def fuel_density
        return self.fuel_mass / self.capacity
      end


      #===== ENGINE METHODS =====

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
