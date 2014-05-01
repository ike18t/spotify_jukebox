#!/usr/bin/env ruby
require 'bundler/setup'
require 'main'
require_relative 'app/services/config_service'

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
