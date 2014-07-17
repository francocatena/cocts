class UsersController < ApplicationController
  include Users::Sessions
  include Users::PersonalData

  before_action :set_title, except: [:destroy, :update_password,
    :logout, :update_personal_data]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :auth, except: [:login, :create_session]
  before_action :admin, except: [:login, :create_session, :edit_password,
    :update_password, :edit_personal_data, :update_personal_data,:logout]
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

    respond_to do |format|
      if @user.save
        UserMailer.new_user_notification(@user, pass).deliver
        flash[:notice] = t :'users.correctly_created'
        format.html { redirect_to(users_path) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => :new }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /users/1
  def update
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    respond_to do |format|
      if @user.update_attributes(user_params)
        flash[:notice] = t :'users.correctly_updated'
        format.html { redirect_to(users_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::StaleObjectError
    flash[:alert] = t :'users.stale_object_error'
    redirect_to edit_user_path(@user)
  end

  # * DELETE /users/1
  def destroy
    unless @user.destroy
      flash[:alert] = t :'users.project_error'
    end

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  def admin
    unless @auth_user.admin?
      flash[:alert] = t :'users.admin_error'
      redirect_to projects_path
    end
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
