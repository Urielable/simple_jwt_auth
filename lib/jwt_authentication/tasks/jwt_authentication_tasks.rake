# lib/tasks/jwt_authentication_tasks.rake

namespace :jwt_authentication do
  desc "Generates authentication models and controllers for login and signup"
  task generate_auth_resources: :environment do
    # Generate User model
    generate_user_model

    # Generate authentication controllers
    generate_login_controller
    generate_signup_controller
  end
end

# Private method to generate the User model
def generate_user_model
  user_model_file = <<~MODEL
    # app/models/user.rb
    class User < ApplicationRecord
      include JwtAuthentication::Authenticatable
      # Add your user model associations, validations, etc. here
    end
  MODEL

  # Save the content to the file
  save_file("app/models/user.rb", user_model_file)
end

# Private method to generate the login controller
def generate_login_controller
  login_controller_file = <<~CONTROLLER
    # app/controllers/login_controller.rb
    class LoginController < ApplicationController
      def create
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          render json: { token: generate_token(user.id) }
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end
    end
  CONTROLLER

  # Save the content to the file
  save_file("app/controllers/login_controller.rb", login_controller_file)
end

# Private method to generate the signup controller
def generate_signup_controller
  signup_controller_file = <<~CONTROLLER
    # app/controllers/signup_controller.rb
    class SignupController < ApplicationController
      def create
        user = User.new(user_params)
        if user.save
          render json: { token: generate_token(user.id) }, status: :created
        else
          render json: { error: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end
  CONTROLLER

  # Save the content to the file
  save_file("app/controllers/signup_controller.rb", signup_controller_file)
end

# Private method to generate JWT token
def generate_token(user_id)
  JWT.encode({ user_id: user_id }, Rails.application.secret_key_base)
end

# Private method to save content to a file
def save_file(file_path, content)
  if File.exist?(file_path)
    print "File '#{file_path}' already exists. Do you want to overwrite it? (y/n): "
    answer = $stdin.gets.chomp
    return unless answer.downcase == 'y'
  end

  File.open(file_path, "w") do |file|
    file.puts content
  end

  puts "File '#{file_path}' created"
end
