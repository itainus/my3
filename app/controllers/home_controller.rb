class HomeController < ApplicationController

  before_filter :init

  def init
    Rails.logger.info "[DEBUG INFO] ############## HomeController - init ##############"

    if current_user.trees.blank?
      tree_name = "#{current_user.email} Tree"
      current_user.trees.create_new(current_user.id, tree_name)
    end

    @trees = current_user.trees
  end

  def index
  end

  def trees
    Rails.logger.info "[DEBUG INFO] ############## HomeController - trees ##############"

    render json: @trees.as_json
  end

  def friends
    Rails.logger.info "[DEBUG INFO] ############## HomeController - friends ##############"

    render json: current_user.friends.as_json(
      only: [:id, :email],
      methods: [:trees]
    )
  end

  def generate_random_tree
    Rails.logger.info "[DEBUG INFO] ############## HomeController - test ##############"

    # t = Tree.create_new(1, "Test Tree - #{rand(1..10000)}")
    user_id = 1

    User.find(user_id).trees.destroy_all

    t = Tree.generate_random(user_id, 1,4,1,4,0,3)

    render json: t.as_json
  end

end
