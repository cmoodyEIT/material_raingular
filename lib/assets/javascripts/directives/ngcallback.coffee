angular.module 'NgCallback', ['Factories', 'FactoryName']

  .directive 'ngCallback', ->
    restrict: 'A'
    controller: ($scope,$element) ->
      @evaluate = (returnData)->
        for callback in $element[0].attributes['ng-callback'].value.split(';')
          [match,func,args] = callback.match(/(.*)\((.*)\)/)
          data = []
          for arg in args.split(',')
            data.push $scope.$eval(arg)
          data.push returnData
          if typeof $scope[func] == 'function'
            $scope[func] data...
          else if typeof window[func] == 'function'
            window[func] data...
      return
