require 'rack/coffee_compiler'

module Jasmine
  class Configuration
    alias_method :old_js_files, :js_files

    def js_files
      # Convert all .coffee files into .js files before putting them in a script tag
      old_js_files.map do |filename|
        filename.sub(/\.coffee/, '.js')
      end
    end
  end
end

module Jasmine
  class Server
    def start
      root = File.expand_path(File.join(File.dirname(__FILE__), '../../..'))

      config = Jasmine.config
      @application = Rack::Builder.new do
        # Compiler for your specs
        use Rack::CoffeeCompiler,
            source_dir: File.join(root, 'spec/js'),
            url: config.spec_path

        # Compiler for your app files
        use Rack::CoffeeCompiler,
            source_dir: File.join(root, 'app/js'),
            url: 'app/js'

        run Jasmine::Application.app(config)
      end

      server = Rack::Server.new(@rack_options.merge(Port: @port, AccessLog: []))
      # workaround for Rack bug, when Rack > 1.2.1 is released Rack::Server.start(:app => Jasmine.app(self)) will work
      server.instance_variable_set(:@app, @application)
      server.start
    end
  end
end
