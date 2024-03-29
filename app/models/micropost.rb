class Micropost < ApplicationRecord
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :favorite_users, through: :likes, source: :user
  default_scope -> {order(created_at: :desc)}
  mount_uploader :picture, PictureUploader
  validates :user_id,presence: true
  validates :content, presence:true,length: {maximum: 140}
  validate :picture_size

  def favorite?(user) #ファボ済みか判定
    favorite_users.include?(user) #favorite_usersにuserが含まれているか？
  end

  private
    #アップロードされた画像のサイズをバリデーションする
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
