ctrls = angular.module('Mytree.controllers',[])

ctrls.controller 'MyController',
  ($scope, Services, TreeSketch)->

    $scope.initialize = ()->

      console.log ("initialize")

      $('#btn').tooltip();
      $('#new-link-btn').tooltip();

      $scope.tree = {}
      $scope.friends = []
      $scope.set_tree()
      $scope.set_friends()
      $("#new-category-btn").attr("disabled", null);
      $("#new-link-btn").attr("disabled", null);
      $("#tree-canvas-stats").hide();

    $scope.set_tree = ()->
      Services.get_trees().then (trees)->
#        console.log(trees)
        tree = trees[0];
        $scope.tree = tree
        $scope.myTree = tree
        $scope.sketch_tree()

    $scope.reset_tree = (tree)->
      $scope.tree = tree
      $scope.myTree = tree
      $scope.sketch_tree()

    $scope.sketch_tree = (filter, trunk)->
      branches = $scope.tree.branches

      tree = {}
      tree.branches = branches
      tree.trunk = if trunk then trunk else $scope.get_branch_by_category_id(1);
      tree.trunk.angle = if trunk then trunk.angle else 90
#      tree.trunk.len = if trunk then trunk.len else 250

      tree.filter = !!filter

      return TreeSketch.drawTree(tree)

    $scope.save_category = ()->
      Services.create_category($scope.tree.id, $scope.categoryName, $scope.categoryParentID).then (response)->
        if response.success
          new_branch = response.branch

          parent_branch = $scope.get_branch_by_category_id($scope.categoryParentID)

          parent_branch.branches.push(new_branch)

          $scope.myTree.branches.push(new_branch)
          $scope.linkCategoryID = new_branch.category.id
          $scope.reset_tree($scope.myTree)

          $scope.categoryName = '';
          $scope.categoryParentID = 1;

          angular.element('#newCategory').modal('hide');
          if ($scope.toggleLinkModal == 'newLink')
            angular.element('#newLink').modal('show')
            $scope.toggleLinkModal = false
          else if ($scope.toggleLinkModal == 'editLink')
            angular.element('#editLink').modal('show')
            $scope.toggleLinkModal = false
        else
          console.error response

    $scope.delete_category = (branchID)->
      Services.delete_category($scope.tree.id, branchID).then (tree)->
        $scope.reset_tree(tree)

    $scope.save_link = ()->
      Services.create_link($scope.tree.id, $scope.linkName, $scope.linkUrl, $scope.linkCategoryID).then (tree)->
        $scope.linkName = '';
        $scope.linkCategoryID = 1;
        $scope.linkUrl = '';
        $scope.reset_tree(tree)

    $scope.delete_link = (leafID)->
      Services.delete_link($scope.tree.id, leafID).then (tree)->
        $scope.reset_tree(tree)

    $scope.edit_link = (leafID)->
      Services.update_link($scope.tree.id, leafID, $scope.linkName, $scope.linkUrl, $scope.linkCategoryID).then (tree)->
        $scope.reset_tree(tree)

    $scope.toggle_new_link_modal = (type)->
      $scope.toggleLinkModal = type
      angular.element('#newLink').modal('hide')
      angular.element('#editLink').modal('hide')
      angular.element('#newCategory').modal('show')
      true

    $scope.set_edit_link_fields = (leaf)->
      if (leaf)
        $scope.linkName = leaf.name
        $scope.linkUrl = leaf.link.url
        $scope.linkCategoryID = leaf.link.category_id
        $scope.leafID = leaf.id
      else
        $scope.linkName = ""
        $scope.linkUrl = ""
        $scope.linkCategoryID = ""

    $scope.set_friends = ()->
      Services.get_friends().then (friends)->
        $scope.friends = friends

    $scope.show_friend_tree = ()->
      if $scope.friend
        $scope.tree = $scope.friend.trees[0]
        $("#new-category-btn").attr("disabled", "disabled");
        $("#new-link-btn").attr("disabled", "disabled");
        $("#tree-canvas-stats").show();
      else
        $scope.tree = $scope.myTree
        $("#new-category-btn").attr("disabled", null);
        $("#new-link-btn").attr("disabled", null);
        $("#tree-canvas-stats").hide();

      $scope.sketch_tree()
      return

    $scope.is_mytree = ()->
      if (!$scope.myTree)
        return true
      return $scope.tree.id == $scope.myTree.id

    $scope.is_link_already_in_mytree = (linkID)->
