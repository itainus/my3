class FriendController < ApplicationController

  before_filter :init

  def init
    Rails.logger.info "[DEBUG INFO] ############## FriendController - init ##############"

  end

  def index
  end


end
