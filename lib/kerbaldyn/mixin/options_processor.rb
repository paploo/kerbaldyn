module KerbalDyn
  module Mixin
    module OptionsProcessor

      private

      # Iterates over all the key/value pairs in the options, calling the relevant
      # accessor.  Uses the passed block to get defaults for given keys.
      def process_options(options, defaults)
        defaults.merge(options).each do |key,value|
          self.send("#{key}=", value)
        end
      end

    end
  end
end
