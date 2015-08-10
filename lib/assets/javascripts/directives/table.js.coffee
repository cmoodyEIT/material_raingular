angular.module('Table', [])
  .directive 'stickyHeader', ($timeout) ->
    restrict: 'A'
    link: (scope, element, attributes) ->
      tableLoaded = ->
        element.find('tbody').find('td').length > 0
      parentHeights = ->
        heights = [element[0].offsetHeight]
        parent = element[0].parentElement
        until !parent
          heights.push(parent.offsetHeight)
          parent = parent.parentElement
        heights
      minimumParentHeight = ->
        Math.min.apply(Math, parentHeights())
      maximumParentHeight = ->
        Math.max.apply(Math, parentHeights())
      tbody = ->
        angular.element(element.find('tbody')[0])
      thead = ->
        angular.element(element.find('thead')[0])
      initialize = ->
        bodyWatcher() if bodyWatcher
        parent = angular.element(element[0].parentElement)
        parent.css('min-height', minimumParentHeight() + 'px')
        parent.css('max-height', maximumParentHeight() + 'px')
        parent.css('overflow-y', 'hidden')
        for col in element.find('th')
          col.style.width = col.offsetWidth + 'px'
        for col in element.find('td')
          col.style.width = col.offsetWidth + 'px'
        theight = minimumParentHeight() - thead()[0].offsetHeight - 20
        tbody().css('display', 'block').css('overflow-y', 'auto').css('height', theight + 'px').css('overflow-x', 'hidden')
        thead().css('display','block').css('width', tbody().find('tr')[0].offsetWidth + 'px')
        bodyWatcher = scope.$watch bodyWidth, (val,old) ->
          unless val == old
            $timeout ->
              reinitialize()
      bodyWidth = ->
        tbody()[0].offsetWidth
      reinitialize = ->
        tbody().css('display','')
        thead().css('display','')
        initialize()
      if element[0].tagName.toLowerCase() == 'table'
        loadedWatcher = scope.$watch tableLoaded, (isLoaded) ->
          if isLoaded
            initialize()
            window.addEventListener 'resize', ->
              reinitialize()
            loadedWatcher()
