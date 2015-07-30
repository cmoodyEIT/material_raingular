angular.module 'NgBoolean', ['Factories', 'FactoryName']

  .directive 'ngBoolean', ($injector,factoryName) ->
    restrict: 'A'
    require:  'ngModel'

    link: (scope, element, attributes, ngModelCtrl) ->
      model = attributes.ngModel
      callFunction = model + ' = !' + model + ' ; update("' + model + '")'
      callFunction += ';' + attributes.ngCallback if attributes.ngCallback
      element.attr("call-function", callFunction)
      element.bind 'click', ->
        scope.$eval(element.attr("call-function"))
      scope.update = (modelName)->
        input = modelName.split(',')
        trackby = input.pop() if input.length > 1
        trackby = trackby.split(';') if trackby
        trackby = [] unless trackby
        data = input.splice(0,1)[0].split('.')
        functions = input.join(',').split(')')
        factory = factoryName(data[0])
        object = {id: scope[data[0]]['id']}
        object[data[0]] = {id: scope[data[0]]['id']}
        object[data[0]][data[1]] = scope[data[0]][data[1]]
        list = $injector.get(factory)
        list.update object, (returnData) ->
          for tracked in trackby
            scope[data[0]][tracked] = returnData[tracked]
          ngModelCtrl.$setViewValue(returnData[data[1]]) if ngModelCtrl.$modelValue == object[data[0]][data[1]]
          callFunctions = []
          for callFunction in functions
            callFunctions.push(callFunction + ',' + JSON.stringify(returnData) + ')') if callFunction.length > 0
          scope.$eval( callFunctions.join('') ) if callFunctions.join('').length > 0
