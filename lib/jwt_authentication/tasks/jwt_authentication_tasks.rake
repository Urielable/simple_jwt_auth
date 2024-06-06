# lib/tasks/jwt_authentication_tasks.rake

namespace :jwt_authentication do
  desc "Generates authentication models and controllers for login and signup"
  task generate_auth_resources: :environment do
    # Generate User model
    generate_user_model

    # Generate authentication controllers
    generate_login_controller
    generate_signup_controller

    # Append application controller content
    append_to_application_controller
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

# Private method to append content to the application controller
def append_to_application_controller
  application_controller_content = <<~CONTROLLER
    before_action :authorize_request

    private

    def authorize_request
      header = request.headers['Authorization']
      header = header.split(' ').last if header
      begin
        @decoded = JwtAuthentication.decode(header)
        @current_user = User.find(@decoded[:id])
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: e.message }, status: :unauthorized
      rescue JWT::DecodeError => e
        render json: { errors: e.message }, status: :unauthorized
      end
    end

    # Private method to generate JWT token
    def generate_token(user_id)
      JWT.encode({ user_id: user_id }, Rails.application.secret_key_base)
    end
  CONTROLLER

  # Read the content of the existing file
  existing_content = File.read("app/controllers/application_controller.rb")

  # Find the index of the last "end" keyword
  end_index = existing_content.rindex("end")

  # Insert the new content before the last "end"
  new_content = existing_content.insert(end_index, application_controller_content)

  # Write the updated content back to the file
  File.open("app/controllers/application_controller.rb", "w") do |file|
    file.puts new_content
  end

  puts "Content appended to app/controllers/application_controller.rb"
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
