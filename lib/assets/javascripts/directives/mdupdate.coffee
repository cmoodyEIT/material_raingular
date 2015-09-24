class ElementUpdate
  constructor: (scope,element,attributes,controllers,RailsUpdater) ->
    [@ngModelCtrl,@ngCallbackCtrl,@ngTrackByCtrl] = controllers
    @updater     = RailsUpdater.new(scope,controllers,attributes.ngModel,attributes.ngOverride)
    @type        = attributes.type
    @tagName     = element[0].tagName
    @modelName   = attributes.ngModel
    @isInput     = @tagName == 'INPUT'
    @scope       = scope
    @element     = element
    @placeholder = attributes.placeholder
    @bindInput()          if @isInput
    @bindElement()    unless @isInput
    @setPlaceholder() unless @placeholder
  watcher: ->
    eu = @
    @scope.$watch @modelName, (updated,old) ->
      eu.updater.update(updated) unless updated == old
  bindInput: ->
    eu = @
    if @type == 'radio' || @type == 'date'
      @element.bind 'input', (event) ->
        return unless eu.ngModelCtrl.$valid
          eu.updater.update(element.val())
    else if @type == 'hidden'
      @watcher()
    else if @type == 'checkbox'
      @element.bind 'click', (event) ->
        eu.updater.update(element.val())
    else
      oldValue = null
      @element.bind 'focus', ->
        eu.scope.$apply ->
          oldValue = eu.element.val()
      @element.bind 'blur', (event) ->
        delay = if @element.hasClass('autocomplete') then 300 else 0
        $timeout ->
          @scope.$apply ->
            newValue = @element.val()
            @updater.update(newValue) if (newValue != oldValue)
        , delay

  bindElement: ->
    if @tagName == 'TEXTAREA'
      @element.bind 'keyup', ->
        $timeout.cancel(scope.debounce)
        scope.debounce = $timeout ->
          eu.updater.update(element.val())
        ,750
    else
      @watcher()
  setPlaceholder: ->
    placeholder = ''
    for word in @modelName.split('.').pop().split('_')
      placeholder += word[0].toUpperCase() + word[1..-1].toLowerCase() + ' '
    @element.attr('placeholder',placeholder)

angular.module 'MdUpdate', ['Factories', 'FactoryName','RailsUpdater']
  .directive 'mdUpdate', ($timeout, factoryName, $injector, RailsUpdater) ->
    restrict: 'A'
    require:  ['ngModel','?ngCallback','?ngTrackBy']

    link: (scope, element, attributes, ngControllers) ->
      new ElementUpdate(scope,element,attributes,ngControllers, RailsUpdater)
