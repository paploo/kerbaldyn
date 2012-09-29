require File.join(File.dirname(__FILE__), 'spec_helper')

describe KerbalDyn::OrbitalManeuver::Hohmann do

  # I'm purposefully violating a purist OrbitalManeuver::Base Unit Test for the sake of time,
  # since the necessary tests involve implementing the same two methods that that Hohmann does.
  describe "Standard Hohmann, including testing OrbitalManeuver::Base methods with a real transfer." do

    before(:all) do
      # Set all the testable data with hard-set values.
      @initial = {:mean_velocity => 16.0, :semimajor_axis => 16.0}
      @final = {:mean_velocity => 8.0, :semimajor_axis => 64.0}
      @transfer = {:periapsis => 16.0, :periapsis_velocity => 20.2385770251, :apoapsis => 64.0, :apoapsis_velocity => 5.05964425627}
      @time = 12.41823533225
      @delta_vs = [4.23857702508, 2.94035574373]
      @delta_v = 7.178932768808223

      # Build the test transfer object up from basic pieces.
      # TODO: Stub these classes to make a truly independent class.
      @planetoid = KerbalDyn::Planetoid.new('Gallifrey', :gravitational_parameter => 2.0**12, :radius => 2.0)
      @initial_orbit = KerbalDyn::Orbit.new(@planetoid, :radius => @initial[:semimajor_axis])
      @final_orbit = KerbalDyn::Orbit.new(@planetoid, :radius => @final[:semimajor_axis])
      @hohmann = KerbalDyn::OrbitalManeuver::Hohmann.new(@initial_orbit, @final_orbit)
    end

    it 'should produce the transfer orbit' do
      transfer_orbit = @hohmann.transfer_orbit
      @transfer.each {|k,v| transfer_orbit.send(k).should be_within_six_sigma_of(v)}
    end

    it 'should produce the list of orbits' do
      orbits = @hohmann.orbits

      orbits.length.should == 3
      orbits[0].should == @hohmann.initial_orbit
      orbits[1].should == @hohmann.transfer_orbit
      orbits[2].should == @hohmann.final_orbit
    end

    it 'should produce the list of burn events' do
      burn_events = @hohmann.burn_events

      burn_events.length.should == 2

      burn_events.first.tap do |be|
        be.initial_velocity.should be_within_six_sigma_of( @initial[:mean_velocity] )
        be.final_velocity.should be_within_six_sigma_of( @transfer[:periapsis_velocity] )
        be.orbital_radius.should be_within_six_sigma_of( @initial[:semimajor_axis] )
        be.time.should be_within(1e-9).of(0.0)
        be.mean_anomaly.should be_within(1e-9).of(0.0)
      end

      burn_events.last.tap do |be|
        be.initial_velocity.should be_within_six_sigma_of( @transfer[:apoapsis_velocity] )
        be.final_velocity.should be_within_six_sigma_of( @final[:mean_velocity] )
        be.orbital_radius.should be_within_six_sigma_of( @final[:semimajor_axis] )
        be.time.should be_within_six_sigma_of(@time)
        be.mean_anomaly.should be_within_six_sigma_of(Math::PI)
      end
    end

    it 'should know if it is moving ot a higher orbit' do
      @hohmann.moving_to_higher_orbit?.should be_true
    end

    it 'should produce the list of before/after velocities' do
      velocities = @hohmann.velocities
      expected_velocities = [ [@initial[:mean_velocity], @transfer[:periapsis_velocity]], [@transfer[:apoapsis_velocity], @final[:mean_velocity]] ]

      [0,1].each do |i|
        [0,1].each do |j|
          velocities[i][j].should be_within_six_sigma_of(expected_velocities[i][j])
        end
      end
    end

    it 'should produce the list of delta velocities' do
      @hohmann.delta_velocities.zip(@delta_vs).each do |actual, expected|
        actual.should be_within_six_sigma_of(expected)
      end
    end

    it 'should produce the list of impulse burn time stamps' do
      @hohmann.times.first.should be_within(1e-9).of(0.0)
      @hohmann.times.last.should be_within_six_sigma_of(@time)
    end

    it 'should produce the list of impulse burn radii' do
      @hohmann.orbital_radii.zip([@initial[:semimajor_axis], @final[:semimajor_axis]]).each do |actual, expected|
        actual.should be_within_six_sigma_of(expected)
      end
    end

    it 'should produce the list of impulse burn mean anomalies' do
      @hohmann.mean_anomalies.first.should be_within(1e-9).of(0.0)
      @hohmann.mean_anomalies.last.should be_within_six_sigma_of(Math::PI)
    end

    it 'should produce the final delta velocity' do
      @hohmann.delta_velocity.should >= 0.0
      @hohmann.delta_velocity.should be_within_six_sigma_of(@delta_v)
      @hohmann.delta_v.should == @hohmann.delta_velocity
    end

    it 'should produce the delta_t' do
      @hohmann.delta_t.should be_within_six_sigma_of(@time)
    end

    it 'should produce the delta anomaly' do
      @hohmann.delta_mean_anomaly.should be_within_six_sigma_of(Math::PI)
    end

    it 'should produce the mean lead angle' do
      @hohmann.mean_lead_angle.should be_within_six_sigma_of(1.5893132370591518)
    end

    it 'should produce the mean lead time' do
      @hohmann.mean_lead_time.should be_within_six_sigma_of(5.364425222994782)
    end

    it 'should produce the relative anomaly delta' do
      @hohmann.relative_anomaly_delta.should be_within_six_sigma_of(-5.497787143782138)
    end

  end

  describe "Descending Hohmann" do

    before(:all) do
      # Set all the testable data with hard-set values.
      @initial = {:mean_velocity => 8.0, :semimajor_axis => 64.0}
      @final = {:mean_velocity => 16.0, :semimajor_axis => 16.0}
      @transfer = {:periapsis => 16.0, :periapsis_velocity => 20.2385770251, :apoapsis => 64.0, :apoapsis_velocity => 5.05964425627}
      @time = 12.41823533225
      @delta_vs = [-2.94035574373, -4.23857702508]
      @delta_v = 7.178932768808223

      # Build the test transfer object up from basic pieces.
      # TODO: Stub these classes to make a truly independent class.
      @planetoid = KerbalDyn::Planetoid.new('Gallifrey', :gravitational_parameter => 2.0**12, :radius => 2.0)
      @initial_orbit = KerbalDyn::Orbit.new(@planetoid, :radius => @initial[:semimajor_axis])
      @final_orbit = KerbalDyn::Orbit.new(@planetoid, :radius => @final[:semimajor_axis])
      @hohmann = KerbalDyn::OrbitalManeuver::Hohmann.new(@initial_orbit, @final_orbit)
    end

    it 'should produce the transfer orbit' do
      transfer_orbit = @hohmann.transfer_orbit
      @transfer.each {|k,v| transfer_orbit.send(k).should be_within_six_sigma_of(v)}
    end

    it 'should produce the list of orbits' do
      orbits = @hohmann.orbits

      orbits.length.should == 3
      orbits[0].should == @hohmann.initial_orbit
      orbits[1].should == @hohmann.transfer_orbit
      orbits[2].should == @hohmann.final_orbit
    end

    it 'should produce the list of burn events' do
      burn_events = @hohmann.burn_events

      burn_events.length.should == 2

      burn_events.first.tap do |be|
        be.initial_velocity.should be_within_six_sigma_of( @initial[:mean_velocity] )
        be.final_velocity.should be_within_six_sigma_of( @transfer[:apoapsis_velocity] )
        be.orbital_radius.should be_within_six_sigma_of( @initial[:semimajor_axis] )
        be.time.should be_within(1e-9).of(0.0)
        be.mean_anomaly.should be_within(1e-9).of(0.0)
      end

      burn_events.last.tap do |be|
        be.initial_velocity.should be_within_six_sigma_of( @transfer[:periapsis_velocity] )
        be.final_velocity.should be_within_six_sigma_of( @final[:mean_velocity] )
        be.orbital_radius.should be_within_six_sigma_of( @final[:semimajor_axis] )
        be.time.should be_within_six_sigma_of(@time)
        be.mean_anomaly.should be_within_six_sigma_of(Math::PI)
      end
    end

    it 'should know if it is moving ot a higher orbit' do
      @hohmann.moving_to_higher_orbit?.should be_false
    end

    it 'should produce the list of delta velocities' do
      @hohmann.delta_velocities.zip(@delta_vs).each do |actual, expected|
        actual.should be_within_six_sigma_of(expected)
      end
    end

    it 'should produce the final delta velocity' do
      @hohmann.delta_velocity.should >= 0.0
      @hohmann.delta_velocity.should be_within_six_sigma_of(@delta_v)
      @hohmann.delta_v.should == @hohmann.delta_velocity
    end

  end

  describe "Earth lower-to-higher orbit" do

    before(:all, &BeforeFactory.earth)

    before(:all) do
      # The starting circ orbit.
      @r1 = 6678e3
      @v1 = 7.73e3

      # The final circ orbit.
      @r2 = 42164e3
      @v2 = 3.07e3

      # The transfer orbit apoapsis and periapsis velocities
      @vp = 10.15e3
      @va =  1.61e3

      # The deltas
      @dv1 =  2.42e3
      @dv2 =  1.46e3
      @dv  =  3.88e3


      @orbit1 = KerbalDyn::Orbit.new(@planetoid, :semimajor_axis => @r1, :eccentricity => 0.0)
      @orbit2 = KerbalDyn::Orbit.new(@planetoid, :semimajor_axis => @r2, :eccentricity => 0.0)

      @hohmann = KerbalDyn::OrbitalManeuver::Hohmann.new(@orbit1, @orbit2)
    end

    it 'should calculate burn one from velocity' do
      @hohmann.initial_orbit.apoapsis_velocity.should be_within_two_sigma_of(@v1)
      @hohmann.velocities[0][0].should be_within_two_sigma_of(@v1)
    end

    it 'should calculate burn one to velocity' do
      @hohmann.transfer_orbit.periapsis_velocity.should be_within_two_sigma_of(@vp)
      @hohmann.velocities[0][1].should be_within_two_sigma_of(@vp)
    end

    it 'should calculate burn two from velocity' do
      @hohmann.transfer_orbit.apoapsis_velocity.should be_within_two_sigma_of(@va)
      @hohmann.velocities[1][0].should be_within_two_sigma_of(@va)
    end

    it 'should calculate burn two to velocity' do
      @hohmann.final_orbit.apoapsis_velocity.should be_within_two_sigma_of(@v2)
      @hohmann.velocities[1][1].should be_within_two_sigma_of(@v2)
    end

    it 'should calculate burn one delta velocity' do
      @hohmann.delta_velocities[0].should be_within_two_sigma_of(@dv1)
    end

    it 'should calculate burn two delta velocity' do
      @hohmann.delta_velocities[1].should be_within_two_sigma_of(@dv2)
    end

    it 'should calculate total delta velocity' do
      @hohmann.delta_v.should be_within_two_sigma_of(@dv)
    end

    it 'should calculate the lead angle for intercept' do
      # Value calculated several times, several different ways to cross-check
      @hohmann.mean_lead_angle.should be_within_two_sigma_of(1.756)
    end

    it 'should calculate the lead time for intercept' do
      # Value calculated
      @hohmann.mean_lead_time.should be_within_two_sigma_of(4175.58)
    end

    it 'should calculate the realtive anomaly change per complete orbit' do
      delta_theta = -5.887 #separation change per complete rotation ofinitial orbit as compared to something in the final orbit; negative since the lower orbit should close the gap.
      @hohmann.relative_anomaly_delta.should be_within_two_sigma_of(delta_theta)
    end

    it 'should recognize as a move to a lower orbit' do
      @hohmann.moving_to_higher_orbit?.should be_true
    end

  end

  describe "Earth higher-to-lower orbit" do

    before(:all, &BeforeFactory.earth)

    before(:all) do
      # The final circ orbit.
      @r1 = 42164e3
      @v1 = 3.07e3

      # The starting circ orbit.
      @r2 = 6678e3
      @v2 = 7.73e3

      # The transfer orbit apoapsis and periapsis velocities
      @vp = 10.15e3
      @va =  1.61e3

      # The deltas
      @dv1 =  -1.46e3
      @dv2 =  -2.42e3
      @dv  =  3.88e3


      @orbit1 = KerbalDyn::Orbit.new(@planetoid, :semimajor_axis => @r1, :eccentricity => 0.0)
      @orbit2 = KerbalDyn::Orbit.new(@planetoid, :semimajor_axis => @r2, :eccentricity => 0.0)

      @hohmann = KerbalDyn::OrbitalManeuver::Hohmann.new(@orbit1, @orbit2)
    end

    it 'should calculate burn one from velocity' do
      @hohmann.initial_orbit.apoapsis_velocity.should be_within_two_sigma_of(@v1)
      @hohmann.velocities[0][0].should be_within_two_sigma_of(@v1)
    end

    it 'should calculate burn one to velocity' do
      @hohmann.transfer_orbit.apoapsis_velocity.should be_within_two_sigma_of(@va)
      @hohmann.velocities[0][1].should be_within_two_sigma_of(@va)
    end

    it 'should calculate burn two from velocity' do
      @hohmann.transfer_orbit.periapsis_velocity.should be_within_two_sigma_of(@vp)
      @hohmann.velocities[1][0].should be_within_two_sigma_of(@vp)
    end

    it 'should calculate burn two to velocity' do
      @hohmann.final_orbit.apoapsis_velocity.should be_within_two_sigma_of(@v2)
      @hohmann.velocities[1][1].should be_within_two_sigma_of(@v2)
    end

    it 'should calculate burn one delta velocity' do
      @hohmann.delta_velocities[0].should be_within_two_sigma_of(@dv1)
    end

    it 'should calculate burn two delta velocity' do
      @hohmann.delta_velocities[1].should be_within_two_sigma_of(@dv2)
    end

    it 'should calculate total delta velocity' do
      @hohmann.delta_v.should be_within_two_sigma_of(@dv)
    end

    it 'should calculate the lead angle for intercept' do
      # Value calculated several times, several different ways to cross-check
      # This is a large negative number because the lower orbit gets nearly 3.5 periods in during the transfer, which is nearly 22 radians.
      @hohmann.mean_lead_angle.should be_within_two_sigma_of(-18.83)
    end

    it 'should calculate the lead time for intercept' do
      # The lead angle, -18.828, is so insanely close to three times around the circle, that about 20s is actually the lead time!
      @hohmann.mean_lead_time.should be_within_two_sigma_of(19.73)
    end

    it 'should calculate the realtive anomaly change per complete orbit' do
      # This is large because the inner planet gets nearly 16 loops (nearly 100 radians) in for each of the slow orbit's
      delta_theta = 93.40
      @hohmann.relative_anomaly_delta.should be_within_two_sigma_of(delta_theta)
    end

    it 'should recognize as a move to a lower orbit' do
      @hohmann.moving_to_higher_orbit?.should be_false
    end

  end

  describe 'Null transition' do
    before(:all, &BeforeFactory.earth)

    before(:all) do
      @orbit1 = KerbalDyn::Orbit.new(@planetoid, :semimajor_axis => 1000e3, :eccentricity => 0.0)
      @orbit2 = KerbalDyn::Orbit.new(@planetoid, :semimajor_axis => 1000e3, :eccentricity => 0.0)
      @hohmann = KerbalDyn::OrbitalManeuver::Hohmann.new(@orbit1, @orbit2)
    end

    it 'should have zero relative anomaly delta' do
      @hohmann.relative_anomaly_delta.should be_within(1e-6).of(0.0)
    end

    it 'should have zero lead angle' do
      @hohmann.mean_lead_angle.should be_within(1e-6).of(0.0)
    end

  end

end
