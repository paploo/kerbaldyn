module KerbalDyn
  module Part
    # Parts without specific subclasses are defined as being of type Generic.
    #
    # At this time Generic parts are functionally no different than Base part,
    # however this is reserved to change in the future.
    class Generic < Base
    end
  end
end
