class SessionsController < ApplicationController
  before_action :redirect_if_already_logged_in, only: [:create, :new]

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email])
    if user.present? && user.authenticate(params[:session][:password])
      log_in user
      remember(user) if params[:session][:remember_me] == '1'
      flash[:success] = 'Welcome to the Share Image App!'
      redirect_back_or(images_path)
    else
      flash[:danger] = 'Invalid password/username'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    if logged_in?
      log_out
      flash[:success] = 'You successfully logged out'
    else
      flash[:info] = 'You are already logged out'
    end
    redirect_back_or(images_path)
  end

  private

  def log_out
    cookies.delete(:user_id)
    session.delete(:user_id)
    @current_user = nil
  end

  def remember(user)
    cookies.permanent.signed[:user_id] = user.id
  end

  def redirect_if_already_logged_in
    if logged_in?
      flash[:info] = 'You are already logged in'
      redirect_to images_path
    end
  end

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end
end
