# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]
  before_action :require_login, only: %i[index show update destroy]
  before_action :check_root, only: %i[index]
  before_action :check_current_user, only: %i[show edit]
  before_action :already_login, only: %i[new create]

  # GET /users or /users.json
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  def show; end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @old_user = @user
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    if User.find_by username: @user.username
      flash[:warning] = 'Имя пользователя уже занято!'
      redirect_to new_user_path
    else
      respond_to do |format|
        if @user.save
          sign_in @user
          @user.update_last_login_at
          flash[:success] = 'Пользователь успешно создан!'

          format.html { redirect_to @user }
          format.json { render :show, status: :created, location: @user }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    if User.where('username = ? AND created_at IS NOT ?', user_params[:username], @user.created_at).empty?
      respond_to do |format|
        if @user.update(user_params)
          flash[:success] = 'Пользователь успешно изменён!'
          format.html { redirect_to @user }
          format.json { render :show, status: :ok, location: @user }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    else
      flash[:warning] = "Имя #{user_params[:username]} уже занято!"
      redirect_to edit_user_path
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    flash[:info] = 'Пользователь удалён!' unless @current_user.username == 'root'
    @user.destroy
    respond_to do |format|
      format.html { redirect_to session_login_path }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end
end
