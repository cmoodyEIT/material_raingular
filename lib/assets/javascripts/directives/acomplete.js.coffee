angular.module('AComplete', [ 'FactoryName'])

  .directive 'acList', ($parse,$filter)->
    restrict: 'A'
    require:  'ngModel'
    link: (scope, element, attributes, ngModelCtrl) ->
      scope.autoCompleteList = ->
        [item,list] = attributes.acList.split(' in ')
        actions = item.split('.')
        actions.shift()
        constructed = '.' + actions.join('.') if actions.length > 0
        constructed = '' unless actions.length > 0
        records = $filter('filter')($parse(list)(scope), (ngModelCtrl.$viewValue || '')) || []
        result = for record in records
          eval("record" + constructed)
        result || []
    controller: ($scope) ->
      @list = ->
        $scope.autoCompleteList()
      return
  .directive 'aComplete', ->
    restrict: 'E'
    replace: true
    require:  ['ngModel','acList']
    template: (element, attributes) ->
      element.addClass('autocomplete')
      input = element[0].outerHTML.replace(/a-complete/g,'input')
      input = angular.element(input).attr('md-update','')
      "<md-input-container>" + input[0].outerHTML + "<div class='autocomplete menu md-whiteframe-z1'><a class='item' ng-click='select(item)' ng-repeat='item in list()'>{{item}}</a></div></md-input-container>"

    link: (scope,element,attributes,controllers) ->
      element.css('position','relative').css('display', 'block')
      scope.select = (item) ->
        controllers[0].$setViewValue(item)
        controllers[0].$render()
      scope.list = controllers[1].list
      menuNode = angular.element(element[0].getElementsByClassName('autocomplete menu'))
      inputNode = element.find('input')
      inputNode.css('padding-top','14px')
      inputNode.bind 'blur', ->
        active = angular.element(menuNode[0].getElementsByClassName('active')[0])
        active.removeClass('active')
        controllers[0].$setViewValue(inputNode.val())
        controllers[0].$render()
      inputNode.bind 'keydown', (input)->
        keypress = (direction) ->
          index = if direction == 'next' then 0 else menuNode.find('a').length - 1
          selected = angular.element(menuNode[0].getElementsByClassName('active')[0])
          if selected.hasClass('active')
            selected.removeClass('active')
            until complete
              selected = angular.element(selected[0][direction + 'Sibling']) if selected[0]
              complete = !!selected[0]
              complete = selected[0].tagName == 'A' if complete
              complete = true if !selected[0]
          selected = angular.element(menuNode.find('a')[index]) unless selected[0]
          ind = 0
          for el,i in menuNode[0].getElementsByTagName('a')
            ind = i if el == selected[0]
          scroll = selected[0].scrollHeight * ind
          selected[0].parentElement.scrollTop = scroll
          selected.addClass('active')
          inputNode.val(selected.text())
        if input.keyCode == 40
          keypress('next')
        if input.keyCode == 38
          keypress('previous')
