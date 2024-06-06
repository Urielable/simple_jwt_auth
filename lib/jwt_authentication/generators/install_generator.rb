# lib/jwt_authentication/generators/install_generator.rb
require 'rails/generators'
require 'rails/generators/migration'

module JwtAuthentication
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      def create_migration_file
        migration_template "create_users.rb", "db/migrate/create_users.rb"
      end

      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname)
        if ActiveRecord::Base.connection.migration_context.migrations.any?
          last_migration = ActiveRecord::Base.connection.migration_context.migrations.last.version
          (last_migration + 1).to_s
        else
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        end
      end
    end
  end
end
