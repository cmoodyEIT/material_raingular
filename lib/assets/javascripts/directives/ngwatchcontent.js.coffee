angular.module('NgWatchContent', [])
  .directive 'ngWatchContent', ->
    controller: ($scope, $rootScope) ->
      $scope.watchContents = ->
        contents = ''
        for element in angular.element('[ng-watch-content]')
          contents += element.outerHTML
        return contents
      $rootScope.contentWatcher = $scope.$watch 'watchContents()', ->
        height = 0
        for element in angular.element('[ng-watch-content]')
          height += element.getBoundingClientRect().height
        angular.element('.content').css('min-height', height)