# lib/tasks/jwt_authentication/generate_tests.rake

namespace :jwt_authentication do
  desc "Generate tests for signup and login"
  task generate_tests: :environment do
    generate_auth_tests
  end

  # Private method to generate tests for signup and login
  def generate_auth_tests
    signup_test_file = <<~TEST
      # spec/controllers/signup_controller_spec.rb
      require 'rails_helper'

      RSpec.describe SignupController, type: :controller do
        describe 'POST #create' do
          context 'with valid attributes' do
            it 'creates a new user' do
              expect {
                post :create, params: { user: { username: 'testuser', email: 'test@example.com', password: 'password', password_confirmation: 'password' } }
              }.to change(User, :count).by(1)
            end

            it 'returns a JWT token' do
              post :create, params: { user: { username: 'testuser', email: 'test@example.com', password: 'password', password_confirmation: 'password' } }
              expect(response).to have_http_status(:created)
              expect(JSON.parse(response.body)).to have_key('token')
            end
          end

          context 'with invalid attributes' do
            it 'does not create a new user' do
              expect {
                post :create, params: { user: { username: '', email: 'test@example.com', password: 'password', password_confirmation: 'password' } }
              }.to_not change(User, :count)
            end

            it 'returns an error message' do
              post :create, params: { user: { username: '', email: 'test@example.com', password: 'password', password_confirmation: 'password' } }
              expect(response).to have_http_status(:unprocessable_entity)
              expect(JSON.parse(response.body)).to have_key('errors')
            end
          end
        end
      end
    TEST

    login_test_file = <<~TEST
      # spec/controllers/login_controller_spec.rb
      require 'rails_helper'

      RSpec.describe LoginController, type: :controller do
        let!(:user) { User.create(username: 'testuser', email: 'test@example.com', password: 'password', password_confirmation: 'password') }

        describe 'POST #create' do
          context 'with valid credentials' do
            it 'returns a JWT token' do
              post :create, params: { email: user.email, password: user.password }
              expect(response).to have_http_status(:ok)
              expect(JSON.parse(response.body)).to have_key('token')
            end
          end

          context 'with invalid credentials' do
            it 'returns an error message' do
              post :create, params: { email: user.email, password: 'wrongpassword' }
              expect(response).to have_http_status(:unauthorized)
              expect(JSON.parse(response.body)).to have_key('errors')
            end
          end
        end
      end
    TEST

    save_file("spec/controllers/signup_controller_spec.rb", signup_test_file)
    save_file("spec/controllers/login_controller_spec.rb", login_test_file)
    puts "Signup and login tests created in spec/controllers/"
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
