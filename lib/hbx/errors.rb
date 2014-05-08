module Hbx
  module Errors
    class MissingHeaderError < StandardError
    end

    class NoSuchTransformError < StandardError
    end

    class NoSuchSchemaError < StandardError
    end

    class ValidationFailedError < StandardError
      def ==(other)
        return false unless other.class == ValidationFailedError
        self.message == other.message
      end
    end
  end
end
