# lib/tasks/jwt_authentication/add_routes.rake

namespace :jwt_authentication do
  desc "Add routes for signup and login"
  task add_routes: :environment do
    append_to_routes
  end

  # Private method to append routes to routes.rb
  def append_to_routes
    routes_content = <<~ROUTES
      # Routes for authentication
      post 'signup', to: 'signup#create'
      post 'login', to: 'login#create'
    ROUTES

    # Read the content of the existing routes file
    existing_content = File.read("config/routes.rb")

    # Check if the routes are already present
    unless existing_content.include?("post 'signup', to: 'signup#create'") && existing_content.include?("post 'login', to: 'login#create'")
      # Find the index of the last "end" keyword in the routes file
      end_index = existing_content.rindex("end")

      # Insert the new routes before the last "end"
      new_content = existing_content.insert(end_index, routes_content)

      # Write the updated content back to the file
      save_file("config/routes.rb", new_content)
      puts "Routes added to config/routes.rb"
    else
      puts "Routes already exist in config/routes.rb"
    end
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
