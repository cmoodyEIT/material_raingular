angular.module('TextArea', [])
  .directive 'textarea', ($timeout) ->
    restrict: 'E'
    link: (scope, element, attributes) ->
      scope.initialHeight = scope.initialHeight || element[0].style.height
      element.css('resize','none').css('overflow','hidden').css('border','0px')
      resize = ->
        element[0].style.height = scope.initialHeight
        element[0].style.height = "" + element[0].scrollHeight + "px"
      element.on("blur keyup change", resize)
      $timeout(resize, 0)
