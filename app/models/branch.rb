class Branch < ActiveRecord::Base
  belongs_to :tree
  belongs_to :category

  has_many :leafs, :dependent => :destroy
  has_many :links, :through => :leafs

  belongs_to :branch
  has_many :branches, :dependent => :destroy

  has_many :followings
  has_many :followers, :through => :followings, :source => :user

  # attr_accessor :ranking

  # def after_initialize
  # def after_find
  #   self.ranking = 1717
  # end

  # def rank
  #   self.ranking
  # end

  def as_json (options = nil)
    # self.ranking = 171
    super(
      only: [:id],
      include: {
        category: {
            only: [:id, :name, :category_id]
        },
        branches: {
            only: [:id, :name]
        }
      },
      methods: [:leafs]
    )
  end

  def notify_followers msg
    Rails.logger.info "[DEBUG INFO] ############## Branch - notify_followers - branch_id #{self.id} - msg = #{msg.as_json} ##############"
    self.followers.each do |follower|
      Rails.logger.info "[DEBUG INFO] notify #{follower.email} - id #{follower.email}"
      # WebsocketRails.users[follower.id].send_message :branch, msg, :namespace => :follow
      # WebsocketRails.users[follower.id].send_message :status, msg, :namespace => :friend
      NotificationsController.notify_user(follower.id, msg)
    end
  end
end
