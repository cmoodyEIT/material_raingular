angular.module('TextArea', [])
  .directive 'textarea', ($timeout) ->
    restrict: 'E'
    link: (scope, element, attributes) ->
      return if element.hasClass('static')
      initialHeight = initialHeight || element[0].style.height
      element.css('resize','none').css('overflow','hidden').css('border','0px')
      initial = element.parent().css('height')
      resize = ->
        element.parent().css('height',element.parent()[0].offsetHeight) if element.parent()[0]
        element[0].style.height = initialHeight
        element[0].style.height = "" + Math.max(20,element[0].scrollHeight) + "px"
        $timeout ->
          element.parent().css('height',initial)
      element.on("blur keyup change focus input", resize)
      $timeout(resize, 0)
