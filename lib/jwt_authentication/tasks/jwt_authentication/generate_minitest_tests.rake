# lib/generators/jwt_authentication/generate_minitest_tests.rake

namespace :jwt_authentication do
  desc "Generate MiniTest tests for signup and login"
  task generate_minitest_tests: :environment do
    generate_minitest_auth_tests
    Rake::Task['jwt_authentication:create_test_user'].invoke
  end

  # Private method to generate MiniTest tests for signup and login
  def generate_minitest_auth_tests
    signup_test_file = <<~TEST
      # test/controllers/signup_controller_test.rb
      require 'test_helper'
      require 'pry'

      class SignupControllerTest < ActionDispatch::IntegrationTest
        test "should create user with valid attributes" do
          post signup_url, params: { user: { name: 'testuser', last_name: 'testuser', email: 'testsign_up@example.com', password: 'password', password_confirmation: 'password' } }
          
          assert_response :created
          assert JSON.parse(response.body).key?('token')
        end

        test "should not create user with invalid attributes" do
          assert_no_difference('User.count') do
            post signup_url, params: { user: { name: '', last_name: '', email: 'testsign_up2@example.com', password: 'password', password_confirmation: 'password' } }
          end
          assert_response :unprocessable_entity
          assert JSON.parse(response.code).equal?(422)
        end
      end
    TEST

    login_test_file = <<~TEST
      # test/controllers/login_controller_test.rb
      require 'test_helper'

      class LoginControllerTest < ActionDispatch::IntegrationTest
        # Load fixtures
        fixtures :users

        setup do
          @user = users(:one)
        end

        test "should login with valid credentials" do
          post login_url, params: { email: @user.email, password: 'password' }
          assert_response :success
          assert JSON.parse(response.body).key?('token')
        end

        test "should not login with invalid credentials" do
          post login_url, params: { email: @user.email, password: 'wrongpassword' }
          assert_response :unauthorized
          assert JSON.parse(response.code).equal?(401)
        end
      end
    TEST

    save_file("test/controllers/signup_controller_test.rb", signup_test_file)
    save_file("test/controllers/login_controller_test.rb", login_test_file)
    puts "MiniTest tests for signup and login created in test/controllers/"
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
