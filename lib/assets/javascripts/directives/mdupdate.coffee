class ElementUpdate
  constructor: (scope,element,attributes,controllers,RailsUpdater,timeout,parse) ->
    [@ngModelCtrl,@ngCallbackCtrl,@ngTrackByCtrl] = controllers
    @updater     = RailsUpdater.new(scope,controllers,attributes.ngModel,attributes.ngOverride,attributes.ngFactory)
    @type        = attributes.type
    @tagName     = element[0].tagName
    @modelName   = attributes.ngModel
    @modelVal    = parse(attributes.ngModel)
    @isInput     = @tagName == 'INPUT'
    @scope       = scope
    @element     = element
    @timeout     = timeout
    @bindInput()          if @isInput
    @bindElement()    unless @isInput
  watcher: ->
    eu = @
    @scope.$watch @modelVal, (updated,old) ->
      eu.updater.update(updated) unless updated == old
  bindInput: ->
    eu = @
    if @type == 'radio' || @type == 'date'
      @element.bind 'input', (event) ->
        return unless eu.ngModelCtrl.$valid
          eu.updater.update(eu.element.val())
    else if @type == 'hidden'
      @watcher()
    else if @type == 'checkbox'
      @element.bind 'click', (event) ->
        eu.updater.update(eu.element.val())
    else
      oldValue = null
      @element.bind 'focus', ->
        eu.scope.$apply ->
          oldValue = eu.element.val()
      @element.bind 'blur', (event) ->
        delay = if eu.element.hasClass('autocomplete') then 300 else 0
        eu.timeout ->
          eu.scope.$apply ->
            newValue = eu.element.val()
            eu.updater.update(newValue) if (newValue != oldValue)
        , delay

  bindElement: ->
    eu = @
    if @tagName == 'TEXTAREA'
      @element.bind 'keyup', ->
        eu.timeout.cancel(eu.debounce)
        eu.debounce = eu.timeout ->
          eu.updater.update(eu.element.val())
        ,750
    else
      @watcher()

angular.module 'MdUpdate', ['Factories', 'FactoryName','RailsUpdater']
  .directive 'mdUpdate', ($timeout, factoryName, $injector, RailsUpdater,$parse) ->
    restrict: 'A'
    require:  ['ngModel','?ngCallback','?ngTrackBy']

    link: (scope, element, attributes, ngControllers) ->
      new ElementUpdate(scope,element,attributes,ngControllers, RailsUpdater,$timeout,$parse)
