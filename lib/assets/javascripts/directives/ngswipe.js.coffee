angular.module('NgSwipe', [])
  .factory 'SwipeStart', ->
    object = {}

    object.set = (x,y) ->
      this.x = x
      this.y = y

    object.get = ->
        return this

    return object
  .directive 'ngSwipeUp', ->
    controller: ($scope, $element, SwipeStart) ->
      callFunction = $element[0].attributes['ng-swipe-up'].value
      if callFunction.indexOf('=') > -1
        split = callFunction.split('=')
        callFunction = []
        for arg in split
          unless arg.indexOf('true') > -1 || arg.indexOf('false') > -1
            callFunction.push('!$scope.' + arg.replace(/!/g,'').trim()) if arg.indexOf('!') > -1
            callFunction.push('$scope.' + arg) if arg.indexOf('!') < 0
          else
            callFunction.push('!' + arg.replace(/!/g,'').trim()) if arg.indexOf('!') > -1
            callFunction.push(arg) if arg.indexOf('!') < 0
        callFunction = callFunction.join(' = ')
      else
        callFunction = '$scope.' + callFunction.trim()
      $element.bind 'touchstart', (event) ->
        touchStart = event.originalEvent.targetTouches[0]
        SwipeStart.set(touchStart.screenX, touchStart.screenY)
      $element.bind 'touchend', (event) ->
        touchEnd = event.originalEvent.changedTouches[0]
        if (Math.abs(SwipeStart.get().x - touchEnd.screenX) < Math.abs(SwipeStart.get().y - touchEnd.screenY)) && (SwipeStart.get().y - touchEnd.screenY > 0)
          $scope.$apply ->
            eval callFunction
  .directive 'ngSwipeDown', ->
    controller: ($scope, $element, SwipeStart) ->
      callFunction = $element[0].attributes['ng-swipe-down'].value
      if callFunction.indexOf('=') > -1
        split = callFunction.split('=')
        callFunction = []
        for arg in split
          unless arg.indexOf('true') > -1 || arg.indexOf('false') > -1
            callFunction.push('!$scope.' + arg.replace(/!/g,'').trim()) if arg.indexOf('!') > -1
            callFunction.push('$scope.' + arg) if arg.indexOf('!') < 0
          else
            callFunction.push('!' + arg.replace(/!/g,'').trim()) if arg.indexOf('!') > -1
            callFunction.push(arg) if arg.indexOf('!') < 0
        callFunction = callFunction.join(' = ')
      else
        callFunction = '$scope.' + callFunction.trim()
      $element.bind 'touchstart', (event) ->
        touchStart = event.originalEvent.targetTouches[0]
        SwipeStart.set(touchStart.screenX, touchStart.screenY)
      $element.bind 'touchend', (event) ->
        touchEnd = event.originalEvent.changedTouches[0]
        if (Math.abs(SwipeStart.get().x - touchEnd.screenX) < Math.abs(SwipeStart.get().y - touchEnd.screenY)) && (SwipeStart.get().y - touchEnd.screenY < 0)
          $scope.$apply ->
            eval callFunction
