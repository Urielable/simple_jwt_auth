module JWTAuthentication
  module Controllers
    class AuthController < ActionController::API
      before_action :authorize_request, except: :login

      # POST /auth/register
      def register
        @user = User.new(user_params)
        if @user.save
          render json: { user: @user, token: @user.generate_jwt }, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /auth/login
      def login
        @user = User.find_by(email: params[:email])
        if @user&.authenticate(params[:password])
          token = @user.generate_jwt
          render json: { user: @user, token: token }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end

      def authorize_request
        header = request.headers['Authorization']
        header = header.split(' ').last if header
        begin
          @decoded = JWTAuthentication.decode(header)
          @current_user = User.find(@decoded['id'])
        rescue ActiveRecord::RecordNotFound => e
          render json: { errors: e.message }, status: :unauthorized
        rescue JWT::DecodeError => e
          render json: { errors: e.message }, status: :unauthorized
        end
      end
    end
  end
end
