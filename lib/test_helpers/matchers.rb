module TestHelpers
  module Matchers

    class GenerallyEqual

      EPSILON = 0.0001

      def initialize(expected)
        @expected = expected
      end

      def matches?(actual)
        @actual = actual

        if @actual.kind_of?(Float) || @expected.kind_of?(Float)
          (@expected - EPSILON .. @expected + EPSILON).include? @actual
        else
           @expected == @actual
        end
      end

      def failure_message_for_should
        "expected #{@actual.inspect} to be generally equal to #{@expected.inspect}"
      end

      def failure_message_for_should_not
        "expected #{@actual.inspect} not to be generally equal to #{@expected.inspect}"
      end
    end

    def be_generally_equal(expected)
      GenerallyEqual.new(expected)
    end

  end
end
