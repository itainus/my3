class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :trees, :dependent => :destroy

  has_many :friendships, :dependent => :destroy
  has_many :friends, :through => :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id" #,:dependent => :destroy
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user

  has_many :followings
  # has_many :followers, through: :followings
end
