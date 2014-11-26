ctrls = angular.module('Mytree.controllers',[])

window.websocket_dispatcher = null

create_notification = (template, vars, opts)->
  $("#notifications-container").notify("create", template, vars, opts);

init_websocket = ()->
  if window.websocket_dispatcher
    console.log 'window.websocket_dispatcher already defined'
    return
  port = if location.port == '' then '' else (':' + location.port)
  websocket_endpoint = document.domain + port + '/websocket'
  window.websocket_dispatcher = new WebSocketRails(websocket_endpoint)
  window.websocket_dispatcher.on_open = (data) ->
    console.log "Connection has been established:", data
  window.websocket_dispatcher.on_close = (data) ->
    console.log "Connection has been closed: ", data
    window.websocket_dispatcher = new WebSocketRails(websocket_endpoint)

  window.websocket_dispatcher.bind 'user.notifications', (notification) =>
    console.log 'user.notifications bind response:', notification
    $("#notifications-container").notify()
    msg = {
      title:notification.data.title,
      text:notification.data.body
    }
    create_notification("sticky", msg, { expires:false });

init_websocket()

ctrls.controller 'TreeController',
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

    $scope.sketch_tree = (filter_by, trunk)->
      $scope.filterBy = if filter_by then filter_by else null
      $scope.zoomBranch = if trunk then trunk else null
      tree = {}
      tree.branches = $scope.tree.branches
      tree.trunk = if trunk then trunk else $scope.get_branch_by_category_id(1);
#      tree.trunk.angle = if trunk then trunk.angle else 90
      return TreeSketch.draw_tree(tree, filter_by, $scope)

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
      Services.create_link($scope.tree.id, $scope.linkName, $scope.linkUrl, $scope.linkCategoryID).then (response)->
        if response.success
          new_leaf = response.leaf

          parent_branch = $scope.get_branch_by_category_id($scope.linkCategoryID)

          parent_branch.leafs.push(new_leaf)

          $scope.linkName = '';
          $scope.linkCategoryID = 1;
          $scope.linkUrl = '';

          $scope.reset_tree($scope.myTree)
#        $scope.reset_tree(tree)

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

    $scope.set_edit_category_fields = (branch)->
      if (branch)
        $scope.categoryName = branch.category.name
        $scope.categoryParentID = branch.category.category_id
        $scope.branchID = branch.id
      else
        $scope.categoryName = ""
        $scope.categoryParentID = ""
        $scope.branchID = ""

    $scope.set_friends = ()->
      Services.get_friends().then (friends)->
        $scope.friends = friends

    $scope.show_friend_tree = ()->
      if $scope.friend
        Services.get_friend_trees($scope.friend.id).then (friend)->
          if friend.id == $scope.friend.id
            $scope.friend.trees = friend.trees
            $scope.tree = $scope.friend.trees[0]
            $("#new-category-btn").attr("disabled", "disabled");
            $("#new-link-btn").attr("disabled", "disabled");
            $("#tree-canvas-stats").show();
            $scope.sketch_tree()
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

    $scope.add_branch_to_mytree = (branch_id)->
      Services.add_branch($scope.myTree.id, branch_id).then (myTree)->
        $scope.reset_tree(myTree)

    $scope.follow_branch= (branch_id)->
      Services.follow_branch(branch_id).then (response)->
        console.log 'follow_branch', response

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
          $scope.add_branch_to_mytree(branch.id)
        if (action == 'follow')
          $scope.follow_branch(branch.id)
        if (action == 'edit')
          $scope.add_branch_to_mytree(branch)
          angular.element('#editCategory').modal('show');
        if (action == 'delete')
          $scope.delete_category(statID)
        if (action == 'zoom')
#          $scope.sketch_tree(branch)
          $scope.zoomBranch = branch
          $("#tree-canvas").addClass("zoom-in");
          $scope.sketch_tree($scope.filterBy, branch)

    $scope.filter_tree = (el) ->

      return $scope.sketch_tree($scope.filterBy, $scope.zoomBranch)

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
      return $scope.sketch_tree(true)

    $scope.initialize()


ctrls.controller 'FriendsController',
  ($scope, Services)->
    $scope.initialize = ()->
      console.log('FriendsController')
      console.log(ctrls)

      Services.get_all_other_users().then (users)->
#        console.log(users)
        $scope.users = users
        Services.get_friends().then (friends)->
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

