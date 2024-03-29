class User < ApplicationRecord
has_many :microposts, dependent: :destroy
has_many :active_relationships, class_name: "Relationship",
                        foreign_key: "follower_id",
                        dependent: :destroy
has_many :passive_relationships, class_name: "Relationship",
                      foreign_key: "followed_id",
                      dependent: :destroy
has_many :following, through: :active_relationships, source: :followed
has_many :followers, through: :passive_relationships, source: :follower
has_many :likes, dependent: :destroy
attr_accessor :remember_token
before_save {email.downcase!}
validates :name, presence: true , length: {maximum: 50}
VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
validates :email, presence: true, length: {maximum: 255},
              format: {with:VALID_EMAIL_REGEX},
              uniqueness: { case_sensitive: false }
has_secure_password
validates :password, presence: true,length: {minimum: 6},allow_nil: true

# 渡された文字列のハッシュ値を返す
 def User.digest(string)
   cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                 BCrypt::Engine.cost  #ハッシュ化のコストを指定。
   BCrypt::Password.create(string, cost: cost) #指定したコストで文字列でハッシュ化
 end

 #ランダムなトークンを返す
 def User.new_token
   SecureRandom.urlsafe_base64 #ランダムなトークンを生成
 end

 def remember
   self.remember_token = User.new_token #self.remember_tokenにランダムなトークンを代入
   update_attribute(:remember_digest, User.digest(remember_token))#remember_digestカラムにremember_tokenをハッシュ化したものを代入
 end

 #渡されたトークンがダイジェストと一致したらtrueを返す
 def authenticate?(remember_token)
   return false if remember_digest.nil?
   BCrypt::Password.new(remember_digest).is_password?(remember_token)
 end

 def feed
   following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
 end

 #ユーザーをフォローする
 def follow(other_user)
   following << other_user
 end

 #ユーザーをフォロー解除する
 def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
 end

 #現在のユーザーがフォローしてたらtrueを返す
 def following?(other_user)
   following.include?(other_user)
 end

 #ユーザーのログイン情報を破棄する
 def forget
   update_attribute(:remember_digest, nil)
 end
end
