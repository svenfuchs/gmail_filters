module Gmail
  module Filters
    class Expr
      class << self
        def build(strs)
          group(strs).inject(And.new) do |expr, strs|
            expr << Or.new(*strs)
          end
        end

        private

          def group(strs)
            strs ||= []
            groups = strs.map { |str| str.split(':') }
            groups = groups.group_by(&:first).values
            groups.map { |group| group.map { |strs| strs.join(':') } }
          end
      end

      attr_reader :op, :exprs

      def initialize(op, *exprs)
        @op = op
        @exprs = exprs
      end

      def <<(expr)
        exprs << expr
        self
      end

      def size
        exprs.size
      end

      class And < Expr
        def initialize(*exprs)
          super(:AND, *exprs)
        end

        def to_s
          strs = exprs.map { |expr| expr.is_a?(Or) && expr.size > 1 ? "(#{expr.to_s})" : expr.to_s }
          strs = strs.reject(&:empty?)
          strs.join(" #{op} ")
        end
      end

      class Or < Expr
        def initialize(*exprs)
          super(:OR, *exprs)
        end

        def to_s
          strs = exprs.map(&:to_s).reject(&:empty?)
          size > 1 ? strs.join(" #{op} ") : strs.join
        end
      end

      class Not
        attr_reader :expr

        def initialize(expr)
          @expr = expr
        end

        def to_s
          case expr.size
          when 0
            ''
          when 1
            "-#{expr.to_s}"
          else
            "-(#{expr.to_s})"
          end
        end
      end
    end
  end
end
