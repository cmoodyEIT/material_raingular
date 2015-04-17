angular.module('NgPopup', [])
  .directive 'ngPopup',($timeout) ->
    restrict: 'A',
    scope: {
      ngPopup: '@'
    }
    controller: ($scope, $element) ->
      popup = document.createElement('div')
      popup.setAttribute('class','ng-popup ng-hide')
      exitStatus = true
      while exitStatus
        $scope.uniqueId   = Math.floor(Math.random()*(1000000))
        exitStatus = !!document.getElementById($scope.uniqueId)
      popup.setAttribute('id', $scope.uniqueId)
      document.body.appendChild(popup)

    link: (scope, element, attributes) ->
      setView = (start) ->
        if start
          pos = element[0].getBoundingClientRect()
          popup = document.getElementById(scope.uniqueId)
          popup.style.left = (pos.right + 3) + 'px'
          popup.style.top = (pos.top + 3) + 'px'
          scope.runner = $timeout ->
            document.getElementById(scope.uniqueId).innerHTML = scope.ngPopup
            setView(true)
          30
          popup.classList.remove('ng-hide')
        else
          $timeout.cancel scope.runner
          document.getElementById(scope.uniqueId).classList.add('ng-hide')
      startListener = if (element[0].tagName == 'INPUT' || element[0].tagName == 'INPUT') then 'focus' else 'mouseenter'
      stopListener  = if (element[0].tagName == 'INPUT' || element[0].tagName == 'INPUT') then 'blur'  else 'mouseout'
      element[0].addEventListener startListener, ->
        setView(true)
      element[0].addEventListener stopListener, ->
        setView()
