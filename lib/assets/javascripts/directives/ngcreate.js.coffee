angular.module 'NgCreate', ['Factories', 'FactoryName']

  .directive 'ngCreate', ($timeout, $compile) ->
    restrict: 'A'
    link: (scope, element, attributes) ->
      element.bind 'click', (event) ->
        [parentName, listName] = attributes.ngContext.split('.') if attributes.ngContext
        scope.create(attributes.ngCreate,parentName,listName)
    controller: ($scope, $injector, factoryName) ->
      $scope.create = (modelName,parentName,listName) ->
        factory = factoryName(modelName)
        list = $injector.get(factory)
        object = {}
        object[parentName + '_id'] = $scope[parentName].id if parentName
        list.create object, (returnData) ->
          if listName
            scope = if $scope[parentName] then $scope else $scope.$parent
            scope[parentName] = {} unless scope[parentName]
            scope[parentName][listName] = [] unless scope[parentName][listName]
            scope[parentName][listName].push(returnData)
          else
            $scope[factory] = [] unless $scope[factory]
            $scope[factory].push(returnData)
