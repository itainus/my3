class UserController < ApplicationController
  def all_users
    Rails.logger.info "[DEBUG INFO] ############## UserController - all_users ##############"

    # render json: User.all.as_json(only: [:id, :email])
    render json: User.where.not(id: current_user.id).as_json(only: [:id, :email])
  end

  def follow_branch
    branch_id = params[:branch_id]
    Rails.logger.info "[DEBUG INFO] ############## UserController - follow_branch - branch_id = #{branch_id} ##############"

    if Branch.find(branch_id).present?
      if current_user.followings.where(:branch_id => branch_id).blank?
        current_user.followings.create(:branch_id => branch_id)
      else
        Rails.logger.info "[DEBUG INFO] user #{current_user.email} already follows branch #{branch_id}"
      end
    else
      Rails.logger.info "[DEBUG INFO] branch #{branch_id} dose not exits"
    end
    render json: current_user.followings.as_json
  end

end
