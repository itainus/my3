class UserController < ApplicationController
  def all_users
    Rails.logger.info "[DEBUG INFO] ############## UserController - all_users ##############"

    render json: User.all.as_json(only: [:id, :email])

  end

end
