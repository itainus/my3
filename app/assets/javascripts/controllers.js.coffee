ctrls = angular.module('Mytree.controllers',[])

ctrls.controller 'MyController',

  ($scope, Services, TreeSketch)->

    $scope.initialize = ()->
      console.log "initialize"
      $scope.tree = {}
      $scope.friends = []
      $scope.set_tree()
      $scope.set_friends()
      $("#new-category-btn").attr("disabled", null);
      $("#new-link-btn").attr("disabled", null);

    $scope.set_tree = ()->
      Services.get_tree().then (tree)->
        console.log(tree)
        $scope.tree = tree
        $scope.myTree = tree
        $scope.sketch_tree()

    $scope.reset_tree_branches = (branches)->
      $scope.tree.branches = branches
      $scope.myTree.branches = branches
      $scope.sketch_tree()

    $scope.reset_tree_leafs = (leafs)->
      $scope.tree.leafs = leafs
      $scope.myTree.leafs = leafs
      $scope.sketch_tree()

    $scope.sketch_tree = ()->
      branches = $scope.tree.branches
      leafs = $scope.tree.leafs
      TreeSketch.drawTree(branches, leafs)

    $scope.save_category = ()->
      angular.element('#newCategory').modal('hide')
      Services.create_category($scope.tree.id, $scope.categoryName, $scope.categoryParentID).then (branches)->
        $scope.categoryName = '';
        $scope.categoryParentID = 1;

        if ($scope.toggleLinkModal == 'newLink')
          $scope.linkCategoryID = resp.id
          angular.element('#newLink').modal('show')
          $scope.toggleLinkModal = false
        else if ($scope.toggleLinkModal == 'editLink')
          $scope.linkCategoryID = resp.id
          angular.element('#editLink').modal('show')
          $scope.toggleLinkModal = false
        $scope.reset_tree_branches(branches)

    $scope.save_link = ()->
      Services.create_link($scope.tree.id, $scope.linkName, $scope.linkUrl, $scope.linkCategoryID).then (leafs)->
        $scope.linkName = '';
        $scope.linkCategoryID = 1;
        $scope.linkUrl = '';
        $scope.reset_tree_leafs(leafs)

    $scope.delete_link = (leafID)->
      Services.delete_link($scope.tree.id, leafID).then (leafs)->
        $scope.reset_tree_leafs(leafs)

    $scope.edit_link = (leafID)->
      Services.update_link($scope.tree.id, leafID, $scope.linkName, $scope.linkUrl, $scope.linkCategoryID).then (leafs)->
        $scope.reset_tree_leafs(leafs)

    $scope.get_category_name = (category_id)->
      for branch in $scope.tree.branches
        if(branch.category.id == category_id)
          return branch.category.name

    $scope.set_link_name = (link)->
      for leaf in $scope.tree.leafs
        if(leaf.link_id == link.id)
          link.name = leaf.name
          return leaf.name

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
      return

    $scope.is_mytree = ()->
      return $scope.tree.id == $scope.myTree.id

    $scope.is_link_already_in_mytree = (linkID)->
      for leaf in $scope.myTree.leafs
        if (leaf.link.id == linkID)
          return true
      return false

    $scope.is_category_already_in_mytree = (categoryID)->
      console.log(categoryID)
      for branch in $scope.myTree.branches
        if (branch.category.id == categoryID)
          return true
      return false

    $scope.add_link_to_mytree = (leaf)->
      Services.add_link($scope.myTree.id, leaf.link.id, leaf.name).then (myTree)->
        $scope.myTree = myTree
        $scope.tree = $scope.tree

    $scope.initialize()

