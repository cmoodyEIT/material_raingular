angular.module('NgWatchShow', [])
  .directive 'ngWatchShow', ($timeout)->
    link: (scope, element, attributes) ->
      scope.$watch attributes.ngWatchShow, (newVal) ->
        if (newVal)
          element.removeClass('ng-hide')
        else
          if element.is(":focus")
            inputs = document.getElementsByTagName('input')
            for input, index in inputs
              inputIndex = index if input == element[0]
            input = angular.element inputs[inputIndex + 1]
            $timeout ->
              input.focus()
          element.addClass('ng-hide')
