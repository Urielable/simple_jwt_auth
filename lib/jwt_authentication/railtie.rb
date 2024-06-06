# lib/jwt_authentication/railtie.rb
require 'jwt_authentication'
require 'rails'

module JwtAuthentication
  class Railtie < Rails::Railtie
    railtie_name :jwt_authentication

    rake_tasks do
      load "tasks/jwt_authentication_tasks.rake"
    end

    generators do
      require "generators/install_generator"
    end
  end
end
