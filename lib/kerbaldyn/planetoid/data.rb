module KerbalDyn
  class Planetoid
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
          return @kerbin ||= self.new('Kerbin', 5.29e22, 600e3, :rotational_period => 6.0*3600.0).freeze
        end

        def kerbol
          return @kerbol ||= self.new('Kerbol', 1.75e28, 65400e3).freeze
        end

        def mun
          return @mun ||= self.new('Mun', 9.76e20, 200e3, :rotational_period => 41.0*3600.0).freeze
        end

        def minmus
          return @minmus ||= self.new('Minmus', 4.234e19, 60e3, :rotational_period => 299.272*3600.0).freeze
        end

      end

    end
  end
end
