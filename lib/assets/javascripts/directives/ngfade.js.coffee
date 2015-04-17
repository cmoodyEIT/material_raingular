angular.module('NgFade', [])
  .directive 'ngFadeOut', ->
    link: (scope, element, attributes) ->
      element.css('transition', '0.3s all')
      scope.$watch attributes.ngFadeOut, (value) ->
        if value
          element.css('opacity', '0')
          element.css('z-index', '0')
        else
          element.css('opacity', '1')
          element.css('z-index', '1')
  .directive 'ngFadeIn', ->
    link: (scope, element, attributes) ->
      element.css('transition', '0.3s all')
      scope.$watch attributes.ngFadeIn, (value) ->
        if value
          element.css('opacity', '1')
          element.css('z-index', '1')
        else
          element.css('opacity', '0')
          element.css('z-index', '0')
