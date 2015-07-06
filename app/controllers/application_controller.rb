class ApplicationController < ActionController::Base
  include ActionTitle
  include UpdateResource

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  load_and_authorize_resource

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  private

    # Verifica que el login se haya realizado y el usuario esté activo
    def login_check
      load_auth_user

      !@auth_user.nil? && @auth_user.is_enable?
    end

    # Inicializa la variable @auth_user si hay un usuario autenticado en la sesión
    def load_auth_user
      @auth_user ||= User.find(session[:user_id]) if session[:user_id]
    end

    # Controla que el usuario esté autenticado
    def auth
      action = (params[:action] || 'none').to_sym

      unless login_check
        go_to = {
          action: (params[:action] == 'create' ? :new :
            params[:action] == 'update' ? :edit : params[:action]),
          controller: params[:controller],
          id: params[:id]
        }
        session[:go_to] = go_to unless action == :logout
        @auth_user = nil
        redirect_to_login t 'messages.must_be_authenticated'
      else
        response.headers['Cache-Control'] = 'no-cache, no-store'
      end
    end

    # Redirige la navegación a la página de autenticación, enviando el mensaje
    # indicado
    def redirect_to_login(mensaje = nil)
      flash[:notice] = mensaje if mensaje
      redirect_to login_users_url
    end

    def restart_session
      flash_temp = flash.to_hash
      reset_session
      flash.replace flash_temp
    end

    def current_ability
      @current_ability ||= Ability.new(load_auth_user)
    end

end
