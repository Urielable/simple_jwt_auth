namespace :jwt_authentication do
  desc "Create a test user for login tests"
  task create_test_user: :environment do
    User.create(username: 'testuser', email: 'test@example.com', password: 'password', password_confirmation: 'password')
    puts "Test user created with email 'test@example.com' and password 'password'"
  end
end
