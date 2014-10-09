class NotificationsController < WebsocketRails::BaseController

  def self.number_of_foos
    @@connections
  end

  def initialize_session
    @@connections = 0
    Rails.logger.info @@connections
  end

  def authorize_channels
    Rails.logger.info "[DEBUG INFO] ############## NotificationsController - authorize_channels - client_id = #{client_id} ##########"
    # The channel name will be passed inside the message Hash
    channel = WebsocketRails[message[:channel]]

    if can? :subscribe, channel
      controller_store[current_user.id] = connection
      Rails.logger.info "[DEBUG INFO] authorize_channel #{channel.as_json}"
      accept_channel current_user
    else
      deny_channel({:message => 'authorization failed!'})
    end
  end

  def client_connected
    Rails.logger.info "[DEBUG INFO] ############## NotificationsController - client_connected - client_id = #{client_id} ##########"
    controller_store[current_user.id] = connection
    current_user
  end

  def client_disconnected
    known_connections = controller_store[current_user.id]
    known_connections.connections.delete connection
  end

  def tree_update
    Rails.logger.info "[DEBUG INFO] ############## NotificationsController - tree_update ##########"

    response = {:action => 'action', :data => {:leaf => true, :name => 'leaf-name' }}

    # connection = controller_store[current_user.id]
    #
    # connection.send_message :update, response, :namespace => :tree

    # Rails.logger.info WebsocketRails.users[current_user.id].send_message :updatee, response
    WebsocketRails.users[current_user.id].send_message :update, response, :namespace => :tree
    # WebsocketRails[:tree].trigger(:updatee, response)
    Rails.logger.info "[DEBUG INFO] ############## NotificationsController - tree_update - done ##########"
  end

  def friend_status
    Rails.logger.info "[DEBUG INFO] ############## NotificationsController - friend_status -  ##########"
    Rails.logger.info message.as_json

    response = {:friend => current_user[:email], :data => {:action => message[:action], 'itay' => 'king'}}
    # response = {}
    if true #controller_store[message[:friend_id]].present?
      Rails.logger.info "[DEBUG INFO] connection of user_id = #{message[:friend_id]} exists"

      connection = controller_store[message[:friend_id]]
      connection.send_message :status, response , :namespace => :friend
    else
      Rails.logger.info "[DEBUG INFO] no connection of user_id = #{message[:friend_id]} exists"
    end

     # WebsocketRails[:friend].trigger(:status, response)

    # connection = controller_store[current_user.id]
    # Rails.logger.info controller_store[current_user.id]
    # Rails.logger.info controller_store[4]
    #
    # connection = controller_store[4]
    #
    # # connection.send_message :status, response, :namespace => :friend
    # connection.send_message :status, {}, :namespace => :friend
    # connection = controller_store[4]
    # connection.send_message :status, {}, :namespace => :friend
  end

  private
end
