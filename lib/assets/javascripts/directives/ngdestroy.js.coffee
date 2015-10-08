angular.module 'NgDestroy', ['Factories']

  .directive 'ngDestroy', ($injector, factoryName) ->
    restrict: 'A'
    require: '?ngCallback'
    link: (scope, element, attributes, ngCallbackCtrl) ->
      element.bind 'click', (event) ->
        destroy(attributes.ngDestroy,attributes.ngContext)
      destroy = (modelName,listName) ->
        factory = factoryName(modelName)
        if listName
          list = scope
          for childScope in listName.split('.')
            list = list[childScope]
        else
          list = scope[factory]
        list.drop(scope[modelName])
        list = $injector.get(factory)
        object = {id: scope[modelName].id}
        list.delete object, (returnData)->
          ngCallbackCtrl.evaluate(returnData) if !!ngCallbackCtrl
