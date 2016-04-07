class ImagesController < ApplicationController
  def index
    @hello_world = 'Hello World'
  end

  def show
    @image = Image.find(params[:id])
  end

  def new

  end

  def create
    @image = Image.create!(image_params)
    redirect_to @image
  end

  private

  def image_params
    params.require(:image).permit(:title, :url)
  end
end
