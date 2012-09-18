require 'pathname'

module KerbalDyn
  # PartLibrary is an array like list of Part objects with convenience methods
  # for common operations.
  class PartLibrary
    include Enumerable

    # Loads parts from a given directory into the library.
    def self.load_parts(directory)
      dir = Pathname.new(directory)
      raise "#{dir} is not a directory" unless dir.directory?

      parts = dir.children.reject do |part_dir|
        # Reject if it starts with a dot or is not a directory.
        (part_dir.basename.to_s =~ /^\./) || !part_dir.directory?
      end.inject([]) do |parts, part_dir|
        parts << Part::Base.load_part(part_dir)
      end

      return self.new(parts)
    end

    # Initialize with an array of parts or a list of parts.
    def initialize(*parts)
      @parts = parts.to_a.flatten
    end

    # Iterates over each part using a block.
    #
    # This is the root for all Enumerable methods.
    def each(&block)
      return @parts.each(&block)
    end

    # The lenght
    def length
      return @parts.length
    end

    # Returns the part with the given index or directory name
    def [](val)
      case val
      when Numeric
        return @parts[val]
      else
        return @parts.find {|part| part.directory_name == val}
      end
    end

  end
end

$lib = KerbalDyn::PartLibrary.load_parts("/Users/jreinecke/Downloads/NovaPunch1_3beta/NovaPunch/Parts")
