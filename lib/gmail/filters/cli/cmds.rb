require 'gmail/filters/cli/opts'

module Gmail
  module Filters
    class Cli
      class Export < Struct.new(:opts)
        include Opts

        DEFAULTS = {
          source: '~/.gmail_filters/*.rb'
        }

        on '-a AUTHOR', '--author AUTHOR' do |value|
          opts[:author] = value
        end

        on '-e EMAIL', '--email EMAIL' do |value|
          opts[:email] = value
        end

        on '-s SOURCE', '--source SOURCE' do |value|
          opts[:source] = value
        end

        def run
          filters = Gmail::Filters::Model::Filters.new(opts)
          load_sources(filters, opts[:source] || DEFAULTS[:source])
          Xml::Doc.new(filters).render
        end

        private

          def load_sources(filters, sources)
            sources = sources.split(',')
            sources = sources.map { |path| File.expand_path(path) }
            Dir[*sources].each { |path| load_source(filters, path) }
          end

          def load_source(filters, path)
            set = Model::Set.new
            dsl = Dsl::Set.new(set)
            dsl.instance_eval(File.read(path), __FILE__, __LINE__)
            filters.sets << set
          end
      end
    end
  end
end
