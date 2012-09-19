require File.join(File.dirname(__FILE__), 'spec_helper')

describe KerbalDyn::Part do

  before(:all) do
    @liquid_engine_attr = {"name"=>"liquidEngine", "module"=>"LiquidFuelEngine", "author"=>"Mrbrownce", "mesh"=>"model.mu", "scale"=>"0.1", "node_stack_top"=>"0.0, 7.21461, 0.0, 0.0, 1.0, 0.0", "node_stack_bottom"=>"0.0, -7.27403, 0.0, 0.0, 1.0, 0.0", "fx_exhaustFlame_blue"=>"0.0, -10.3, 0.0, 0.0, 1.0, 0.0, active", "fx_exhaustLight_blue"=>"0.0, -10.3, 0.0, 0.0, 0.0, 1.0, active", "fx_smokeTrail_light"=>"0.0, -10.3, 0.0, 0.0, 1.0, 0.0, active", "sound_vent_medium"=>"activate", "sound_rocket_hard"=>"active", "sound_vent_soft"=>"deactivate", "cost"=>"850", "category"=>"0", "subcategory"=>"0", "title"=>"LV-T30 Liquid Fuel Engine", "manufacturer"=>"Jebediah Kerman's Junkyard and Spaceship Parts Co.", "description"=>"Although criticized by some due to its not unsignificant use of so-called \"pieces found lying about\", the LV-T series has proven itself as a comparatively reliable engine. The T30 model boasts a failure ratio below the 50% mark. This has been considered a major improvement over previous models by engineers and LV-T enthusiasts.", "attachRules"=>"1,0,1,0,0", "mass"=>"1.25", "dragModelType"=>"default", "maximum_drag"=>"0.2", "minimum_drag"=>"0.2", "angularDrag"=>"2", "crashTolerance"=>"7", "maxTemp"=>"3600", "maxThrust"=>"215", "minThrust"=>"0", "heatProduction"=>"400", "Isp"=>"320", "vacIsp"=>"370"}
    @liquid_engine2_attr = {"name"=>"liquidEngine2", "module"=>"LiquidFuelEngine", "author"=>"Mrbrownce", "mesh"=>"model.mu", "scale"=>"0.1", "node_stack_top"=>"0.0, 7.21461, 0.0, 0.0, 1.0, 0.0", "node_stack_bottom"=>"0.0, -5.74338, 0.0, 0.0, 1.0, 0.0", "fx_exhaustFlame_blue"=>"0.0, -5.74338, 0.0, 0.0, 1.0, 0.0, active", "fx_exhaustLight_blue"=>"0.0, -5.74338, 0.0, 0.0, 0.0, 1.0, active", "fx_smokeTrail_light"=>"0.0, -5.74338, 0.0, 0.0, 1.0, 0.0, active", "sound_vent_medium"=>"activate", "sound_rocket_hard"=>"active", "sound_vent_soft"=>"deactivate", "cost"=>"950", "category"=>"0", "subcategory"=>"0", "title"=>"LV-T45 Liquid Fuel Engine", "manufacturer"=>"Jebediah Kerman's Junkyard and Spaceship Parts Co.", "description"=>"The LV-T45 engine was considered another breakthrough in the LV-T series, due to its Thrust Vectoring feature. The LV-T45 can deflect its thrust to aid in craft control. All these added mechanics however, make for a slightly smaller and less powerful engine in comparison with earlier LV-T models.", "attachRules"=>"1,0,1,0,0", "mass"=>"1.5", "dragModelType"=>"default", "maximum_drag"=>"0.2", "minimum_drag"=>"0.2", "angularDrag"=>"2", "crashTolerance"=>"7", "maxTemp"=>"3600", "maxThrust"=>"200", "minThrust"=>"0", "heatProduction"=>"440", "fuelConsumption"=>"7", "Isp"=>"320", "vacIsp"=>"370", "thrustVectoringCapable"=>"True", "gimbalRange"=>"1.0"}
    @fuel_tank_attr = {"name"=>"fuelTank", "module"=>"FuelTank", "author"=>"Mrbrownce", "mesh"=>"model.mu", "scale"=>"0.1", "node_stack_top"=>"0.0, 7.72552, 0.0, 0.0, 1.0, 0.0", "node_stack_bottom"=>"0.0, -7.3, 0.0, 0.0, 1.0, 0.0", "node_attach"=>"5.01, 0.0, 0.0, 1.0, 0.0, 0.0, 1", "cost"=>"850", "category"=>"0", "subcategory"=>"0", "title"=>"FL-T400 Fuel Tank", "manufacturer"=>"Jebediah Kerman's Junkyard and Spaceship Parts Co.", "description"=>"The FL series was received as a substantial upgrade over previous fuel containers used in the Space Program, generally due to its ability to keep the fuel unexploded more often than not. Fuel tanks are useless if there isn't a Liquid Engine attached under it. They can also be stacked with other fuel tanks to increase the amount of fuel for the engine below.", "attachRules"=>"1,1,1,1,0", "mass"=>"2.25", "dragModelType"=>"default", "maximum_drag"=>"0.2", "minimum_drag"=>"0.3", "angularDrag"=>"2", "crashTolerance"=>"6", "breakingForce"=>"50", "breakingTorque"=>"50", "maxTemp"=>"2900", "fuel"=>"400.0", "dryMass"=>"0.25", "fullExplosionPotential"=>"0.9", "emptyExplosionPotential"=>"0.1"}
    @rcs_tank_attr = {"name"=>"RCSFuelTank", "module"=>"RCSFuelTank", "author"=>"Mrbrownce || HarvesteR", "mesh"=>"model.mu", "scale"=>"0.1", "node_stack_top"=>"0.0, 4.64624, 0.0, 0.0, 1.0, 0.0", "node_stack_bottom"=>"0.0, 0.23193, 0.0, 0.0, 1.0, 0.0", "cost"=>"800", "category"=>"0", "subcategory"=>"0", "title"=>"FL-R25 RCS Fuel Tank", "manufacturer"=>"Jebediah Kerman's Junkyard and Spaceship Parts Co.", "description"=>"These fuel tanks carry pressurized gas propellant for RCS thrusters. New advances in plumbing technology made it possible to route RCS lines to any point in the ship. So unlike liquid fuel tanks, RCS Fuel tanks can be placed anywhere.", "attachRules"=>"1,0,1,1,0", "mass"=>"0.5", "dragModelType"=>"default", "maximum_drag"=>"0.2", "minimum_drag"=>"0.2", "angularDrag"=>"2", "crashTolerance"=>"12", "maxTemp"=>"2900", "fuel"=>"200", "dryMass"=>"0.1", "fullExplosionPotential"=>"0.7", "emptyExplosionPotential"=>"0.1"}
    @booster_attr = {"name"=>"solidBooster", "module"=>"SolidRocket", "author"=>"Il Carnefice", "mesh"=>"model.mu", "scale"=>"0.1", "node_stack_bottom"=>"0.0, -12.5127, 0.0, 0.0, 1.0, 0.0, 1", "node_stack_top"=>"0.0, 10.2547, 0.0, 0.0, 1.0, 0.0, 1", "node_attach"=>"0.0, 0.0, -5, 0.0, 0.0, 1.0, 1", "fx_exhaustFlame_yellow"=>"0.0, -11.2673, 0.0, 0.0, 1.0, 0.0, active", "fx_exhaustSparks_yellow"=>"0.0, -11.2673, 0.0, 0.0, 1.0, 0.0, active", "fx_smokeTrail_medium"=>"0.0, -11.2673, 0.0, 0.0, 1.0, 0.0, active", "sound_vent_medium"=>"activate", "sound_rocket_hard"=>"active", "sound_vent_soft"=>"deactivate", "cost"=>"450", "category"=>"0", "subcategory"=>"0", "title"=>"RT-10 Solid Fuel Booster", "description"=>"While considered by some to be little more than \"a trash bin full o' boom\", The RT-10 is used in many space programs, whenever the need to save cash is greater than the need to keep astronauts alive. Use with caution, though. Once lit, solid fuel motors cannot be put out until the fuel runs out.", "attachRules"=>"1,1,1,1,0", "mass"=>"1.8", "dragModelType"=>"default", "maximum_drag"=>"0.3", "minimum_drag"=>"0.2", "angularDrag"=>"2", "crashTolerance"=>"7", "maxTemp"=>"3600", "thrust"=>"250", "dryMass"=>"0.36", "heatProduction"=>"550", "fuelConsumption"=>"4", "internalFuel"=>"100", "fullExplosionPotential"=>"0.8", "emptyExplosionPotential"=>"0.1", "thrustCenter"=>"0, -0.5, 0", "thrustVector"=>"0, 1, 0"}
  end

  describe KerbalDyn::Part::Base do

    describe 'properties' do

      before(:each) do
        @attributes = {'name' => 'fooThruster', 'module' => 'LiquidFuelEngine', 'category' => '0'}
        @part = KerbalDyn::Part::Base.new(@attributes)
      end

      # Rather than test every single property, we test those that have non-trivial
      # accessors.

      it 'should provide string and symbol access to attributes' do
        @part['name'].should == @attributes['name']
        @part[:name].should == @attributes['name']
      end

      it 'should provide category name' do
        @part.category.should == KerbalDyn::Part::CATEGORIES['Propulsion']
        @part.category_name.should == 'Propulsion'
      end

      it 'should provide module class' do
        @part.module_class.should == KerbalDyn::Part::LiquidFuelEngine
      end

      it 'should copy the attributes passed to it' do
        attributes = @attributes.dup
        part = KerbalDyn::Part::Base.new(attributes)

        part.attributes.object_id.should_not == attributes.object_id

        part['name'].should == 'fooThruster'
        attributes['name'] == 'barThruster'
        part['name'].should_not == 'barThruster'
      end

    end

    describe 'loader' do

      it 'should load parts from part directories'

      it 'should instantiate as the module attribute class'

      it 'should default to instantiating as generic'

      it 'should return nil if no part was found'

      it 'should log parse errors'

    end

  end

  describe KerbalDyn::Part::Generic do

    it 'should be a subclass of Base'

  end

  describe KerbalDyn::Part::FuelTank do

    before(:each) do
      @fuel_tank = KerbalDyn::Part::FuelTank.new(@fuel_tank_attr)
    end

    it 'should calculate capacity in m^3'

    it 'should calculate fuel weight'

    it 'should calculate fuel density in kg/m^3'

  end

  describe KerbalDyn::Part::RCSFuelTank do

    before(:each) do
      @rcs_fuel_tank = KerbalDyn::Part::FuelTank.new(@rcs_fuel_tank_attr)
    end

    it 'should calculate capacity in m^3'

    it 'should calculate fuel weight'

    it 'should calculate fuel density in kg/m^3'

  end

  describe KerbalDyn::Part::LiquidFuelEngine do

    before(:each) do
      @liquid_engine = KerbalDyn::Part::LiquidFuelEngine.new(@liquid_engine_attr)
      @liquid_engine2 = KerbalDyn::Part::LiquidFuelEngine.new(@liquid_engine2)
    end

    it 'should calculate mass flow rate'

    it 'should calculate vacuum mass flow rate'

    it 'should calculate fuel consumption in m^3/s'

    it 'should calculate vacuum fuel consumption in m^3/s'

  end

  describe KerbalDyn::Part::SolidRocket do

    before(:each) do
      @booster = KerbalDyn::Part::FuelTank.new(@booster_attr)
    end

    it 'should calculate capacity in m^3'

    it 'should calculate fuel weight'

    it 'should calculate fuel density in kg/m^3'

    it 'should calculate fuel consumption in m^3/s'

    it 'should calculate burn time'

  end

end
