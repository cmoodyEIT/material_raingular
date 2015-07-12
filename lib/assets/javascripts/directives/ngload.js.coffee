angular.module 'NgLoad', ['Factories', 'FactoryName']

  .directive 'ngLoad', ->
    restrict: 'E'
    require:  'ngModel'

    controller: ($scope, $element, $injector, $routeParams, factoryName) ->
      factory = factoryName($element[0].attributes['ng-model'].value)
      object  = {id: $routeParams.id}
      list    = $injector.get(factory)
      if $routeParams.id
        list.show object, (returnData) ->
          $scope[$element[0].attributes['ng-model'].value] = returnData
      else
        list.create (returnData) ->
          $scope[$element[0].attributes['ng-model'].value] = returnData
