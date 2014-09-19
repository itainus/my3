angular.module('mytree',['ngRoute', 'Mytree.controllers', 'Mytree.services', 'Mytree.treeSketch']).config(
  ($routeProvider)->
    $routeProvider
      .when('/', {
        template: JST['views/tree'],
        controller: 'MyController'
      })
      .otherwise({redirectTo: '/'})
)