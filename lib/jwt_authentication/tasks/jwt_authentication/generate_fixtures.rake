# lib/generators/jwt_authentication/generate_fixtures.rake

namespace :jwt_authentication do
  desc "Generate fixtures for MiniTest"
  task generate_fixtures: :environment do
    generate_users_fixture
  end

  # Private method to generate users fixture
  def generate_users_fixture
    users_fixture = <<~FIXTURE
      # test/fixtures/users.yml
      one:
        name: testuser
        email: test@example.com
        password_digest: <%= User.digest('password') %>

      two:
        name: anotheruser
        email: another@example.com
        password_digest: <%= User.digest('password') %>
    FIXTURE

    save_file("test/fixtures/users.yml", users_fixture)
    puts "Users fixture created in test/fixtures/users.yml"
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
