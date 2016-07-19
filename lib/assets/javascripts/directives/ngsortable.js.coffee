angular.module('NgSortable', [])
  .directive 'ngSortable', ($parse)->
    template: (element) ->
      '<span>' + element[0].innerHTML + '</span><i class="sort"></i>'
    link: (scope,element,attributes) ->
      scopeName = attributes.ngScopeName || scope.$id
      angular.sortableField = {} unless angular.sortableField
      angular.sortableField[scopeName] = {sortableReverse: false} unless angular.sortableField[scopeName]
      scope.sortableField = (resource)->
        return resource.position unless !!angular.sortableField[scopeName].howToSortField
        angular.sortableField[scopeName].howToSortField(resource)
      scope.sortableReverse = ->
        angular.sortableField[scopeName].sortableReverse
      sortableFunc = $parse(attributes.ngSortable)
      icon = element.find('i')
      if Object.keys(attributes).includes('ngInitialSort')
        angular.sortableField[scopeName].howToSortField  = sortableFunc
        if attributes.ngInitialSort == 'reverse'
          angular.sortableField[scopeName].sortableReverse = true
          icon.addClass('up')
        else
          icon.addClass('down')
      icon.bind 'click', ->
        element.parent().find('i').removeClass('up')
        element.parent().find('i').removeClass('down')
        scope.$apply ->
          if angular.sortableField[scopeName].howToSortField == sortableFunc
            angular.sortableField[scopeName].sortableReverse = !angular.sortableField[scopeName].sortableReverse
          else
            angular.sortableField[scopeName].sortableReverse = false
            angular.sortableField[scopeName].howToSortFieldi = attributes.ngSortable
            angular.sortableField[scopeName].howToSortField = sortableFunc
          if angular.sortableField[scopeName].sortableReverse == false
            icon.addClass('down')
            icon.removeClass('up')
          else
            icon.addClass('up')
            icon.removeClass('down')
