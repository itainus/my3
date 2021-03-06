angular.module('Mytree.services', ['ngResource'])
  .factory 'Services', ($http, $q) ->

    get_trees: () ->
      $http.get('/home/trees').then (resp) ->
        return resp.data

    create_category: (tree_id, name, category_parent_id) ->
      $http.post('/tree/' + tree_id + '/category_create', {category_name: name, category_parent_id: category_parent_id}).then (resp) ->
        return resp.data

    add_category: (tree_id, category_id) ->
      $http.post('/tree/' + tree_id + '/category_add', {category_id: category_id}).then (resp) ->
        return resp.data

    add_branch: (tree_id, branch_id) ->
      $http.post('/tree/' + tree_id + '/branch_add', {branch_id: branch_id}).then (resp) ->
        return resp.data

    follow_branch: (branch_id) ->
      $http.post('/user/branch_follow', {branch_id: branch_id}).then (resp) ->
        return resp.data

    delete_category: (tree_id, branch_id) ->
      $http.post('/tree/' + tree_id + '/category_remove', {branch_id: branch_id}).then (resp) ->
        return resp.data

    delete_branch: (tree_id, branch_id) ->
      $http.post('/tree/' + tree_id + '/branch_remove', {branch_id: branch_id}).then (resp) ->
        return resp.data

    create_link: (tree_id, name, url, parent_id) ->
      $http.post('/tree/' + tree_id + '/link_create', {link_name: name, link_url: url, link_category_id: parent_id}).then (resp) ->
        return resp.data

    delete_link: (tree_id, leaf_id) ->
      $http.post('/tree/' + tree_id + '/link_remove', {leaf_id: leaf_id}).then (resp) ->
        return resp.data

    update_link: (tree_id, leaf_id, name, url, parent_id) ->
      $http.post('/tree/' + tree_id + '/link_update', {leaf_id: leaf_id, link_name: name, link_url: url, link_category_id: parent_id}).then (resp) ->
        return resp.data

    add_link: (tree_id, link_id, name) ->
      $http.post('/tree/' + tree_id + '/link_add', {link_id: link_id, link_name: name}).then (resp) ->
        return resp.data

    get_all_other_users: () ->
      $http.get('/user/all_others').then (resp) ->
        return resp.data

    get_friends: () ->
      $http.get('/friends').then (resp) ->
        return resp.data

    add_friend: (user_id) ->
      $http.post('/friend/add', {user_id: user_id}).then (resp) ->
        return resp.data

    delete_friend: (user_id) ->
      $http.post('/friend/delete', {user_id: user_id}).then (resp) ->
        return resp.data

    get_friend_trees: (user_id) ->
      $http.get('/friend/' + user_id + '/trees', {}).then (resp) ->
        return resp.data