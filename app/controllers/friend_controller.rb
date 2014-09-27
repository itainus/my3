class FriendController < ApplicationController

  before_filter :init

  def init
    Rails.logger.info "[DEBUG INFO] ############## FriendController - init ##############"

  end

  def index
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
    end

    render_friends
  end

  def delete_friend
    friend_id = params[:user_id]
    current_user.friends.destroy(friend_id)

    render_friends
  end

  private

  def render_friends
    render json: current_user.friends.as_json(
        only: [:id, :email],
        include: {
            trees:{
                only: [:id, :name],
                include: {
                    branches: {
                        only: [:id],
                        include: {
                            category: {
                                only: [:id, :name, :category_id]
                            },
                            leafs: {
                                only: [:id, :name],
                                include: {
                                    link: {
                                        only: [:id, :name, :url, :category_id]
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
  end

end