ctrls.controller 'FoldersController',
  ($scope, Services)->
    $scope.initialize = ()->
      $scope.tree = null
      $scope.myTree = null
      $scope.currentBranch = null
      $scope.currentLeaf = null
      $scope.path = []
      $scope.friends = []

      Services.get_trees().then (trees)->
        $scope.myTree = trees[0]
        $scope.load_tree($scope.myTree)

      Services.get_friends().then (friends)->
        $scope.friends = friends
        console.log friends

    $scope.load_tree = (tree)->
      $scope.path = []
      $scope.currentBranch = null
      $scope.tree = tree
      for branch in $scope.tree.branches
        if branch.category.category_id == null
          $scope.path.push(branch)
          $scope.currentBranch = branch
          return

    $scope.set_path_current_branch = (branch_id)->
      console.log(branch_id)
      tmpPath = []
      for branch in $scope.path
        if branch.id == branch_id
          break
        tmpPath.push(branch)
      branch = $scope.get_branch_by_id(branch_id)
      $scope.currentBranch = branch
      $scope.path = tmpPath
      $scope.path.push(branch)

    $scope.get_branch_by_id = (branch_id)->
      for branch in $scope.tree.branches
        if branch.id == branch_id
          return branch
      return null

    $scope.show_new_branch_input = ()->
      $('.folder-input-container').removeClass('active')
      $('#new-branch-container').addClass('active')
      $('#new-branch-name').focus();
      return false

    $scope.show_new_leaf_input = ()->
      $scope.currentLeaf = null
      $('.folder-input-container').removeClass('active')
      $('#new-leaf-container').addClass('active')
      $('#new-leaf-name').focus();
      return false

    $scope.show_edit_leaf_input = (leaf)->
      $scope.currentLeaf = leaf
      $('.folder-input-container').removeClass('active')
      $('#edit-leaf-container').addClass('active')
      $('#edit-leaf-name').focus();
      return false

    $scope.create_new_branch = ()->
      categoryName = $('#new-branch-name').val()
      Services.create_category($scope.myTree.id, categoryName, $scope.currentBranch.category.id).then (response)->
        if response.success
          new_branch = response.branch
          $scope.myTree.branches.push(new_branch)
          $scope.tree = $scope.myTree
          $scope.currentBranch.branches.push(new_branch)
          $('#new-branch-name').val('')
        $('.folder-input-container').removeClass('active')
      return false

    $scope.create_new_leaf = ()->
      linkName = $('#new-leaf-name').val()
      linkUrl = $('#new-leaf-url').val()
      Services.create_link($scope.myTree.id, linkName, linkUrl, $scope.currentBranch.category.id).then (response)->
        if response.success
          new_leaf = response.leaf
          $scope.tree = $scope.myTree
          $scope.currentBranch.leafs.push(new_leaf)
          $('#new-leaf-name').val('')
          $('#new-leaf-url').val('')
        $('.folder-input-container').removeClass('active')
      return false

    $scope.delete_branch = (branch_id)->
      for parentBranch in $scope.myTree.branches  #$scope.path
        for i, branch of parentBranch.branches
          if branch.id == branch_id
            Services.delete_branch($scope.myTree.id, branch_id).then (response)->
              console.log response
              $('.folder-input-container').removeClass('active')
              if response.success
                parentBranch.branches.splice(i*1, 1);
                $scope.set_path_current_branch(parentBranch.id)
            return true
      return false

    $scope.add_friend_branch = (branch_id)->
      Services.add_branch($scope.myTree.id, branch_id).then (response)->
        console.log response
        if response.success
          branches = response.branches
          parentBranch = response.parentBranch
          $scope.load_my_tree()
          $scope.set_path_current_branch(parentBranch.id)
        $('.folder-input-container').removeClass('active')
      return false

    $scope.follow_friend_branch = (branch_id)->
      linkName = $('#new-leaf-name').val()

    $scope.unfollow_friend_branch = (branch_id)->
      linkName = $('#new-leaf-name').val()

    $scope.edit_leaf = ()->
      leafID = $scope.currentLeaf.id
      linkName = $('#new-leaf-name').val()
      linkUrl = $('#new-leaf-url').val()
      console.log leafID, linkName, linkUrl, $scope.currentBranch.category.id
      Services.update_link($scope.myTree.id, leafID, linkName, linkUrl, $scope.currentBranch.category.id).then (response)->
        if response.success
          for leaf in $scope.currentBranch.leafs
            if leaf.id == response.leaf.id
              leaf.link = response.leaf.link
              break
        $('.folder-input-container').removeClass('active')
      return false

    $scope.delete_leaf = (leaf)->
      Services.delete_link($scope.myTree.id, leaf.id).then (response)->
        if response.success
          for i, leaf of $scope.currentBranch.leafs
            if leaf.id == response.leaf.id
              $scope.currentBranch.leafs.splice(i*1, 1);
              break
        $('.folder-input-container').removeClass('active')
      return false

    $scope.load_my_tree = ()->
      $('#folder-actions-buttons').show()
      $('#folder-actions').show()
      $scope.load_tree($scope.myTree)

    $scope.load_friend_tree = (friend_id)->
      $('.folder-input-container').removeClass('active')
      Services.get_friend_trees(friend_id).then (friend)->
        $scope.load_tree(friend.trees[0])

    $scope.set_selected_button_tree = (e)->
      $('#roots-container button').removeClass('selected-tree')
      e.currentTarget.className += ' selected-tree'

    $scope.is_my_tree = ()->
      if ($scope.myTree && $scope.tree)
        return  $scope.myTree.id == $scope.tree.id
      return true

    $scope.is_branch_followed = ()->
      return false

    $scope.initialize()