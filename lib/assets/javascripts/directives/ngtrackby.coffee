angular.module 'NgTrackBy', ['Factories', 'FactoryName']

  .directive 'ngTrackBy', ->
    restrict: 'A'

    controller: ($scope,$element) ->
      @evaluate = (returnData)->
        parent = attributes['ng-model'].value.split('.')[0]
        for model in $element[0].attributes['ng-track-by'].value.split(';')
          $scope[parent][model] = returnData[model]
      return
