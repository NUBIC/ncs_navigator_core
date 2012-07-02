

require 'ncs_navigator/core'

require 'forwardable'

module NcsNavigator::Core::Psc
  ##
  # This is a copy of Faraday::Response::Logger that logs entities as well.
  class Logger < ::Faraday::Response::Logger
    extend Forwardable

    attr_reader :app
    def_delegators :@logger, :debug, :info, :warn, :error, :fatal

    def initialize(app, logger)
      @app = app
      @logger = logger
    end

    def call(env)
      info('Request') { dump_env(env, 'Request', "#{env[:method]} #{env[:url].to_s}") }

      app.call(env).on_complete do |environment|
        info('Response') { dump_env(environment, 'Response', environment[:status].to_s) }
      end
    end

    def dump_env(env, req_or_resp, extra)
      req_or_resp + "\n" + ('-' * req_or_resp.size) + "\n" +
        extra + "\n" +
        "Headers:\n" +
        dump_headers(env[:"#{req_or_resp.downcase}_headers"]) + "\n" +
        "Entity: " + env[:body].to_s + "\n"
    end

    def dump_headers(headers)
      headers.map { |k, v| "  #{k}: #{v.inspect}" }.join("\n")
    end
    private :dump_headers
  end
end