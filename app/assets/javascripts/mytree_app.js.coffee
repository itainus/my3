angular.module('mytree',['ngRoute', 'Mytree.controllers', 'Mytree.services', 'Mytree.treeSketch']).config(
  ($routeProvider)->
    $routeProvider
      .when('/', {
        template: JST['views/show_all'],
        controller: 'MyController'
        })
      .otherwise({redirectTo: '/'})
)