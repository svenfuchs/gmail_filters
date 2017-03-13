module Gmail
  module Filters
    class Dsl
      class Set
        attr_reader :set

        def initialize(set, &block)
          @set = set
          instance_eval(&block) if block
        end

        def filter(opts = {}, &block)
          filter = Model::Filter.new(opts)
          Filter.new(filter, &block)
          set.filters << filter
        end

        def otherwise(&block)
          except = set.filters.inject([]) { |result, f| result + f.except + f.only }.uniq
          filter(except: except, &block)
        end
      end

      class Filter
        attr_reader :filter

        def initialize(filter, &block)
          @filter = filter
          instance_eval(&block) if block
        end

        def from(*args)
          only *args.map { |arg| "from:#{arg}" }
        end

        def to(*args)
          only *args.map { |arg| "to:#{arg}" }
        end

        def list(*args)
          only *args.map { |arg| "list:#{arg}" }
        end

        def has(*args)
          filter.only(*args)
        end
        alias only has

        def label(arg)
          filter.label = arg
        end

        def mark_read
          filter.mark_read = true
        end

        def archive
          filter.archive = true
        end

        def delete
          filter.delete = true
        end
      end
    end
  end
end
