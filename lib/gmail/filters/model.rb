module Gmail
  module Filters
    module Model
      class Filters
        attr_reader :sets, :opts

        def initialize(opts = {})
          @opts = opts
          @sets = []
        end

        def author
          opts[:author] || 'Unknown author'
        end

        def email
          opts[:email] || 'Unknown email'
        end

        def map(&block)
          sets.map(&block)
        end
      end

      class Set
        def filters
          @filters ||= []
        end
      end

      class Filter
        attr_accessor :label, :archive, :mark_read, :delete

        def initialize(opts = {})
          opts.each { |key, obj| instance_variable_set(:"@#{key}", obj) }
        end

        def only(*only)
          @only ||= []
          @only.concat(only) if only.any?
          @only
        end

        def except
          @except ||= []
        end

        def to_h
          compact(
            has: to_s,
            label: label,
            mark_read: mark_read,
            archive: archive,
            delete: delete
          )
        end

        def to_s
          Expr::And.new(Expr.build(only), Expr::Not.new(Expr.build(except))).to_s
        end

        private

          def compact(hash)
            hash.reject { |_, obj| blank?(obj) }
          end

          def blank?(obj)
            obj.nil? || obj.respond_to?(:empty?) && obj.empty?
          end
      end
    end
  end
end
