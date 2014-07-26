module Users::Sessions
  # * GET /users/login
  def login
    @user = User.new
  end

  # * POST /users/create_session
  def create_session
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
      redirect_to_login t 'messages.invalid_user_or_password'
    end
  end

  # * GET /users/edit_password/1
  def edit_password
    @auth_user.password = nil
  end

  # * PUT /users/update_password/1
  def update_password
    @user = User.new
    @user.user = @auth_user.user

    auth_user = User.find_by_user @auth_user.user
    @user.salt = auth_user.salt if auth_user

    @user.encrypt_password

    unless auth_user && auth_user.password
      flash[:alert] = t 'users.current_password_error'
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

          flash[:notice] = t 'users.password_correctly_updated'
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
    flash[:alert] = t 'users.password_stale_object_error'
    redirect_to edit_password_user_path(@auth_user)
  end

  # * GET /users/logout
  def logout
    restart_session
    redirect_to_login t 'messages.session_closed_correctly'
  end
end
