# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionHelper

  around_action :switch_locale

  def require_login
    unless signed_in?
      flash[:error] = 'Требуется авторизоваться!'
      redirect_to session_login_path
    end
  end

  def check_root
    unless current_user.username == 'root'
      flash[:error] = 'Нет прав доступа!'
      redirect_to @current_user
    end
  end

  def check_current_user
    if current_user.nil?
      flash[:error] = 'Нет прав доступа!'
      redirect_to session_login_path
    else
      unless current_user == @user || current_user.username == 'root'
        flash[:error] = 'Нет прав доступа!'
        redirect_to @current_user
      end
    end
  end

  def check_current_users_post
    if current_user.nil?
      flash[:error] = 'Нет прав доступа!'
      redirect_to session_login_path
    else
      unless current_user.id == @post.user_id || current_user.username == 'root'
        flash[:error] = 'Нет прав доступа!'
        redirect_to @current_user
      end
    end
  end

  def already_login
    unless current_user.nil?
      flash[:error] = 'Вы уже в системе!'
      redirect_to @current_user
    end
  end

  private

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def locale_from_url
    locale = params[:locale]
    return locale if I18n.available_locales.map(&:to_s).include?(locale)
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
