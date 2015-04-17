angular.module 'NgCreate', ['Factories', 'FactoryName']

  .directive 'ngCreate', ($timeout, $compile) ->
    restrict: 'A'
    link: (scope, element, attributes) ->
      element.bind 'click', (event) ->
        scope.create(attributes.ngCreate,attributes.ngContext)
    controller: ($scope, $injector, factoryName) ->
      $scope.create = (modelName,parentName) ->
        factory = factoryName(modelName)
        list = $injector.get(factory)
        object = {}
        object[parentName + '_id'] = $scope[parentName].id if parentName
        list.create object, (returnData) ->
          $scope[factory] = [] unless $scope[factory]
          $scope[factory].push(returnData)
