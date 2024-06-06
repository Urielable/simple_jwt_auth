# frozen_string_literal: true

require_relative "jwt_authentication/version"
require "jwt_authentication/authenticatable"
require "jwt_authentication/controllers/auth_controller"
require "jwt_authentication/railtie" if defined?(Rails)

require 'jwt'
require 'bcrypt'

module JwtAuthentication
  class << self
    # Método para generar un token JWT
    def encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, Rails.application.secrets.secret_key_base)
    end

    # Método para decodificar un token JWT
    def decode(token)
      body = JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
      HashWithIndifferentAccess.new body
    rescue
      nil
    end
  end
end
