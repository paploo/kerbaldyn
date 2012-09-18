module KerbalDyn
  module Part
    class FuelTank < Base

      # Fuel capacity in m^3 to match mks requirement,
      # even though the game seems to display liters.
      #
      # Note that 1 m^3 = 1000 liters
      def fuel
        return self['fuel'].to_f / 1000.0
      end
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

    end
  end
end

