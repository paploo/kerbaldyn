require 'pathname'

module KerbalDyn
  module Part
    class Base
      CATEGORIES = {'Propulsion' => 0, 'Command & Control' => 1, 'Structural & Aerodynamic' => 2, 'Utility & Scientific' => 3, 'Decals' => 4, 'Crew' => 5}

      def self.load_part(directory)
        # Process the argument.
        dir = Pathname.new(directory)
        return nil unless dir.directory?

        # Get a handle on the spec file.
        spec_file = dir + 'part.cfg'
        return nil unless spec_file.file?

        # Initialize the attributes container.
        attributes = {}
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
            STDERR.puts "Unhandled line in #{spec_file.to_s}:#{line_count}: #{line.inspect}"
          end
        end

        # Now instantiate the right kind of part.
        return self.module_class(attributes['module']).new(attributes)
      end

      def self.module_class(module_name)
        ref_mod = Module.nesting[1]
        if( ref_mod.constants.include?(module_name.to_sym) )
          return ref_mod.const_get(module_name.to_sym)
        else
          return ref_mod.const_get(:Generic)
        end
      end

      def initialize(attributes)
        @attributes = attributes.dup
      end

      attr_reader :attributes

      def [](attr)
        return self.attributes[attr.to_s]
      end

      def to_hash
        return attributes.dup
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
