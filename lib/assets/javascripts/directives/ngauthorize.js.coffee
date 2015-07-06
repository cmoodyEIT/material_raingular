angular.module('NgAuthorize', [])
  .directive 'ngAuthorize', ($http) ->
    controller: ($scope, $element) ->
      params = $element[0].attributes['ng-authorize'].value.split(',')
      object = {action: params[0], object: params[1]}
      $http url: '/authorize.json', method: "GET", params: object
        .success (data) ->
          $scope.authorized = data.authorized
