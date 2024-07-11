# Changelog

## [Unreleased]

### Added
- Initial implementation of the `jwt_authentication` gem for Rails applications.
- Added `User` model with `Authenticatable` module integration.
- Implemented `SignupController` and `LoginController` for user registration and authentication.
- Added JWT-based authentication with `authorize_request` method in `ApplicationController`.
- Created tasks for generating user model, signup controller, login controller, and appending authentication logic to `ApplicationController`.
- Ensured routes for `signup` and `login` are automatically added within the `Rails.application.routes.draw` block.
- Added `.env` file support using `dotenv-rails` for managing environment variables.
- Included JWT token generation and decoding methods.
- Added ability to append content to `ApplicationController` without overwriting existing content.
- Provided user prompts for file overwrites during task execution.

### Fixed
- Correctly handled the insertion of new routes within the `Rails.application.routes.draw` block.
- Fixed indentation issues when appending methods to `ApplicationController`.
- Ensured tasks check for existing files and provide prompts before overwriting.
- Handled initialization of the `Authenticatable` module and its inclusion in the `User` model.

### Security
- Utilized `has_secure_password` for secure password handling in the `User` model.
- Configured JWT secret key management using environment variables loaded from a `.env` file.

### Changed
- Updated task methods to support appending content to existing files instead of overwriting them.
- Refactored task logic to ensure proper placement of generated content in controllers and routes.

---

## [0.2.0] - 2024-07-11

### Added
- Initial release of the `jwt_authentication` gem.
- Basic JWT authentication setup for Rails applications.
- Task to generate user model and authentication controllers.
- JWT token generation and verification logic.

### Security
- Basic user authentication with JWT.
- Secure password handling with `has_secure_password`.

---

## [0.2.1] - 2024-07-01

### Added
- Project setup and initial gem structure.
- Basic JWT token handling.

## [0.3.2] - 2024-07-01
- Adds this Changelog
- Adds append to routes to adds login and sign_up endpoints.
- Adds last_name to migration and user model.