angular.module('NgSortable', [])
  .directive 'ngSortable', ($parse)->
    template: (element) ->
      '<span>' + element[0].innerHTML + '</span><i class="sort"></i>'
    link: (scope,element,attributes) ->
      scope.sortableField = (resource)->
        return 'position' unless !!scope.howToSortField
        scope.howToSortField(resource)
      sortableFunc = $parse(attributes.ngSortable)
      icon = element.find('i')
      icon.bind 'click', ->
        element.parent().find('i').removeClass('up')
        element.parent().find('i').removeClass('down')
        scope.$apply ->
          if scope.howToSortField == sortableFunc
            scope.sortableReverse = !scope.sortableReverse
          else
            scope.sortableReverse = false
            scope.howToSortField = sortableFunc
          if scope.sortableReverse == false
            icon.addClass('down')
            icon.removeClass('up')
          else
            icon.addClass('up')
            icon.removeClass('down')
