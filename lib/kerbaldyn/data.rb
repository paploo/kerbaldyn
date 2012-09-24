require 'pathname'

module KerbalDyn
  # :nodoc: all
  #
  # A class for doing the work of getting and maintaining singletons of data resources.
  #
  # NOTE: There is NO reason a client to the library shoudl be in here; indeed, this
  # is likely to drastically change, so using this class directly will result in
  # trouble later.
  class Data
    # Files added here are automatically recognized by the fetch method.
    # Files must be in the data directory.
    FILE_MAP = {
      :planet_data => 'planet_data.json'
    }

    # Fetch a data singleton by the stored key.
    #
    # If the key is unknown, then it attempts to fetch the data from disk.
    def self.fetch(key)
      registry = self.registry
      data_obj = registry.include?(key) ? registry[key] : registry[key]=self.new(key, FILE_MAP[key])
      return data_obj.data
    end

    # A method for directly getting the registry; this shoudl typically be treated as private.
    def self.registry
      return @registry ||= {}
    end

    # Initialize with the given key and data file name (in the data directory).
    # This does NOT auto-add to the registry.  Fetch will do so for entries in
    # FILE_MAP.
    def initialize(key, data_file_name)
      # Get a handle on the file.
      data_file = Pathname.new(__FILE__).dirname + 'data' + data_file_name.to_s
      raise ArgumentError, "No such file #{data_file.to_s}" unless data_file.exist?

      # Parse
      @data = case data_file.extname
              when '.json'
                JSON.parse( data_file.read, :symbolize_names => true )
              else
                raise ArgumentError "Cannot parse files of type #{data_file.extname}"
              end

      # Set key and freeze
      @key = key.freeze
      @data.freeze
    end

    attr_reader :key, :data

  end
end
