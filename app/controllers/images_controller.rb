class ImagesController < ApplicationController
  before_action :find_image, only: [:show, :edit, :update]
  before_action :find_image_without_raising, only: [:destroy, :share]
  before_action :require_login, except: [:index, :show]
  before_action :set_destroy_permission, only: [:show, :destroy]

  def index
    tag = params[:tag]
    if tag.present?
      @images = Image.tagged_with(tag)
      flash.now[:danger] = "No images are tagged with #{tag}" if @images.empty?
    else
      @images = Image.all
    end
  end

  def show
    @image = Image.find(params[:id])
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(image_params.merge(user: @current_user))
    if @image.save
      redirect_to @image
      flash[:success] = 'You have successfully added an image.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def share
    if @image.present?
      @share_form = ShareForm.new(params[:share_form])
      if @share_form.valid?
        ImageMailer.send_email(@image, @share_form, @current_user).deliver_now
        head :ok
      else
        share_form_html = render_to_string partial: 'images/share_form'
        render json: { form_html: share_form_html }, status: :unprocessable_entity
      end
    else
      flash[:danger] = 'Image you want to share does not exist'
      head :not_found
    end
  end

  def destroy
    if @image.present?
      if @user_can_destroy_image
        flash[:success] = 'Image deleted'
        @image.destroy!
        redirect_to images_path
      else
        flash[:warning] = 'You can not delete this image'
        redirect_to image_path(@image)
      end
    else
      flash[:danger] = 'Image does not exist'
      redirect_to images_path
    end
  end

  def edit
  end

  def update
    new_tags =  params[:image][:tag_list]
    if @image.update_attributes(tag_list: new_tags)
      flash[:success] = 'You successfully change the tags'
      redirect_to image_path(@image)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def image_params
    params.require(:image).permit(:title, :url, :tag_list)
  end

  def require_login
    unless logged_in?
      session[:forwarding_url] = request.url if request.get?
      flash[:warning] = 'Please log in first'
      if request.xhr?
        head :unauthorized
      else
        redirect_to login_path
      end
    end
  end

  def find_image
    @image = Image.find(params[:id])
  end

  def find_image_without_raising
    @image = Image.find_by(id: params[:id])
  end

  def set_destroy_permission
    @user_can_destroy_image = @image.try(:owned_by?, @current_user)
  end
end
