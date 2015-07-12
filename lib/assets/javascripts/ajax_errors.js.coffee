angular.factories
  .factory 'AjaxErrorsInterceptor', ($q, $rootScope) ->
    request: (config)          ->
      $rootScope.xhr_errors = []
      config
    requestError: (rejection)  -> rejection
    response: (response)       -> response
    responseError: (rejection) ->
      $rootScope.xhr_errors = []
      for k,v of rejection.data
        for description in v
          $rootScope.xhr_errors.push(k + ' ' + ' ' + description)
      rejection
