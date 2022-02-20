# frozen_string_literal: true

class SessionController < ApplicationController
  before_action :already_login, only: %i[login create]

  def login; end

  def create
    user = User.find_by username: params[:username]

    if user&.authenticate(params[:password])
      user.update_last_login_at
      sign_in user

      redirect_to root_path
    else
      flash[:warning] = 'Неверный логин или пароль!'
      redirect_to session_login_path
    end
  end

  def logout
    sign_out
    flash[:info] = 'Вы вышли из системы.'
    redirect_to session_login_path
  end
end
