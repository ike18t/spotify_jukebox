#!/usr/bin/env ruby
require 'bundler/setup'
require 'main'

def autoload_all path
  Dir.glob("#{path}**/*.rb").each do |file|
    File.open(file, 'r') do |infile|
      while (line = infile.gets)
        match = line.match /^(class|module)\s([A-Z]\w+)/
        if not match.nil? and not match[2].nil?
          autoload match[2].to_sym, File.expand_path(file)
          break
        end
      end
    end
  end
end

autoload_all 'app/'

Main {
  option(:username) {
    argument :optional
    description 'Set the username'
  }

  option(:password) {
    argument :optional
    description 'Set the password'
  }

  option(:app_key) {
    argument :optional
    description 'Set the path to the application key'
  }

  def run
    updated = params.select(&:given?)
    updated = updated.inject({}) do |result, p|
      result[p.name.to_sym] = p.value
      result
    end
    ConfigService.update updated
  end
}