#      alert(linkID)
      for branch in $scope.myTree.branches
        for leaf in branch.leafs
          if (leaf.link.id == linkID)
            return true
      return false

    $scope.is_category_already_in_mytree = (categoryID)->
      for branch in $scope.myTree.branches
        if (branch.category.id == categoryID)
          return true
      return false

    $scope.add_link_to_mytree = (leaf)->
      Services.add_link($scope.myTree.id, leaf.link.id, leaf.name).then (myTree)->
        $scope.myTree = myTree
        $scope.tree = $scope.tree

    $scope.add_category_to_mytree = (category_id)->
      Services.add_category($scope.myTree.id, category_id).then (myTree)->
        $scope.myTree = myTree
        $scope.tree = $scope.tree

    $scope.get_leaf_by_id = (id) ->
      for branch in $scope.tree.branches
        for leaf in branch.leafs
          if (leaf.id == id)
            return leaf
      return null


    $scope.get_branch_by_category_id = (category_id) ->
      for branch in $scope.tree.branches
        if (branch.category.id == category_id)
          return branch
      return null

    $scope.get_branch_by_id = (id) ->
      for branch in $scope.tree.branches
          if (branch.id == id)
            return branch
      return null

    $scope.tree_stats = (action)->
      statType =  $('#tree-canvas-stats-menu').attr('data-stats-type')
      statID =  $('#tree-canvas-stats-menu').attr('data-stats-id') * 1

      console.log('tree_stats - ' + action + ' - '  + statType + ' - ' + statID)

      if (statType == 'leaf')
        leaf = $scope.get_leaf_by_id(statID)
        if (action == 'add')
          $scope.add_link_to_mytree(leaf)
        if (action == 'follow')
          null
        if (action == 'edit')
          $scope.set_edit_link_fields(leaf)
          angular.element('#editLink').modal('show');
        if (action == 'delete')
          $scope.delete_link(statID)
      if (statType == 'branch')
        branch = $scope.get_branch_by_id(statID)
        if (action == 'add')
          $scope.add_category_to_mytree(branch.category.id)
        if (action == 'follow')
          null
        if (action == 'edit')
          $scope.edit_category(statID)
        if (action == 'delete')
          $scope.delete_category(statID)
        if (action == 'zoom')
          console.log(branch)
          $scope.sketch_tree(false, branch)


    $scope.filter_tree = (el) ->
      console.log($scope.filterBy)
      q = $scope.filterBy

      if (!q)
        $scope.sketch_tree(false)
        return

      leafs_array = []
      branches = []
      leafs = {}

      for b in $scope.tree.branches
        b.keep = false
        for l in b.leafs
          link = l.link
          if (link.url.indexOf(q) != -1)
            leafs_array.push(l)
            leafs[l.id] = l
            branches.push(b)
            l.keep = true
            b.keep = true
          else
            l.keep = false

      len = branches.length
      for i in [0...len]
        b = branches[i]
        for tb in $scope.tree.branches
          if tb.category.id == b.category.category_id
            branches.push(tb)
            len++
            tb.keep = true
            break
      $scope.sketch_tree(true)

      return true

    $scope.create_notification = (template, vars, opts)->
      $("#notifications-container").notify("create", template, vars, opts);

    $scope.init_websocket = ()->
      if document.websocket_dispatcher_init
        return

      if $scope.websocket_dispatcher
        return
      port = if location.port == '' then '' else (':' + location.port)
      websocket_endpoint = document.domain + port + '/websocket'
      $scope.websocket_dispatcher = new WebSocketRails(websocket_endpoint)
      $scope.websocket_dispatcher.on_open = (data) ->
        console.log "Connection has been established:", data
        document.websocket_dispatcher_init = true
      $scope.websocket_dispatcher.on_close = (data) ->
        console.log "Connection has been closed: ", data
        window.websocket_dispatcher = new WebSocketRails(websocket_endpoint)

      $scope.websocket_dispatcher.bind 'tree.update', (response) =>
        console.log 'tree.update bind response:', response
        $("#notifications-container").notify()

        msg = {
          title:response.data.title,
          text:response.data.body
        }
        $scope.create_notification("sticky", msg, { expires:false });
        $scope.initialize()

      $scope.websocket_dispatcher.bind 'friend.status', (response) =>
        console.log 'friend.status bind response:', response
        $("#notifications-container").notify()

        msg = {
          title:response.data.title,
          text:response.data.body
        }
        $scope.create_notification("sticky", msg, { expires:false });

