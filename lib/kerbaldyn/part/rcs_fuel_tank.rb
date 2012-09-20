module KerbalDyn
  module Part
    # A class respresenting all RCS fuel tanks.
    #
    # Most of its methods are defined in the Mixin::FuelTank module.
    class RCSFuelTank < Base
      include Mixin::FuelTank
    end
  end
end
