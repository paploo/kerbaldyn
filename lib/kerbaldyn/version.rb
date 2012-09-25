module KerbalDyn
  class Version
    MAJOR = 0
    MINOR = 5
    TINY  = 0

    def self.to_s
      return [MAJOR, MINOR, TINY].join('.')
    end
  end

  VERSION = Version.to_s
end
