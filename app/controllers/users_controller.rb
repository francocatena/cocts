class UsersController < ApplicationController
  before_filter :auth, :except => [:login, :create_session]
  layout proc { |controller|
    ['login', 'session'].include?(controller.action_name) ?
      'clean' : 'application'
  }

  # * GET /users
  # * GET /users.xml
  def index
    @title = t :'users.index_title'
    @users = User.order("#{User.table_name}.user ASC").paginate(
      :page => params[:page],
      :per_page => APP_LINES_PER_PAGE
    )

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
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
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

    respond_to do |format|
      if @user.update_attributes(params[:user])
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
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
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
    @user = User.new(params[:user])

    auth_user = User.find_by_user(@user.user)
    @user.salt = auth_user.salt if auth_user

    @user.encrypt_password

    if auth_user && auth_user.is_enable? && auth_user.password &&
        auth_user.password == @user.password then
      session[:last_access] = Time.now
      session[:user_id] = auth_user.id
      go_to = session[:go_to] || { :action => :index }
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
    @user.password = params[:current_password]
       
    auth_user = User.find_by_user(@auth_user.user)
    @user.salt = auth_user.salt if auth_user

    @user.encrypt_password
   
    unless auth_user && auth_user.password && auth_user.password == 
        @user.password && params[:current_password] == params[:current_password_confirmation]
      flash[:notice] = t :'users.current_password_error'
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
    flash[:notice] = t :'users.password_stale_object_error'
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
    attributes = {
      :name  => params[:user][:name],
      :lastname  => params[:user][:lastname],
      :email => params[:user][:email]
    }

    if @user.update_attributes(attributes)
      flash[:notice] = t :'users.personal_data_correctly_updated'
    end

    render :action => :edit_personal_data

  rescue ActiveRecord::StaleObjectError
    flash[:notice] = t :'users.stale_object_error'
    redirect_to edit_personal_data_user_path(@user)
  end

  # * GET /users/logout
  # * GET /users/logout.xml
  def logout
    restart_session
    redirect_to_login t(:'messages.session_closed_correctly')
  end
end