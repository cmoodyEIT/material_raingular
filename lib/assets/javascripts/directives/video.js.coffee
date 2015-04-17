angular.module('Video', [])
  .directive 'video',($timeout) ->
    restrict: 'E'
    link: (scope, element, attributes) ->
      element[0].addEventListener 'click', (event)->
        if element[0].paused
          element[0].play()
        else
          element[0].pause()

