ctrls = angular.module('Mytree.controllers',[])

ctrls.controller 'MyController',
  ($scope, Services, TreeSketch)->

    $scope.initialize = ()->

#      $location.path('edit')
#      $('#tip-canvas').tooltip()
#      $('#btn').tooltip()
      $('#btn').tooltip();
      $('#new-link-btn').tooltip();


      console.log ("initialize")
      $scope.tree = {}
      $scope.friends = []
      $scope.set_tree()
      $scope.set_friends()
      $("#new-category-btn").attr("disabled", null);
      $("#new-link-btn").attr("disabled", null);
      $("#tree-canvas-stats").hide();

    $scope.set_tree = ()->
      Services.get_trees().then (trees)->
        console.log(trees)
        tree = trees[0];
        $scope.tree = tree
        $scope.myTree = tree
        $scope.sketch_tree()

    $scope.reset_tree = (tree)->
      $scope.tree = tree
      $scope.myTree = tree
      $scope.sketch_tree()

    $scope.sketch_tree = (filter)->
      branches = $scope.tree.branches
      leafs = []
      for b in branches
        for l in b.leafs
          leafs.push(l)
      TreeSketch.drawTree(branches, leafs, filter)

    $scope.save_category = ()->
      Services.create_category($scope.tree.id, $scope.categoryName, $scope.categoryParentID).then (tree)->
#        console.log('create_category cb')
        angular.element('#newCategory').modal('hide');
        $scope.categoryName = '';
        $scope.categoryParentID = 1;
        newCategory = tree.branches[tree.branches.length-1].category
        if ($scope.toggleLinkModal == 'newLink')
          $scope.linkCategoryID = newCategory.id
          angular.element('#newLink').modal('show')
          $scope.toggleLinkModal = false
        else if ($scope.toggleLinkModal == 'editLink')
          $scope.linkCategoryID = newCategory.id
          angular.element('#editLink').modal('show')
          $scope.toggleLinkModal = false
        $scope.reset_tree(tree)

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

#    $scope.get_category_name = (category_id)->
#      for branch in $scope.tree.branches
#        if(branch.category.id == category_id)
#          return branch.category.name

#    $scope.set_link_name = (link)->
#      for leaf in $scope.tree.leafs
#        if(leaf.link_id == link.id)
#          link.name = leaf.name
#          return leaf.name

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
      $scope.tree = $scope.friend.trees[0]
      $scope.sketch_tree()
      $("#new-category-btn").attr("disabled", "disabled");
      $("#new-link-btn").attr("disabled", "disabled");
      $("#tree-canvas-stats").show();
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
          angular.element('#newLink').modal('show');
        if (action == 'delete')
          $scope.delete_link(statID)
      if (statType == 'branch')
        if (action == 'add')
          $scope.add_category_to_mytree(statID)
        if (action == 'follow')
          null
        if (action == 'edit')
          $scope.edit_category(statID)
        if (action == 'delete')
          $scope.delete_category(statID)




    $scope.setActive = (el) ->
      console.log('setActive', el)

    $scope.setViewComponent = (component) ->
      return false
      $scope.component = component
      console.log('setViewComponent')
      return false

    $scope.filter_tree = (el) ->
      console.log(el)
      console.log(this)
      console.log($scope.filterBy)
      q = $scope.filterBy

      if (!q)
        $scope.sketch_tree(false)
        return

      branches_array = []
      leafs_array = []
      branches = {}
      leafs = {}

      for b in $scope.tree.branches
        b.keep = false
        for l in b.leafs
          link = l.link
          if (link.url.indexOf(q) != -1)
            leafs_array.push(l)
            leafs[l.id] = l
            branches[b.id] = b
            l.keep = true
            b.keep = true
          else
            l.keep = false

      for k,b of branches
        for tb in $scope.tree.branches
          if tb.category.id == b.category.category_id
            branches[tb.id] = tb
            tb.keep = true


      $scope.sketch_tree(true)

      return true


#    $scope.component = 'tree'
    $scope.initialize()



ctrls.controller 'FriendsController',
  ($scope, Services)->
    $scope.initialize = ()->
      console.log('FriendsController')
      Services.get_all_users().then (users)->
        console.log(users)
        $scope.users = users
        Services.get_friends().then (friends)->
          console.log(friends)
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


    $scope.initialize()
