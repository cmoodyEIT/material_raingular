angular.module('NgSlide', [])
  .factory 'PreviousHeight', ->
    object     = []
    object.set = (height) ->
      this.push(height)
    object.get = ->
      return this.pop()
    return object
  .directive 'ngSlide', (PreviousHeight)->
    link: (scope, element) ->
      window.onresize = ->
        for slider in angular.element('[ng-slide]')
          for att in slider.attributes['ng-slide'].value.split('{')[1].split(',')
            margin = att.split(':')[1].trim() if att.indexOf('margin') > -1
          margin   = margin.replace(/{|}|'|"| /g, "") #' <-syntax highlighting thing
          element  = angular.element(slider)
          element.css(margin,calcStart(slider)) unless element.css(margin) == '0px'
      contents = ->
        return element.html()
      calcStart = (element) ->
        amount = Math.max(element.offsetWidth,element.offsetHeight) + 'px'
        return       amount if params[0] == 'left'
        return '-' + amount if params[0] == 'right'
        return '-' + amount
      hash   = element[0].attributes['ng-slide'].value.split('{')
      params = hash[0].split(',')
      params[2] = hash[1]
      margin = 'margin'
      start  = '0'
      end    = '-100%'
      delay  = '0.3'
      if params[0] == 'up'
        margin += '-top'
        start   = '100%'
        end     = '0'
      else if params[0] == 'left'
        margin += '-right'
      else if params[0] == 'right'
        margin += '-left'
      else
        margin += '-top'
      strings = params[2].replace(/{|}|'|"| /g, "").split(',') #' <-syntax highlighting thing
      params[2] = {}
      for obj in strings
        keyValue = obj.split(':')
        params[2][keyValue[0]] = keyValue[1]
      if params[2]
        delay  = params[2].duration if params[2].duration
        start  = params[2].start    if params[2].start
        end    = params[2].end      if params[2].end
        margin = params[2].margin   if params[2].margin
      delay += 's ' + margin
      element.css('transition', delay)
      if params[2].auto
        scope.$watch contents, (newVal, oldVal) ->
          if newVal != oldVal
            start = calcStart(element[0])
            end = 0 + 'px'
          if scope[params[1]]
            element.css(margin, end)
          else
            element.css(margin, start)
      setHeight = (element) ->
        return if params[2].resize == 'false'
        rect    = element[0].getBoundingClientRect()
        content = angular.element('.content')[0].getBoundingClientRect()
        height  = rect.height + rect.top - content.top unless params[0] == 'down'
        height  = rect.height + rect.bottom if  params[0] == 'down'
        angular.element('.content').css('height',height)
      scope.$watch params[1], (newValue, oldValue)->
        if params[2].auto
          start = calcStart(element[0])
          end = params[2].finalMargin || 0 + 'px'
        if newValue
          PreviousHeight.set(angular.element('.content')[0].getBoundingClientRect().height)
          element.css(margin, end)
          setHeight(element)
          watcher = scope.$watch contents, (newVal) ->
            setHeight(element)
        else
          watcher() if watcher
          element.css(margin, start)
          angular.element('.content').css('height', PreviousHeight.get())
