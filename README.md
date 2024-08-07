# JWT Authentication Gem

[![Gem Version](https://badge.fury.io/rb/jwt_authentication.svg)](https://badge.fury.io/rb/jwt_authentication)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Overview

The JWT Authentication gem provides easy-to-use JWT authentication for Ruby on Rails applications. It allows you to quickly integrate JSON Web Token (JWT) authentication into your Rails API, providing secure user authentication without the need for session management.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jwt_authentication'
```

And then execute:

```bash
bundle install
```

## Usage


### Task Generation

To generate authentication resources in your Rails application, run:

```bash
# Generate authentication resources (models, controllers, append to application controller)
rails jwt_authentication:generate_auth_resources

# Add routes for signup and login
rails jwt_authentication:add_routes
```

This will create a user model (`User`) and authentication controllers (`LoginController` and `SignupController`) in your application.

### Automatic Migration Installation

Run the generator to copy the migrations to your application:

```bash
rails generate jwt_authentication:install
rails db:migrate
```

### Manual Migration Installation

If you prefer not to use the generator, you can manually copy the migration file:

1. Copy the migration file from `lib/generators/jwt_authentication/templates/create_users.rb` to your application's `db/migrate` directory.
2. Ensure the migration file name has a timestamp to avoid conflicts. For example: `20230604010101_create_users.rb`.
3. Run the migrations:

```bash
rails db:migrate
```

### Usage in Application

#### Model

Include the `Authenticatable` module in your `User` model:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  include JwtAuthentication::Authenticatable
end
```

#### Controller

Use the authentication logic in your controllers:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
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
end
```

## Testing

To ensure that the authentication functionality works correctly, we have included tests for the `SignupController` and `LoginController`. Follow the steps below to run the tests.

RSpec:

```bash
# Generate tests for signup and login with RSpec
rails jwt_authentication:generate_rspec_tests

```

Minitest:

```bash
# Generate tests for signup and login with MiniTest
rails jwt_authentication:generate_fixtures
rails jwt_authentication:generate_minitest_tests
```


### Prerequisites

Make sure you have RSpec installed in your Rails application. If RSpec is not already installed, add it to your Gemfile:

```ruby
# Gemfile
group :development, :test do
  gem 'rspec-rails', '~> 4.0.0'
end
```

Install gems: 
```
bundle install
rails generate rspec:install
```

Running the Tests

The tests for the authentication functionality are located in the spec/controllers directory. 

## Gem Structure

Here’s an overview of the file structure for gem:
```
jwt_authentication/
├── lib/
│   ├── jwt_authentication/
│   │   ├── authenticatable.rb
│   │   ├── controllers/
│   │   │   └── auth_controller.rb
│   │   ├── generators/
│   │   │   └── jwt_authentication/
│   │   │       ├── install_generator.rb
│   │   │       └── templates/
│   │   │           └── create_users.rb
│   │   ├── tasks/
│   │   │   └── jwt_authentication_tasks.rake
│   │   ├── railtie.rb
│   │   └── version.rb
│   └── jwt_authentication.rb
├── jwt_authentication.gemspec
└── README.md
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/urielable/jwt_authentication](https://github.com/urielable/jwt_authentication). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/urielable/jwt_authentication/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JWT Authentication project's codebases, issue trackers, chat rooms, and mailing lists is expected to follow the [code of conduct](https://github.com/urielable/jwt_authentication/blob/main/CODE_OF_CONDUCT.md).
