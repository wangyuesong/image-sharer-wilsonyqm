class UsersController < ApplicationController
  before_action :redirect_if_already_logged_in, only: [:create, :new]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in(@user)
      redirect_to images_path
      flash[:success] = 'Welcome to the Share Image App!'
    else
      render 'new', status: :unprocessable_entity
    end
  end

  private

  def redirect_if_already_logged_in
    if logged_in?
      flash[:danger] = 'Please log out before you sign up'
      redirect_to images_path
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
