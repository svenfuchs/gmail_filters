require 'yaml'
require 'gmail/filters/cli/cmds'
require 'gmail/filters/cli/opts'

module Gmail
  module Filters
    class Cli
      include Opts

      DEFAULTS = {
        config: '~/.gmail_filters/config.yml'
      }

      on '-c CONFIG', '--config CONFIG' do |value|
        opts[:source] = value
      end

      attr_reader :args

      def initialize(args)
        @args = args
      end

      def run(io = STDOUT)
        cmds = args.take_while { |arg| !arg.start_with?('-') }.flatten
        cmd  = self.class.const_get(camelize(cmds.first || fail('No command given')))
        opts = parse_opts(args, cmd.opts)
        opts = config(opts[:config] || DEFAULTS[:config]).merge(opts)
        io.puts cmd.new(opts).run
      end

      def config(path)
        return {} unless path
        path = File.expand_path(path)
        File.exists?(path) ? symbolize_keys(YAML.load_file(path)) : {}
      end

      def symbolize_keys(hash)
        hash.map { |key, value| [key.to_sym, value] }.to_h
      end

      def camelize(str)
        str.split('_').collect(&:capitalize).join
      end
    end
  end
end
