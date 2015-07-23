angular.module 'NgCreate', ['Factories', 'FactoryName']

  .directive 'ngCreate', ($timeout, $compile) ->
    restrict: 'A'
    link: (scope, element, attributes) ->
      element.bind 'click', (event) ->
        [parentName, listName] = attributes.ngContext.split('.') if attributes.ngContext
        attr = eval('(' + attributes.ngAttributes + ')') || {}
        scope.create(attributes.ngCreate,parentName,listName,attr)
    controller: ($scope, $injector, factoryName) ->
      $scope.create = (modelName,parentName,listName,attributes) ->
        factory = factoryName(modelName)
        list = $injector.get(factory)
        object = {}
        object[modelName] = attributes
        if parentName
          object[parentName]         = $scope[parentName]    unless parentName.indexOf('_id') < 0
          object[parentName + '_id'] = $scope[parentName].id     if parentName.indexOf('_id') < 0
        list.create object, (returnData) ->
          if listName
            scope = if $scope[parentName] then $scope else $scope.$parent
            scope[parentName] = {} unless scope[parentName]
            scope[parentName][listName] = [] unless scope[parentName][listName]
            scope[parentName][listName].push(returnData)
          else
            $scope[factory] = [] unless $scope[factory]
            $scope[factory].push(returnData)
