angular.module('NgMatches', [])
  .directive 'ngMatches', ->
    replace: true
    scope: {
      ngMatches: '='
    }
    template: (element, attributes) ->
      element[0].setAttribute('ng-show','checkMatch(ngMatches)')
      element[0].removeAttribute('ng-matches')
      return element[0].outerHTML
    controller: ($scope,$element) ->
      $scope.checkMatch = (model) ->
        return true unless model
        return $element[0].textContent.toLowerCase().indexOf(model.toLowerCase()) > -1
