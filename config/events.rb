WebsocketRails::EventMap.describe do
  # You can use this file to map incoming events to controller actions.
  # One event can be mapped to any number of controller actions. The
  # actions will be executed in the order they were subscribed.
  #
  # Uncomment and edit the next line to handle the client connected event:
     subscribe :client_connected, :to => NotificationsController, :with_method => :client_connected

    # subscribe :new_message, :to => NotificationsController, :with_method => :msg

     subscribe :client_disconnected, :to => NotificationsController, :with_method => :client_disconnected

  #
  # Here is an example of mapping namespaced events:
  #   namespace :product do
  #     subscribe :new, :to => ProductController, :with_method => :new_product
  #   end
  # The above will handle an event triggered on the client like `product.new`.

  namespace :websocket_rails do
    subscribe :subscribe_private, :to => NotificationsController, :with_method => :authorize_channels
  end

  namespace :rsvp do
    subscribe :new, :to => NotificationsController, :with_method => :rsvp
  end

  namespace :tree do
    subscribe :update, :to => NotificationsController, :with_method => :tree_update
  end

end