#      private_channel = $scope.websocket_dispatcher.subscribe_private 'tree'
#      private_channel.on_success = (current_user) =>
#        console.log( current_user.email + " Has joined the channel");
#      private_channel.on_failure = (reason) =>
#        console.log "Authorization failed" , reason;
#      private_channel.bind 'update', (response) =>
#        console.log 'tree.update subscribe_private channel response:', response
#        $("#notifications-container").notify()
#        $scope.create_notification("sticky", { title:'tree.update - channel', text:'Example of a default notification.  I will not fade out after 5 seconds'},{ expires:false });

    $scope.initialize()
    $scope.init_websocket()





ctrls.controller 'FriendsController',
  ($scope, Services)->
    $scope.initialize = ()->
      console.log('FriendsController')
      Services.get_all_users().then (users)->
#        console.log(users)
        $scope.users = users
        Services.get_friends().then (friends)->
#          console.log(friends)
          $scope.friends = friends

    $scope.is_friend = (userID)->
      if !$scope.friends
        return false
      for f in $scope.friends
        if f.id == userID
          return true
      return false

    $scope.add_friend = (userID)->
      Services.add_friend(userID).then (friends)->
        console.log(friends)
        $scope.friends = friends

    $scope.remove_friend = (userID)->
      Services.delete_friend(userID).then (friends)->
        $scope.friends = friends

#    $scope.create_notification = (template, vars, opts)->
#      $("#notifications-container").notify("create", template, vars, opts);
#
#    $scope.init_websocket = ()->
#      if $scope.websocket_dispatcher
#        return
#      websocket_endpoint = document.domain + ':3000/websocket'
#      $scope.websocket_dispatcher = new WebSocketRails(websocket_endpoint)
#      $scope.websocket_dispatcher.on_open = (data) ->
#        console.log "Connection has been established:", data
#      $scope.websocket_dispatcher.on_close = (data) ->
#        console.log "Connection has been closed: ", data
#        window.websocket_dispatcher = new WebSocketRails(websocket_endpoint)
#
#      $scope.websocket_dispatcher.bind 'tree.update', (response) =>
#        console.log 'tree.update bind response:', response
#        $("#notifications-container").notify()
#        $scope.create_notification("sticky", {
#            title:response.data.title,
#            text:response.data.body
#          },
#          { expires:false }
#        );
##
##      $scope.websocket_dispatcher.bind 'friend.status', (response) =>
##        console.log 'friend.status bind response:', response
##        $("#notifications-container").notify()
##        text = response.friend + ' just ' + response.action + ' you'
##        $scope.create_notification("sticky", { title:'friend.status - direct', text:text},{ expires:false });
#
#
#      private_channel = $scope.websocket_dispatcher.subscribe_private 'tree'
#      private_channel.on_success = (current_user) =>
#        console.log( current_user.email + " Has joined the channel");
#      private_channel.on_failure = (reason) =>
#        console.log "Authorization failed" , reason;
#      private_channel.bind 'update', (response) =>
#        console.log 'tree.update subscribe_private channel response:', response
#        $("#notifications-container").notify()
#        $scope.create_notification("sticky", { title:'tree.update - channel', text:'Example of a default notification.  I will not fade out after 5 seconds'},{ expires:false });
#
##      private_channel2 = $scope.websocket_dispatcher.subscribe 'friend'
##      private_channel2.on_success = (current_user) =>
##        console.log( current_user.email + " Has joined the channel");
##      private_channel2.on_failure = (reason) =>
##        console.log "Authorization failed" , reason;
##      private_channel2.bind 'status', (response) =>
##        console.log 'friend.status subscribe_private channel response:', response
##        $("#notifications-container").notify()
##        $scope.create_notification("sticky", { title:'friend.status channel', text:'Example of a default notification.  I will not fade out after 5 seconds'},{ expires:false });



#
#    $scope.try_websocket = ()->
#      msg = {
#        friend_id : 4,
#        action : 'remove'
#      }
#      $scope.websocket_dispatcher.trigger 'friend.status', msg
#
#    $scope.try_private_websocket = ()->
#      leaf = {
#        id: 12345
#        name: 'new-leaf-name'
#      }
#      $scope.websocket_dispatcher.trigger 'tree.update',leaf
#

    $scope.initialize()
#    $scope.init_websocket()
