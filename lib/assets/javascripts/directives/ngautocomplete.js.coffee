class Autocomplete
  constructor: (scope,factory_name, element,$filter)->
    @element     = element
    @attributes  = element[0].attributes
    @scope       = scope
    @model_name  = @attributes['ng-model'].value
    @list_model  = @attributes['ng-list-model'].value.split('.')
    @options     = if @attributes['ng-list-options']  then eval("(" + @attributes['ng-list-options'].value + ")") else {}
    @context     = if @attributes['ng-context']       then @attributes['ng-context'].value
    @sort_by     = if @attributes['ng-sort-by']       then @attributes['ng-sort-by'].value else @list_attr
    @list_attr   = @list_model[1]
    @factory     = factory_name(@list_model[0])
    @scopes      = @context.split('.') if @context
    @parent_name = @scopes.pop() if @scopes
    @list        = angular.element("<div class='autocomplete menu'></div>")
    @filter      = $filter
    @existing_factory = @scope[@factory] || @scope.$parent[@factory]
    @listFactory = @element.injector().get(@factory) unless @existing_factory
    @list.insertAfter(@element[0])

    if @parent_name
      @parent_id   = @parent_name + if @parent_name.indexOf('_id') < 0 then '_id' else ''

    @load()

  parent_context: =>
    hash = {}
    hash[@parent_id] = @parent() if @context
    return hash
  serialize: =>
    hash = {}
    for key,val of @options
      hash[key] = val
    for key,val of @parent_context()
      hash[key] = val
    hash
  model: (val)=>
    return @scope.$eval(@model_name + '="' + val + '"') if val
    return @scope.$eval(@model_name)
  parent: =>
    return null unless @context
    return @scope.$eval(@context)
  load: ->
    scope   = @scope
    factory = @factory
    model   = @model
    updateView = @updateView
    if @context
      return unless @parent()
    if @existing_factory
      scope[factory] = @existing_factory
      scope.$watchCollection factory, (newVal) ->
        updateView(model())
      updateView(model())
    else
      @listFactory.index @serialize(), (data) ->
        scope[factory] = data
        updateView(model())
  updateView: (value) =>
    object              = {}
    object[@list_attr]  = value || ''
    scope               = @scope
    model               = @model
    model_name          = @model_name
    filtered            = @filter('filter')((scope[@factory] || []), object )
    filtered            = @filter('orderBy')(filtered, @sort_by)
    items               = []
    for item in filtered
      item = angular.element "<a class='item'>" + item[@list_attr] + "</a>"
      item.bind 'click', (event) ->
        model(event.target.textContent)
        scope.$eval event.target.parentNode.previousSibling.attributes['ng-change-on-blur'].value
      items.push item
    @list.empty()
    @list.append(items)

angular.module('AutoComplete', [ 'FactoryName'])

  .directive 'ngAutocomplete', ->
    restrict: 'E'
    replace:  true
    require:  'ngModel'
    require:  'ngListModel'
    template: (element, attributes) ->
      newElement = angular.element('<input>')
      newElement.addClass('autocomplete')
      newElement[0].setAttribute('ng-update',attributes.ngModel)
      newElement[0].setAttribute('auto-complete',true)
      return newElement[0].outerHTML
    controller: ($scope, $element, $filter, $timeout, factoryName) ->
      ac = new Autocomplete($scope,factoryName,$element,$filter)
      if ac.context
        $scope.$watch ac.context, (newVal, oldVal) ->
          if newVal
            ac.load()
      $scope.$watch ac.model_name, (newVal) ->
        ac.updateView(newVal)

  .directive 'autoComplete', ->
    restrict: 'A'
    require: '?ngModel'
    link: (scope, element, attributes, ngModel) ->
      if element[0].tagName == 'INPUT'
        element.bind 'focus', ->
          pos = element.position() if element.position
          element.next()[0].style.left = '0px'
        element.bind 'blur', ->
          active = angular.element(element.next()[0].getElementsByClassName('active')[0])
          active.removeClass('active')
          ngModel.$setViewValue(element.val())
          ngModel.$render()
        element.bind 'keydown', (input)->
          keypress = (direction) ->
            index = if direction == 'next' then 0 else element.next().find('a').length - 1
            selected = angular.element(element.next()[0].getElementsByClassName('active')[0])
            if selected.hasClass('active')
              selected.removeClass('active')
              until complete
                selected = angular.element(selected[0][direction + 'Sibling']) if selected[0]
                complete = !!selected[0]
                complete = selected[0].tagName == 'A' if complete
                complete = true if !selected[0]
            selected = angular.element(element.next().find('a')[index]) unless selected[0]
            ind = 0
            for el,i in element.next()[0].getElementsByTagName('a')
              ind = i if el == selected[0]
            scroll = selected[0].scrollHeight * ind
            selected[0].parentElement.scrollTop = scroll
            selected.addClass('active')
            element.val(selected.text())
          if input.keyCode == 40
            keypress('next')
          if input.keyCode == 38
            keypress('previous')
