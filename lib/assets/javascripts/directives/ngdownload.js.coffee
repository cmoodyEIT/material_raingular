angular.module('NgDownload', [])
  .directive 'ngDownload', ->
    replace: true,
    link: (scope, element, attrs) ->
      value = attrs.ngDownload
      value = if value == true || value == 'true' then '' else value
      value = null if (value == null || value == 'false' || value == '')
      element.attr 'download',value