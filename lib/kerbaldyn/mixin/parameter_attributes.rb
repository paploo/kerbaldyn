module KerbalDyn
  module Mixin
    # See ClassMethods for methods added by this module.
    module ParameterAttributes

      def self.included(mod)
        mod.extend(ClassMethods)
      end

      module ClassMethods

        # Metaprogramming method for setting physical parameters, which are
        # always of float type.
        def attr_parameter(*params)
          params.each do |param|
            attr_reader param

            setter_line = __LINE__ + 1
            setter = <<-METHOD
              def #{param}=(value)
                @#{param} = value && value.to_f
              end
            METHOD
            class_eval(setter, __FILE__, setter_line)
          end
        end

        # Alias a parameter getter and setter methods.
        def alias_parameter(to, from)
          alias_method to, from
          alias_method "#{to}=", "#{from}="
        end

      end

    end
  end
end
