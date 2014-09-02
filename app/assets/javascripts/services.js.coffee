angular.module('Mytree.services', ['ngResource'])
  .factory 'Services', ($http, $q) ->

    get_tree: () ->
      $http.get('/home/tree').then (resp) ->
        return resp.data

    create_category: (tree_id, name, parent_id) ->
      $http.post('/tree/' + tree_id + '/category_create', {category_name: name, category_parent_id: parent_id}).then (resp) ->
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

    get_friends: () ->
      $http.get('/home/friends').then (resp) ->
        return resp.data


    add_category: (categoryID) ->
      $http.post('/category/' + categoryID).then (resp) ->
        return resp.data