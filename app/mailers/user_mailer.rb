class UserMailer < ActionMailer::Base
  default from: 'soporte@cocts.com.ar'
  
  def new_user_notification(user, password)
    @user = user
    @pass = password
    mail(
      to: "#{@user.name} #{@user.lastname} <#{@user.email}>",
      subject: 'Alta de usuario en COCTS'        
    )
  end
  
end
