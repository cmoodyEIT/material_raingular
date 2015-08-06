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
          placeholder += word[0].toUpperCase() + word[1..-1].toLowerCase() + ' '
      callModel += ',' + attributes.ngTrackBy if attributes.ngTrackBy
      callFunction = 'update("' + callModel + '")'
      callFunction += ';' + attributes.ngCallback if attributes.ngCallback
      if element[0].tagName == 'INPUT'
        html[0].setAttribute("ng-change-on-blur", callFunction) if attributes.type != 'radio' && attributes.type != 'checkbox' && attributes.type != 'hidden'
        html[0].setAttribute("ng-change", callFunction)     unless attributes.type != 'radio' && attributes.type != 'checkbox' && attributes.type != 'hidden'
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

    controller: ($scope, $injector,factoryName, $element) ->
      $scope.update = (modelName)->
        override    = if $element[0].attributes['ng-override'] then $element[0].attributes['ng-override'].value.split('.') else []
        input       = modelName.split(',')
        trackby     = input.pop() if input.length > 1
        trackby     = trackby.split(';') if trackby
        trackby     = [] unless trackby
        data        = input.splice(0,1)[0].split('.')
        functions   = input.join(',').split(')')
        factory = factoryName(override[0] || data[0])
        if override[1]
          object = {id: $scope.$eval(override[0]).id}
          object[override[1]] = $scope.$eval(override[1])
        else
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

  .directive 'mdUpdate', ($timeout, factoryName, $injector) ->
    restrict: 'A'
    require:  'ngModel'

    link: (scope, element, attributes, ngModelCtrl) ->
      modelName = attributes.ngModel
      watcher = ->
        scope.$watch modelName, (updated,old) ->
          update(updated) unless updated == old
      equiv = (left,right) ->
        return true if left == right
        return true if (!!left && !!right) == false
        false

      update = (value) ->
        override    = if attributes.ngOverride then attributes.ngOverride.split('.') else []
        functions   = if attributes.ngCallback then attributes.ngCallback.split(';') else []
        trackby     = if attributes.ngTrackBy  then attributes.ngTrackBy.split(';')  else []
        data        = modelName.split('.')
        factory     = factoryName(override[0] || data[0])
        if override[1]
          object = {id: scope.$eval(override[0]).id}
          object[override[1]] = scope.$eval(override[1])
        else
          object = {id: scope[data[0]]['id']}
          object[data[0]] = {id: scope[data[0]]['id']}
          object[data[0]][data[1]] = scope[data[0]][data[1]]
        list = $injector.get(factory)

        list.update object, (returnData) ->
          for tracked in trackby
            scope[data[0]][tracked] = returnData[tracked]
          scope[data[0]][data[1]] = returnData[data[1]] if equiv(scope[data[0]][data[1]], object[data[0]][data[1]]) && !equiv(scope[data[0]][data[1]], returnData[data[1]])
          scope[data[0]].errors   = returnData.errors
          callFunctions = []
          for callFunction in functions
            [match,func,args] = callFunction.match(/(.*)\((.*)\)/)
            if typeof scope[func] == 'function'
              scope[func](args,returnData)
            else if typeof window[func] == 'function'
              window[func](args,returnData)
      if element[0].tagName == 'INPUT'
        if attributes.type == 'radio' || attributes.type == 'checkbox' || attributes.type == 'date'
          element.bind 'input', (event) ->
            return unless ngModelCtrl.$valid
            update(element.val())
        else if attributes.type == 'hidden'
          watcher()
        else
          oldValue = null
          element.bind 'focus', ->
            scope.$apply ->
              oldValue = element.val()
          element.bind 'blur', (event) ->
            delay = if element.hasClass('autocomplete') then 300 else 0
            $timeout ->
              scope.$apply ->
                newValue = element.val()
                update(newValue) if (newValue != oldValue)
            , delay
      else if element[0].tagName == 'TEXTAREA'
        element.bind 'keyup', ->
          $timeout.cancel(scope.debounce)
          scope.debounce = $timeout ->
            update(element.val())
          ,750
      else
        watcher()
      if element[0].attributes['placeholder']
        placeholder = element[0].attributes['placeholder'].value
      else
        placeholder = ''
        for word in modelName.split('.').pop().split('_')
          placeholder += word[0].toUpperCase() + word[1..-1].toLowerCase() + ' '
      element.attr('placeholder',placeholder)
