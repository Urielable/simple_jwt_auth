namespace :jwt_authentication do
  desc "Generate authentication models and controllers for login and signup"
  task :generate_auth_resources do
    # Generate the user model
    generate_user_model

    # Generate the authentication controllers
    generate_login_controller
    generate_signup_controller
  end
end

# Private method to generate the user model
def generate_user_model
  # User model file
  user_model_file = <<~MODEL
    # app/models/user.rb
    class User < ApplicationRecord
      include JwtAuthentication::Authenticatable

      # Add your user model associations, validations, etc. here
    end
  MODEL

  # Save the content to the file
  File.open("app/models/user.rb", "w") do |file|
    file.puts user_model_file
  end

  puts "User model created in app/models/user.rb"
end

# Private method to generate the login controller
def generate_login_controller
  # Login controller file
  login_controller_file = <<~CONTROLLER
    # app/controllers/login_controller.rb
    class LoginController < ApplicationController
      def create
        # Implement login logic here
      end
    end
  CONTROLLER

  # Save the content to the file
  File.open("app/controllers/login_controller.rb", "w") do |file|
    file.puts login_controller_file
  end

  puts "Login controller created in app/controllers/login_controller.rb"
end

# Private method to generate the signup controller
def generate_signup_controller
  # Signup controller file
  signup_controller_file = <<~CONTROLLER
    # app/controllers/signup_controller.rb
    class SignupController < ApplicationController
      def create
        # Implement signup logic here
      end
    end
  CONTROLLER

  # Save the content to the file
  File.open("app/controllers/signup_controller.rb", "w") do |file|
    file.puts signup_controller_file
  end

  puts "Signup controller created in app/controllers/signup_controller.rb"
end
