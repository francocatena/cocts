module Users::PersonalData
  # * GET /users/edit_personal_data/1
  def edit_personal_data
    @user = User.find(session[:user_id])
  end

  # * PUT /users/update_personal_data/1
  def update_personal_data
    @user = User.find(session[:user_id])

    if @user.valid?
      if @user.update_attributes(user_params)
        flash[:notice] = t 'users.personal_data_correctly_updated'
      end
    end

    render action: :edit_personal_data

  rescue ActiveRecord::StaleObjectError
    flash[:alert] = t 'users.stale_object_error'
    redirect_to edit_personal_data_user_path(@user)
  end
end
