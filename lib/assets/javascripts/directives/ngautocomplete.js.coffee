angular.module('AutoComplete', ['templates', 'FactoryName'])

  .directive 'ngAutocomplete', ->
    restrict: 'E'
    replace:  true
    require:  'ngModel'
    require:  'ngListModel'
    template: (element, attributes) ->
      newElement = angular.element('<input>')
      newElement.addClass('autocomplete')
      newElement[0].setAttribute('ng-update',attributes.ngModel)
      return newElement[0].outerHTML
    controller: ($scope, $element, $filter, $timeout, factoryName) ->
      modelName   = $element[0].attributes['ng-model'].value
      model = modelName.split('.')
      list        = angular.element("<div class='autocomplete menu'></div>")
      listModel   = $element[0].attributes['ng-list-model'].value.split('.')
      ngName      = listModel[1]
      factory     = factoryName(listModel[0])
      listFactory = $element.injector().get(factory)
      context     = {}
      options = $element[0].attributes['ng-list-options']
      if options
        options = options.value.replace('{','').replace('}','')
        for option in options.split(',')
          param = option.split(':')
          context[param[0].trim()] = param[1].trim()
      if contextAtt = $element[0].attributes['ng-context']
        contextAtt = contextAtt.value
        $scope.$watch contextAtt, (newVal, oldVal) ->
          if newVal
            if contextAtt.indexOf('_id') < 0
              context[contextAtt.split('.').pop() + '_id'] = $scope.$eval(contextAtt).id
            else
              context[contextAtt.split('.').pop()] = $scope.$eval(contextAtt)
            load()
        if contextAtt.indexOf('_id') < 0
          context[contextAtt.split('.').pop() + '_id'] = $scope.$eval(contextAtt).id
        else
          context[contextAtt.split('.').pop()] = $scope.$eval(contextAtt)
      load = ->
        if contextAtt
          return unless $scope.$eval(contextAtt)
        listFactory.query context, (data) ->
          $scope[factory] = data
          if $scope[model[0]]
            updateView($scope[model[0]][model[1]])
      load()
      list.insertAfter($element[0])
      $scope.$watch modelName, (newVal) ->
        updateView(newVal)
      updateView = (value) ->
        object = {}
        object[ngName] = value || ''
        if $scope[factory]
          filtered = $filter('filter')($scope[factory], object )
          filtered = $filter('orderBy')(filtered, ngName)
          items = []
          for item in filtered
            item = angular.element "<a class='item'>" + item[ngName] + "</a>"
            item.bind 'click', (event) ->
              $timeout ->
                $scope.$apply ->
                  $scope[model[0]][model[1]] = event.target.textContent
                  $scope.$eval event.target.parentNode.previousSibling.attributes['ng-change-on-blur'].value
            items.push item
          list.empty()
          list.append(items)

  .directive 'autocomplete', ->
    restrict: 'C'
    require: '?ngModel'
    link: (scope, element, attributes, ngModel) ->
      if element[0].tagName == 'INPUT'
        element.bind 'focus', ->
          pos = element.position()
          element.next()[0].style.left = '0px'
        element.bind 'blur', ->
          element.parent().find('.active').removeClass('active')
        element.bind 'keydown', (input)->
          if input.keyCode == 40
            selected = element.next().find('a.active')
            if selected.hasClass('active')
              selected.removeClass('active')
              selected = selected.next('a')
            else
              selected = element.next().find('a').first()
            if !selected.html() then selected = element.next().find('a').first()
            selected.addClass('active')
            ngModel.$setViewValue(selected.text())
            ngModel.$render()
          if input.keyCode == 38
            selected = element.next().find('a.active')
            if selected.hasClass('active')
              selected.removeClass('active')
              selected = selected.prev('a')
            else
              selected = element.next().find('a').last()
            if !selected.html() then selected = element.next().find('a').last()
            selected.addClass('active')
            ngModel.$setViewValue(selected.text())
            ngModel.$render()
