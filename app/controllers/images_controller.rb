class ImagesController < ApplicationController
  def index
    @images = Image.all
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
    else
      render :new, status: :unprocessable_entity
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
