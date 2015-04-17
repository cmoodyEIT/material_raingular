angular.module('NgChangeOnBlur', [])
  .directive 'ngChangeOnBlur', ($timeout)->
    restrict: 'A',
    require: 'ngModel',
    link: (scope, element, attributes, ngModelCtrl) ->
      return if (attributes.type == 'radio' || attributes.type == 'checkbox')
      callFunction = attributes.ngChangeOnBlur
      oldValue = null
      element.bind 'focus', ->
        scope.$apply ->
          oldValue = element.val()
      element.bind 'blur', (event) ->
        delay = if element.hasClass('autocomplete') then 300 else 0
        $timeout ->
          scope.$apply ->
            newValue = element.val()
            scope.$eval(callFunction) if (newValue != oldValue)
        , delay

