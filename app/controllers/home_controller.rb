class HomeController < ApplicationController

  before_filter :init

  def init
    Rails.logger.info "[DEBUG INFO] ############## HomeController - init ##############"

    if current_user.trees.blank?
      tree_name = "#{current_user.email} Tree"
      current_user.trees.create_new(current_user.id, tree_name)
    end

    @tree = current_user.trees.first
  end

  def index
  end

  def tree
    Rails.logger.info "[DEBUG INFO] ############## HomeController - tree ##############"

    render json: @tree.as_json(
      only: [:id, :name],
      include: {
        branches: {
          only: [:id],
          include: {
            category: {
              only: [:id, :name, :category_id]
            }
          }
        },
        leafs: {
          only: [:id, :name],
          include: {
            link: {
              only: [:id, :name, :url, :category_id]
            }
          }
        }
    })
  end

  def friends
    Rails.logger.info "[DEBUG INFO] ############## HomeController - friends ##############"

    Rails.logger.info current_user.friends.first.trees.all.as_json
    # @friendship = current_user.friendships.build(:friend_id => 3)
    # if @friendship.save
    #   flash[:notice] = "Added friend."
    # else
    #   flash[:error] = "Unable to add friend."
    # end

    # render json: current_user.friends.as_json(include: [:trees])
    # render json: current_user.friends.as_json(
    #     only: [:id, :email],
    #     include: {
    #       trees: {
    #         only: [:id, :name],
    #         include: {
    #           branches: {only: [:id], include: {category: {only: [:id, :name, :category_id]}}},
    #           leafs: {only: [:id, :name], link: {only: [:id, :name, :url, :category_id]}}
    #         }
    #       }
    #   })

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
                }
              }
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
      })
  end

end