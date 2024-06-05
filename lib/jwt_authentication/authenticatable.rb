module JWTAuthentication
  module Authenticatable
    extend ActiveSupport::Concern

    included do
      has_secure_password

      validates :email, presence: true, uniqueness: true
      validates :password, presence: true, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
    end

    def generate_jwt
      JWTAuthentication.encode(id: id)
    end
  end
end
