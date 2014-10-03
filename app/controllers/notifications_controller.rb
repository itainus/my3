class NotificationsController < WebsocketRails::BaseController

  def authorize_channels
    Rails.logger.info "[DEBUG INFO] ############## NotificationsController - authorize_channels ##########"
    # The channel name will be passed inside the message Hash
    channel = WebsocketRails[message[:channel]]
    Rails.logger.info message.as_json
    Rails.logger.info "[DEBUG INFO] channel"
    Rails.logger.info channel
    # Rails.logger.info channel.as_json

    if can? :subscribe, channel
      Rails.logger.info "[DEBUG INFO] yey"
      Rails.logger.info client_id
      Rails.logger.info connection
      controller_store[client_id] = connection
      accept_channel current_user
    else
      Rails.logger.info "[DEBUG INFO] shit"
      deny_channel({:message => 'authorization failed!'})
    end

    Rails.logger.info "[DEBUG INFO] exit"
  end

  def initialize_session
    # perform application setup here
    @rsvp_yes_count = 0
    @rsvp_no_count = 0
  end

  def client_connected
    Rails.logger.info "[DEBUG INFO] ############## NotificationsController - client_connected ##########"
    Rails.logger.info client_id
    controller_store[client_id] = connection
  end

  def client_disconnected
    known_connections = controller_store[client_id]
    known_connections.connections.delete connection
  end

  def tree_update
    Rails.logger.info "[DEBUG INFO] ############## NotificationsController - tree_update ##########"

    # Rails.logger.info message.as_json
    Rails.logger.info client_id


    response = {:action => 'action', :date => {:leaf => true, :name => 'leaf-name' }}

    connection = controller_store[client_id]
    Rails.logger.info connection
    # Rails.logger.info connection.to_json
    # Rails.logger.info WebsocketRails[:tree]

    # WebsocketRails[:tree].trigger 'update', response
    # connection.send_message 'tree.update', response
    # connection.trigger 'update', response
    # send_message :update, response, :namespace => :tree
    # WebsocketRails[:tree].trigger 'update', response
    # Rails.logger.info x


    connection.send_message :update, response, :namespace => :tree

    Rails.logger.info "[DEBUG INFO] done"
  end

  def rsvp
    Rails.logger.info "[DEBUG INFO] ############## NotificationsController - rsvp ##########"
    Rails.logger.info message.as_json
    # rsvp = FollowUpRsvp.new message[:attending], message[:user_id]
    # register_rsvp(rsvp)
    rsvp_update = {
        :yes => @rsvp_yes_count,
        :no => @rsvp_no_count,
        :user_id => 12345
    }
    WebsocketRails[:rsvp].trigger 'new', rsvp_update
  end

  private
end
