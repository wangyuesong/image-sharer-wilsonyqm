class TagsController < ApplicationController
  def index
    @tags = Image.tag_counts.order(taggings_count: :desc, name: :asc)
  end
end
