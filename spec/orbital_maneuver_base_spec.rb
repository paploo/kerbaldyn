require File.join(File.dirname(__FILE__), 'spec_helper')

describe KerbalDyn::OrbitalManeuver::Base do

  before(:all) do
    @dummy_body = KerbalDyn::Body.test_particle
    @dummy_orbit = KerbalDyn::Orbit.new(@dummy_body)

    @body = KerbalDyn::Planetoid.kerbin
    @orbit1 = KerbalDyn::Orbit.new(@body, :radius => 100e3)
    @orbit2 = KerbalDyn::Orbit.new(@body, :radius => 12000e3)
    @maneuver = KerbalDyn::OrbitalManeuver::Base.new(@orbit1, @orbit2)
  end

  it 'should check that the initial and final orbits are orbiting the same body' do
    @orbit1.primary_body.should == @orbit2.primary_body
    lambda { KerbalDyn::OrbitalManeuver::Base.new(@orbit1, @orbit2) }.should_not raise_error

    @orbit1.primary_body.should_not == @dummy_orbit.primary_body
    lambda { KerbalDyn::OrbitalManeuver::Base.new(@orbit1, @dummy_orbit) }.should raise_error
  end

  it 'should have an initial_orbit' do
    @maneuver.initial_orbit.should == @orbit1
  end

  it 'should have a final_orbit' do
    @maneuver.final_orbit.should == @orbit2
  end

  it 'should have delta_time' do
    @maneuver.should respond_to(:delta_time)
  end

  it 'should map delta_t to delta_time' do
    # Override delta_time just like a subclass would.
    maneuver = @maneuver.dup.tap {|m| m.stub(:delta_time){:jeb}}

    # The real test.
    maneuver.delta_t.should == maneuver.delta_time
  end

  describe 'delta_v' do

    class SettableDeltaVelocitiesTestOrbitalManeuver < KerbalDyn::OrbitalManeuver::Base
      attr_reader :delta_velocities
      attr_writer :delta_velocities
    end

    it 'should give a list of delta velocities' do
      KerbalDyn::OrbitalManeuver::Base.new(@dummy_orbit, @dummy_orbit).delta_velocities.should == []
    end

    it 'should give the sums of the absolute velocities as delta_v' do
      maneuver = SettableDeltaVelocitiesTestOrbitalManeuver.new(@dummy_orbit, @dummy_orbit).tap {|m| m.delta_velocities = [5, -2, 4, 0]}
      maneuver.delta_velocity.should == 11
      maneuver.delta_v.should == 11
    end

    it 'should sum an empty velocity list to zero' do
      maneuver = SettableDeltaVelocitiesTestOrbitalManeuver.new(@dummy_orbit, @dummy_orbit).tap {|m| m.delta_velocities = []}
      maneuver.delta_velocity.should == 0
      maneuver.delta_v.should == 0
    end

    it 'should sum a single negative velocity to its absolute value' do
      maneuver = SettableDeltaVelocitiesTestOrbitalManeuver.new(@dummy_orbit, @dummy_orbit).tap {|m| m.delta_velocities = [-2]}
      maneuver.delta_velocity.should == 2
      maneuver.delta_v.should == 2
    end

  end

end
