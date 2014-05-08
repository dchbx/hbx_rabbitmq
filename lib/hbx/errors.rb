module Hbx
  module Errors
    class MissingHeaderError < StandardError
    end

    class NoSuchTransformError < StandardError
    end

    class NoSuchSchemaError < StandardError
    end
  end
end
