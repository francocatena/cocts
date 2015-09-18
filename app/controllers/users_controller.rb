class UsersController < ApplicationController
  include Users::Sessions
  include Users::PersonalData

  before_action :set_title, except: [:destroy, :update_password,
    :logout, :update_personal_data]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  prepend_before_action :auth, except: [:login, :create_session]

  layout proc { |controller|
    ['login', 'session'].include?(controller.action_name) ?
      'clean' : 'application'
  }

  respond_to :html

  # * GET /users
  def index
    @users = User.search(params[:search], params[:page])
  end

  # * GET /users/1
  def show
  end

  # * GET /users/new
  def new
    @user = User.new
  end

  # * GET /users/1/edit
  def edit
  end

  # * POST /users
  def create
    pass = params[:user][:password]
    @user = User.new(user_params)

    UserMailer.new_user_notification(@user, pass).deliver_now if @user.save
    respond_with @user, location: users_url
  end

  # * PUT /users/1
  def update
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    update_resource @user, user_params

    respond_with @user, location: users_url unless response_body
  end

  # * DELETE /users/1
  def destroy
    flash[:alert] = t 'users.project_error' unless @user.destroy

    respond_with @user, location: users_url
  end

  private

    def set_user
      @user = User.find params[:id]
    end

    def user_params
      params.require(:user).permit(
        :user, :name, :lastname, :password, :password_confirmation, :email, :enable,
        :private, :admin, :lock_version
      )
    end
end
