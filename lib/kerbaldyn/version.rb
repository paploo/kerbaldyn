module KerbalDyn
  class Version
    MAJOR = 0
    MINOR = 0
    TINY  = 1

    def self.to_s
      return [MAJOR, MINOR, TINY].join('.')
    end
  end

  VERSION = Version.to_s
end
