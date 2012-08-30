module KerbalDyn
  # See ClassMethods for methods added by this module.
  module ParameterAttributeHelper

    def self.included(mod)
      mod.extend(ClassMethods)
    end

    module ClassMethods

      # Metaprogramming method for setting physical parameters, which are
      # always of float type.
      def attr_param(*params)
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

    end

  end
end
