angular.module 'NgDestroy', ['Factories']

  .directive 'ngDestroy', ($injector, factoryName) ->
    restrict: 'A'
    require: '?ngCallback'
    link: (scope, element, attributes, ngCallbackCtrl) ->
      console.warn "ngDestroy is deprecated. Please consider using mrDestroy in its stead."
      element.bind 'click', (event) ->
        form = element[0]
        until form.nodeName == 'FORM' || !form
          form = form.parentNode
          break if !form
        form ||= element[0]
        return if attributes.disabled || form.disabled
        destroy(attributes.ngDestroy,attributes.ngContext)
      destroy = (modelName,listName) ->
        factory = factoryName(modelName)
        if listName
          list = scope
          for childScope in listName.split('.')
            list = list[childScope]
        else
          list = scope[factory]
        resource = list #Save resource for later if server returns success
        list = $injector.get(factory)
        object = {id: scope[modelName].id}
        list.delete(object).$promise #remove from server
        .then (returnData)->
          resource.drop(scope[modelName]) #remove from view
          ngCallbackCtrl.evaluate(returnData) if !!ngCallbackCtrl
