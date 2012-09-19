module KerbalDyn
  module Part
    CATEGORIES = {'Propulsion' => 0, 'Command & Control' => 1, 'Structural & Aerodynamic' => 2, 'Utility & Scientific' => 3, 'Decals' => 4, 'Crew' => 5}.freeze
  end
end


require_relative 'part/mixin'

require_relative 'part/base'
require_relative 'part/generic'
require_relative 'part/fuel_tank'
require_relative 'part/liquid_fuel_engine'
require_relative 'part/rcs_fuel_tank'
require_relative 'part/solid_rocket'
