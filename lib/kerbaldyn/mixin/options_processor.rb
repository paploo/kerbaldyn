module KerbalDyn
  module Mixin
    module OptionsProcessor

      private

      # Iterates over all the key/value pairs in the options, calling the relevant
      # accessor.  Uses the passed block to get defaults for given keys.
      def process_options(options, default_value=nil)
        options.each do |key,value|
          default_value = block_given? ? yield(key) : default_value
          self.send("#{key}=", options.fetch(key, default_value))
        end
      end

    end
  end
end
