module KerbalDyn
  module Part
    # A class respresenting all liquid fuel tanks.
    #
    # Most of its methods are defined in the Mixin::FuelTank module.
    class FuelTank < Base
      include Mixin::FuelTank
    end
  end
end

