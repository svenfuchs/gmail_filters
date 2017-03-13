module Gmail
  module Filters
    class Cli
      module Opts
        class Options < OptionParser
          attr_reader :opts

          def initialize(opts, args)
            @opts = {}
            super { opts.each { |args, block| on(*args) { |*args| instance_exec(*args, &block) } } }
            parse!(args)
          end
        end

        def self.included(base)
          base.send(:extend, ClassMethods)
        end

        module ClassMethods
          def on(*args, &block)
            opts << [args, block]
          end

          def opts
            @opts ||= []
          end
        end

        def parse_opts(args, opts = [])
          Options.new(self.class.opts + opts, args).opts
        end
      end
    end
  end
end
