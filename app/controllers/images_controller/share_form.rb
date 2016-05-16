class ImagesController
  class ShareForm
    include ActiveModel::Model

    attr_accessor :recipient, :subject, :content
    VALID_EMAIL = /\A([\w+\-]\.?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    validates :recipient,
              presence: true,
              email_format: {
                message: 'is not a valid email address'
              }
  end
end
