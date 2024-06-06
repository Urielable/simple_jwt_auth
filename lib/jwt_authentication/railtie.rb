# lib/jwt_authentication/railtie.rb
require 'jwt_authentication'
require 'rails'

module JwtAuthentication
  class Railtie < Rails::Railtie
    railtie_name :jwt_authentication

    generators do
      require "jwt_authentication/generators/install_generator"
    end
  end
end
