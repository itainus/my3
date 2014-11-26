class Following < ActiveRecord::Base

  # belongs_to :branch
  # belongs_to :follower, class_name: 'Branch'
  belongs_to :user
  belongs_to :follower, class_name: 'User'
end
