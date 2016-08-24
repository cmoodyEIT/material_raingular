angular.factories
  .factory 'AjaxErrorsInterceptor', ($q, $rootScope) ->
    request: (config)          ->
      #$rootScope.xhr_errors = []
      config
    requestError: (rejection)  -> $q.reject(rejection)
    response: (response)       -> response
    responseError: (rejection) ->
      #$rootScope.xhr_errors = []
      #for error in rejection.data.errors
      #  $rootScope.xhr_errors.push(error)
      $q.reject(rejection)
