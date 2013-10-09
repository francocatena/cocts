class UsersController < ApplicationController
  before_action :auth, :except => [:login, :create_session]
  before_action :admin, :except => [:login, :create_session, :edit_password,
    :update_password, :edit_personal_data, :update_personal_data,:logout]
  layout proc { |controller|
    ['login', 'session'].include?(controller.action_name) ?
      'clean' : 'application'
  }

  # * GET /users
  # * GET /users.xml
  def index
    @title = t :'users.index_title'
    @users = User.search(params[:search], params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # * GET /users/1
  # * GET /users/1.xml
  def show
    @title = t :'users.show_title'
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # * GET /users/new
  # * GET /users/new.xml
  def new
    @title = t :'users.new_title'
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # * GET /users/1/edit
  def edit
    @title = t :'users.edit_title'
    @user = User.find(params[:id])
  end

  # * POST /users
  # * POST /users.xml
  def create
    @title = t :'users.new_title'
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
  # * PUT /users/1.xml
  def update
    @title = t :'users.edit_title'
    @user = User.find(params[:id])

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
  # * DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
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

  # * GET /users/login
  def login
    @title = t :'users.login_title'
    @user = User.new
  end

  # * POST /users/create_session
  def create_session
    @title = t :'users.login_title'

    @user = User.new user_params
    auth_user = User.find_by_user @user.user
    @user.salt = auth_user.salt if auth_user
    @user.encrypt_password

    if auth_user && auth_user.is_enable? && auth_user.password &&
        auth_user.password == @user.password then
      session[:last_access] = Time.now
      session[:user_id] = auth_user.id
      go_to = {:controller => :projects, :action => :index}
      session[:go_to] = nil
      redirect_to go_to
    else
      redirect_to_login t(:'messages.invalid_user_or_password')
    end
  end

  # * GET /users/edit_password/1
  # * GET /users/edit_password/1.xml
  def edit_password
    @title = t :'users.edit_password_title'
    @auth_user.password = nil
  end

  # * PUT /users/update_password/1
  # * PUT /users/update_password/1.xml
  def update_password
    @user = User.new
    @user.user = @auth_user.user

    auth_user = User.find_by_user @auth_user.user
    @user.salt = auth_user.salt if auth_user

    @user.encrypt_password

    unless auth_user && auth_user.password
      flash[:alert] = t :'users.current_password_error'
      redirect_to edit_password_user_path(auth_user)
    else
      @auth_user.password = params[:user][:password]
      @auth_user.password_confirmation = params[:user][:password_confirmation]

      if @auth_user.valid?
        @auth_user.encrypt_password

        if @auth_user.update_attributes(
            :password => @auth_user.password,
            :password_confirmation => @auth_user.password
          )

          flash[:notice] = t :'users.password_correctly_updated'
          redirect_to login_users_url
        else
          render :action => :edit_password
        end
      else
        render :action => :edit_password
      end

      @auth_user.password, @auth_user.password_confirmation = nil, nil
    end
  rescue ActiveRecord::StaleObjectError
    flash[:alert] = t :'users.password_stale_object_error'
    redirect_to edit_password_user_path(@auth_user)
  end



  # * GET /users/edit_personal_data/1
  # * GET /users/edit_personal_data/1.xml
  def edit_personal_data
    @title = t :'users.edit_personal_data_title'
    @user = User.find(session[:user_id])
  end

  # * PUT /users/update_personal_data/1
  # * PUT /users/update_personal_data/1.xml
  def update_personal_data
    @user = User.find(session[:user_id])

    if @user.valid?
      if @user.update_attributes(user_params)
        flash[:notice] = t :'users.personal_data_correctly_updated'
      end
    end
    render :action => :edit_personal_data

  rescue ActiveRecord::StaleObjectError
    flash[:alert] = t :'users.stale_object_error'
    redirect_to edit_personal_data_user_path(@user)
  end

  # * GET /users/logout
  # * GET /users/logout.xml
  def logout
    restart_session
    redirect_to_login t(:'messages.session_closed_correctly')
  end

  private

  def user_params
    params.require(:user).permit(
      :user, :name, :lastname, :password, :password_confirmation, :email, :enable,
      :private, :admin
    )
  end
end
