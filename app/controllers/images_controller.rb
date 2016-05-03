class ImagesController < ApplicationController
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
    @image = Image.new(image_params)
    if @image.save
      redirect_to @image
      flash[:success] = 'You have successfully added an image.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new_share
    @image = Image.find(params[:id])
    @share_form = ShareForm.new
  end

# TODO: rename to just `share` once we refactor to a modal

  def create_share
    @image = Image.find_by(id: params[:id])
    if @image.present?
      @share_form = ShareForm.new(params[:share_form])
      if @share_form.valid?
        ImageMailer.send_email(@image, @share_form).deliver_now
        flash[:success] = 'Shared it!'
        redirect_to images_path
      else
        render :new_share, status: :unprocessable_entity
      end
    else
      flash[:danger] = 'Image you want to share does not exist'
      redirect_to images_path
    end
  end

  def destroy
    @image = Image.find_by(id: params[:id])
    if @image.present?
      flash[:success] = 'Image deleted'
      @image.destroy!
    else
      flash[:danger] = 'Image does not exist'
    end
    redirect_to images_path
  end

  private

  def image_params
    params.require(:image).permit(:title, :url, :tag_list)
  end
end
