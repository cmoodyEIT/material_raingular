angular.module 'NgUpdate', ['Factories', 'FactoryName']

  .directive 'ngUpdate', ($timeout, $compile) ->
    restrict: 'A'

    link: (scope, element, attributes, ngModelCtrl) ->
      model = attributes.ngUpdate.split('"').join('\'')
      html = element[0].outerHTML
      html = angular.element(html)
      html[0].setAttribute("ng-model", model.split(',')[0])
      callModel = model
      if element[0].attributes['placeholder']
        placeholder = element[0].attributes['placeholder'].value
      else
        placeholder = ''
        for word in callModel.split('.').pop().split('_')
          placeholder += word[0].toUpperCase() + word[1..-1].toLowerCase()
      callModel += ',' + attributes.ngTrackBy if attributes.ngTrackBy
      callFunction = 'update("' + callModel + '")'
      callFunction += ';' + attributes.ngCallback if attributes.ngCallback
      if element[0].tagName == 'INPUT'
        html[0].setAttribute("ng-change-on-blur", callFunction) if attributes.type != 'radio' && attributes.type != 'checkbox'
        html[0].setAttribute("ng-change", callFunction)     unless attributes.type != 'radio' && attributes.type != 'checkbox'
      else if element[0].tagName == 'SELECT'
        html[0].setAttribute("ng-change", callFunction)
      else if element[0].tagName == 'TEXTAREA'
        html[0].setAttribute("ng-change-debounce", callFunction)
      else
        callFunction = callModel + ' = !' + callModel + ' ; update("' + callModel + '")'
        callFunction += ';' + attributes.ngCallback if attributes.ngCallback
        html[0].setAttribute("ng-click", callFunction)
      html[0].setAttribute('placeholder',placeholder)
      html[0].removeAttribute('ng-update')
      element.replaceWith html
      $compile(html)(scope)

    controller: ($scope, $injector,factoryName) ->
      $scope.update = (modelName)->
        input = modelName.split(',')
        trackby = input.pop() if input.length > 1
        trackby = trackby.split(';') if trackby
        trackby = [] unless trackby
        data = input.splice(0,1)[0].split('.')
        functions = input.join(',').split(')')
        factory = factoryName(data[0])
        object = {id: $scope[data[0]]['id']}
        object[data[0]] = {id: $scope[data[0]]['id']}
        object[data[0]][data[1]] = $scope[data[0]][data[1]]
        list = $injector.get(factory)
        list.update object, (returnData) ->
          for tracked in trackby
            $scope[data[0]][tracked] = returnData[tracked]
          $scope[data[0]][data[1]] = returnData[data[1]] if $scope[data[0]][data[1]] == object[data[0]][data[1]]
          callFunctions = []
          for callFunction in functions
            callFunctions.push(callFunction + ',' + JSON.stringify(returnData) + ')') if callFunction.length > 0
          $scope.$eval( callFunctions.join('') ) if callFunctions.join('').length > 0
