# lib/tasks/jwt_authentication/generate_resources.rake

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

  # Private method to generate the User model
  def generate_user_model
    user_model_file = <<~MODEL
      # app/models/user.rb
      class User < ApplicationRecord

        has_secure_password

        validates :username, presence: true, uniqueness: true
        validates :email, presence: true, uniqueness: true
        validates :password, presence: true, length: { minimum: 6 }

        # Add this class method to create password digests
        def self.digest(string)
          cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
          BCrypt::Password.create(string, cost: cost)
        end
      end
    MODEL

    save_file("app/models/user.rb", user_model_file)
    puts "User model created in app/models/user.rb"
  end

  # Private method to generate the Login controller
  def generate_login_controller
    login_controller_file = <<~CONTROLLER
      # app/controllers/login_controller.rb
      class LoginController < ApplicationController
        skip_before_action :authorize_request, only: :create

        def create
          user = User.find_by(email: params[:email])
          if user&.authenticate(params[:password])
            token = generate_token(user.id)
            render json: { token: token }, status: :ok
          else
            render json: { errors: 'Invalid email or password' }, status: :unauthorized
          end
        end
      end
    CONTROLLER

    save_file("app/controllers/login_controller.rb", login_controller_file)
    puts "Login controller created in app/controllers/login_controller.rb"
  end

  # Private method to generate the Signup controller
  def generate_signup_controller
    signup_controller_file = <<~CONTROLLER
      # app/controllers/signup_controller.rb
      class SignupController < ApplicationController
        skip_before_action :authorize_request, only: :create

        def create
          user = User.new(user_params)
          if user.save
            render json: { message: 'User created successfully', token: generate_token(user.id) }, status: :created
          else
            render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def user_params
          params.require(:user).permit(:username, :email, :password, :password_confirmation)
        end
      end
    CONTROLLER

    save_file("app/controllers/signup_controller.rb", signup_controller_file)
    puts "Signup controller created in app/controllers/signup_controller.rb"
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
          @current_user = User.find(@decoded[:user_id])
        rescue ActiveRecord::RecordNotFound => e
          render json: { errors: e.message }, status: :unauthorized
        rescue JWT::DecodeError => e
          render json: { errors: e.message }, status: :unauthorized
        end
      end

      # Private method to generate JWT token
      def generate_token(user_id)
        JWT.encode({ user_id: user_id }, Rails.application.config.jwt_secret_key)
      end
    CONTROLLER

    # Read the content of the existing file
    existing_content = File.read("app/controllers/application_controller.rb")

    # Find the index of the last "end" keyword
    end_index = existing_content.rindex("end")

    # Insert the new content before the last "end"
    new_content = existing_content.insert(end_index, application_controller_content)

    # Write the updated content back to the file
    save_file("app/controllers/application_controller.rb", new_content)
    puts "Content appended to app/controllers/application_controller.rb"
  end

  # Helper method to save file content
  def save_file(file_path, content)
    if File.exist?(file_path)
      puts "#{file_path} already exists. Do you want to overwrite it? (yes/no)"
      answer = STDIN.gets.chomp
      if answer.downcase != 'yes'
        puts "Skipping #{file_path}"
        return
      end
    end

    File.open(file_path, "w") do |file|
      file.puts content
    end
  end
end
