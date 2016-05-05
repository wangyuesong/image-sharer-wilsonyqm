class Image < ActiveRecord::Base
  VALID_URL_FORMAT = %r!(^$)|(^(http|https)://[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?/.*)?$)!

  validates :title,
            presence: true,
            length:   { minimum: 2 }
  validates :url,
            presence: true,
            format:   {
              with:    VALID_URL_FORMAT,
              message: 'not a valid URL'
            }
  validates :tag_list, presence: true

  acts_as_taggable
end
