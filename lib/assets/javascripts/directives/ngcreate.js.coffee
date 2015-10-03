angular.module 'NgCreate', ['Factories', 'FactoryName']

  .directive 'ngCreate', ($injector, factoryName) ->
    restrict: 'A'
    require: '?ngCallback'
    link: (scope, element, attributes, ngCallbackCtrl) ->
      element.bind 'click', (event) ->
        [parentName, listName] = attributes.ngContext.split('.') if attributes.ngContext
        attr = scope.$eval('(' + attributes.ngAttributes + ')') || {}
        create(attributes.ngCreate,parentName,listName,attr)
      create = (modelName,parentName,listName,attributes) ->
        addTo = element[0].attributes['ng-add-to'].value if element[0].attributes['ng-add-to']
        factory = factoryName(modelName)
        list = $injector.get(factory)
        object = {}
        object[modelName] = attributes
        if parentName
          object[modelName][parentName]         = scope[parentName]    unless parentName.indexOf('_id') < 0
          object[modelName][parentName + '_id'] = scope[parentName].id     if parentName.indexOf('_id') < 0
          object[parentName]                    = scope[parentName]    unless parentName.indexOf('_id') < 0
          object[parentName + '_id']            = scope[parentName].id     if parentName.indexOf('_id') < 0
        list.create object, (returnData) ->
          if addTo
            scope[addTo].push(returnData)
          if listName
            scope = if scope[parentName] then scope else scope.$parent
            scope[parentName] = {} unless scope[parentName]
            scope[parentName][listName] = [] unless scope[parentName][listName]
            scope[parentName][listName].push(returnData)
          else
            scope[factory] = [] unless scope[factory]
            scope[factory].push(returnData)
          ngCallbackCtrl.evaluate(returnData) if !!ngCallbackCtrl
