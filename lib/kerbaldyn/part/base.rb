require 'pathname'
require 'json'

module KerbalDyn
  module Part
    # The base-class for all rocket parts.  Instances are always of another
    # type, which is determined by the +module+ attribute.  For parts that
    # don't have special implementations, the Generic part class is used.
    class Base

      # Load the part from a given part directory.  This will automatically
      # instantiate the correct subclass.
      def self.load_part(directory)
        # Process the argument.
        dir = Pathname.new(directory)
        return nil unless dir.directory?

        # Get a handle on the spec file.
        spec_file = dir + 'part.cfg'
        return nil unless spec_file.file?

        # Initialize the attributes container.
        attributes = {}
        errors = []
        line_count = 0

        # Parse the lines.
        spec_file.read.each_line do |line|
          line_count += 1
          line.chomp!
          line = line.encode('ASCII-8BIT', :invalid => :replace, :replace => '?') unless line.valid_encoding?

          case line
          when /^\s*$/
            # Blank
          when /^\s*\/\//
            # Comments
          when /^(.*)=(.*)/
            key,value = line.split('=', 2).map {|s| s.strip}
            attributes[key] = value
          else
            errors << {:type => :unknown_line, :message => "Unhandled line in #{spec_file.to_s}:#{line_count}: #{line.inspect}"}
          end
        end

        # Now instantiate the right kind of part.
        return self.module_class(attributes['module']).new(attributes).tap {|p| p.send(:errors=, errors)}
      end

      # Return the class to instantiate for a given +module+ attribute.
      def self.module_class(module_name)
        ref_mod = Module.nesting[1]
        if( ref_mod.constants.include?(module_name.to_sym) )
          return ref_mod.const_get(module_name.to_sym)
        else
          return ref_mod.const_get(:Generic)
        end
      end

      # Initialize the part from the hash.  Note that this does NOT auto-select
      # the subclass.
      def initialize(attributes)
        @attributes = attributes.dup
      end

      # Return the raw attributes hash.
      #
      # Generally speaking it is better to use to_hash to keep from accidentally
      # altering the part by altering the attributes hash by reference.  That
      # being said, this is provided for special/power use cases.
      attr_reader :attributes

      # Return any errors with this part (usually found during parsing),
      # or an empty array if there were none.
      def errors
        return @errors || []
      end

      # Private method used to set the errors.
      attr_writer :errors
      private :errors=

      # Return the raw attribute value by string or symbol.
      #
      # It is generally preferrable to use the accessor method.
      def [](attr)
        return self.attributes[attr.to_s]
      end

      # Return a the part parameters as a hash.
      #
      # Currently this is implemented as a raw dump of the attributes hash,
      # but in the future it is planned to convert numeric types appropriately.
      def to_hash
        return attributes.dup
      end

      # Returns a JSON encoded form of the to_hash result.
      def to_json(*args)
        return self.to_hash.to_json(*args)
      end

      def name
        return self['name']
      end

      def title
        return self['title']
      end

      def description
        return self['description']
      end

      def category
        return self['category'].to_i
      end

      def category_name
        return CATEGORIES.invert[self.category]
      end

      def module
        return self['module']
      end

      def module_class
        return self.class.module_class(self.module)
      end

      def mass
        return self['mass'].to_f
      end

      def maximum_drag
        return self['maximum_drag'] && self['maximum_drag'].to_f
      end

      def drag
        return self.maximum_drag
      end

      def minimum_drag
        return self['minimum_drag'] && self['minimum_drag'].to_f
      end

      def max_temp
        return self['maxTemp'].to_f
      end

      def crash_tolerance
        return self['crashTolerance'].to_f
      end

      def impact_tolerance
        return self.crash_tolerance
      end

      def cost
        return self['cost'].to_i
      end

    end
  end
end
