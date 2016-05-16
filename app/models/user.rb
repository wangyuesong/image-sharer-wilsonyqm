class User < ActiveRecord::Base
  before_validation { self.email = email.downcase }

  validates :name,  presence: true, length: { maximum: 50 }
  validates :email,
            presence: true,
            length: { maximum: 255 },
            uniqueness: true,
            email_format: {
              message: 'is not a valid email address'
            }
  validates :password, presence: true, length: { minimum: 6 }
  has_secure_password
end
