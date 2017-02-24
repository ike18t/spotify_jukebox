#!/usr/bin/env ruby
require 'bundler/setup'
require 'main'

def autoload_all(path)
  Dir.glob("#{path}**/*.rb").each do |file|
    File.open(file, 'r') do |infile|
      while (line = infile.gets)
        match = line.match(/^(class|module)\s([A-Z]\w+)/)
        if !match.nil? && !match[2].nil?
          autoload match[2].to_sym, File.expand_path(file)
          break
        end
      end
    end
  end
end

autoload_all 'app/'

Main do
  option(:username) do
    argument :optional
    description 'Set the username'
  end

  option(:password) do
    argument :optional
    description 'Set the password'
  end

  option(:client_id) do
    argument :optional
    description 'Set the Spotify client id'
  end

  option(:client_secret) do
    argument :optional
    description 'Set the Spotify client secret'
  end

  option(:app_key) do
    argument :optional
    description 'Set the path to the application key'
  end

  def run
    updated = params.select(&:given?)
    updated = updated.each_with_object({}) do |param, result|
      result[param.name.to_sym] = param.value
      result
    end
    ConfigService.update updated
  end
end
