class FriendController < ApplicationController

  before_filter :init

  def init
    Rails.logger.info "[DEBUG INFO] ############## FriendController - init ##############"

  end

  def index
    render_friends
  end

  def add_friend
    friend_id = params[:user_id]

    if friend_id == current_user.id
      Rails.logger.info "[DEBUG INFO] ############## FriendController - add_friend - friend #{friend_id} is current user ##############"
      render_friends
      return
    end

    if current_user.friends.exists?(:id => friend_id)
      Rails.logger.info "[DEBUG INFO] ############## FriendController - add_friend - friend #{friend_id} already exists ##############"
    else
      Rails.logger.info "[DEBUG INFO] ############## FriendController - add_friend - adding friend #{friend_id} ##############"
      # current_user.friends.create(:id => friend_id)
      Friendship.create(:user_id => current_user.id, :friend_id => friend_id)

      msg_title = 'Friend Status'
      msg_body = "#{current_user.email} just added you as a friend"
      msg = {
          data: {
              title: msg_title,
              body: msg_body
          }
      }

      notify_friend(friend_id, msg)
    end

    render_friends
  end

  def delete_friend
    friend_id = params[:user_id]
    current_user.friends.destroy(friend_id)

    msg = {
        data: {
            title: "Friend Status",
            body: "You are no longer a friend of #{current_user.email}"
        }
    }
    notify_friend(friend_id, msg)

    render_friends
  end

  def trees
    friend_id = params[:id]
    friend = current_user.friends.find(friend_id)

    if friend.present?
      render json: friend.as_json(
          only: [:id, :email],
          methods: [:trees]
      )
    end
  end

  private

  def notify_friend(friend_id, msg)
    # WebsocketRails.users[friend_id].send_message :status, msg, :namespace => :friend
    # WebsocketRails.users[friend_id].send_message :notifications, msg, :namespace => :user
    NotificationsController.notify_user(friend_id, msg)
  end

  def render_friends
    render json: current_user.friends.as_json(
        only: [:id, :email],
        include: {
            trees: {
                only: [:id, :name]
            }
        }
    )
  end

end
