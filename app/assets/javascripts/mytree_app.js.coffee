angular.module('mytree',['ngRoute', 'Mytree.controllers', 'Mytree.services', 'Mytree.treeSketch']).config(
  ($routeProvider)->
    $routeProvider
      .when('/', {
        template: JST['views/tree'],
        controller: 'TreeController'
      })
      .when('/tree', {
        template: JST['views/tree'],
        controller: 'TreeController'
      })
      .when('/friends', {
        template: JST['views/friends'],
        controller: 'FriendsController'
      })
      .when('/folders', {
        template: JST['views/folders'],
        controller: 'FoldersController'
      })
      .otherwise({redirectTo: '/'})
)