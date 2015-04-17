angular.module('NgAuthorize', ['Factories'])
  .directive 'ngAuthorize', ->
    controller: ($scope, $element, Authorize) ->
      params = $element[0].attributes['ng-authorize'].value.split(',')
      object = {action: params[0], object: params[1]}
      Authorize.query object, (data) ->
        $scope.authorized = data.authorized
