module KerbalDyn
  class Planetoid < Body
    # Contains, via the FactoryMethods submodule, factory methods for creating
    # planetoid data.
    #
    # These are frozen memoized values.
    module Data

      def self.included(mod)
        mod.extend(FactoryMethods)
      end

      module FactoryMethods

        def kerbin
          return @kerbin ||= self.new('Kerbin', :mass => 5.29e22, :radius => 600e3, :rotational_period => 6.0*3600.0).freeze
        end

        def kerbol
          return @kerbol ||= self.new('Kerbol', :mass => 1.75e28, :radius => 65400e3).freeze
        end

        def mun
          return @mun ||= self.new('Mun', :mass => 9.76e20, :radius => 200e3, :rotational_period => 41.0*3600.0).freeze
        end

        def minmus
          return @minmus ||= self.new('Minmus', :mass => 4.234e19, :radius => 60e3, :rotational_period => 1077379).freeze
        end

      end

    end
  end
end
