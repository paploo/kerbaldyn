require File.join(File.dirname(__FILE__), 'spec_helper')

describe KerbalDyn::OrbitalManeuver::Bielliptic do

  describe 'Test Maneuver' do

    before(:all) do
      @planetoid = KerbalDyn::Planetoid.new('Gallifrey', :gravitational_parameter => 2.0**12, :radius => 2.0)
    end

    [
      {:name => 'Low Transfer Up',  :r1 => 16.0, :r2 => 64.0, :rt =>   4.0, :delta_v => 14.563217871508062, :delta_vs => [-5.88071148746, 3.42648374633,  5.25602263772], :times => [0.0, 1.55227941653, 11.2839695983]},
      {:name => 'Med Transfer Up',  :r1 => 16.0, :r2 => 64.0, :rt =>  32.0, :delta_v =>  7.769576954455817, :delta_vs => [ 2.47520861407, 3.82634098781,  1.46802735258], :times => [0.0, 5.77147423573, 22.0956685138]},
      {:name => 'High Transfer Up', :r1 => 16.0, :r2 => 64.0, :rt => 256.0, :delta_v =>  9.228940857774582, :delta_vs => [ 5.95181889824, 1.15783344699, -2.11928851254], :times => [0.0, 77.8535214542, 177.199404112]},
    ].each do |test_case|

      describe test_case[:name] do

        before(:all) do
          @initial_orbit = KerbalDyn::Orbit.new(@planetoid, :radius => test_case[:r1])
          @final_orbit   = KerbalDyn::Orbit.new(@planetoid, :radius => test_case[:r2])
          @bielliptic = KerbalDyn::OrbitalManeuver::Bielliptic.new(@initial_orbit, @final_orbit, :transfer_radius => test_case[:rt])
        end

        it "should have the right transfer radius" do
          @bielliptic.transfer_radius.should be_within_six_sigma_of( test_case[:rt] )
        end

        it "should calculate the right delta_vs" do
          test_case[:delta_vs].zip( @bielliptic.delta_velocities ).each do |expected, actual|
            actual.should be_within_six_sigma_of(expected)
          end
        end

        it "should calculate the right delta v" do
          @bielliptic.delta_v.should > 0.0
          @bielliptic.delta_v.should be_within_six_sigma_of( test_case[:delta_v] )
        end

        it "should calculate the right times" do
          test_case[:times].zip( @bielliptic.times ).each do |expected, actual|
            if( expected.abs <= 1e-9 )
              expected.should be_within(1e-9).of(expected)
            else
              actual.should be_within_six_sigma_of(expected)
            end
          end
        end

        it "should calculate the right delta_anomaly" do
          @bielliptic.delta_mean_anomaly.should be_within_six_sigma_of( 2.0 * Math::PI )
        end

      end

    end

  end

end
