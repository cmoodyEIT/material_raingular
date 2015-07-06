angular.module 'NgRepeatList', ['Factories']
  .directive 'ngRepeatList', ->
    restrict: 'A',
    replace: true
    link: (scope, element, attributes) ->
      filters = attributes.ngRepeatList.split('|')
      parsed = filters.splice(0,1)[0].split(' in ')
      factory = parsed.pop().replace(/\s+/g, '')
      element.parent().addClass('loading')
      list = element.injector().get(factory)
      context = {}
      context[attributes.ngContext + '_id'] = scope[attributes.ngContext].id if attributes.ngContext
      list.index context, (data) ->
        scope[factory] = data
        element.parent().removeClass('loading')
    template: (element, attributes) ->
      element[0].setAttribute('ng-repeat', attributes.ngRepeatList)
      element[0].removeAttribute('ng-repeat-list')
      html = element[0].outerHTML
      return html
  .directive 'ngRepeatStartList', ->
    restrict: 'A',
    replace: true
    link: (scope, element, attributes) ->
      filters = attributes.ngRepeatStartList.split('|')
      parsed = filters.splice(0,1)[0].split(' in ')
      factory = parsed.pop().replace(/\s+/g, '')
      element.parent().addClass('loading')
      list = element.injector().get(factory)
      context = {}
      context[attributes.ngContext + '_id'] = scope[attributes.ngContext].id if attributes.ngContext
      list.index context, (data) ->
        scope[factory] = data
        element.parent().removeClass('loading')
    template: (element, attributes) ->
      element[0].setAttribute('ng-repeat-start', attributes.ngRepeatStartList)
      element[0].removeAttribute('ng-repeat-start-list')
      html = element[0].outerHTML
      return html
