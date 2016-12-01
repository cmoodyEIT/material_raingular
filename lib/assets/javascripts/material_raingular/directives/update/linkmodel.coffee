class DirectiveModels.MrUpdateModel extends AngularLinkModel
  @inject(
    '$parse'
    '$timeout'
    'RailsUpdater'
  )
  initialize: ->
    [@ngModelCtrl,@mrCallbackCtrl,@ngTrackByCtrl] = @$controller
    @updater     = @RailsUpdater.new(@$scope,@$controller,@$attrs.ngModel,@$attrs.ngOverride,@$attrs.ngFactory)
    @_bind()

  @register(Directives.MrUpdate)

  _bind: -> @$timeout => @_bindInput()[@_funcName()]()
  _bindInput: =>
    radio:    => @_boundUpdate('input',true)
    date:     => @_boundUpdate('input',true)
    checkbox: => @_boundUpdate('click')
    hidden:   => @_watcher()
    text:     => @_bindText()
    textarea: => @_bindDebounce(750,'keyup')
    other:    => @_watcher()

  _boundUpdate: (binding,checkValid) ->
    @$element.bind binding, (event) =>
      return if !@ngModelCtrl.$valid && checkValid
      @updater.update(@$element.val())

  _bindText: ->
    @$element.bind 'focus', =>
      @$scope.$apply =>
        @oldValue = @$element.val()
    delay = if @$element.hasClass('autocomplete') then 300 else 0
    @_bindDebounce(delay,'blur')

  _bindDebounce: (delay,binding) ->
    @$element.bind binding, (event) =>
      return if @$element.val() == @oldValue
      @$timeout.cancel(@debounce)
      @debounce = @$timeout =>
        @updater.update(@$element.val())
      ,delay

  _watcher: ->
    @$scope.$watch @_modelVal(), (updated,old) =>
      return if old == undefined
      @updater.update(updated) unless updated == old
  _specificTypes: ['radio','date','checkbox','hidden']
  _type:          -> @$attrs.type
  _tagName:       -> @$element[0].tagName
  _modelName:     -> @$attrs.ngModel
  _modelVal:      -> @$parse(@$attrs.ngModel)
  _isInput:       -> @_tagName() == 'INPUT'
  _funcName: ->
    return 'textarea' if @_tagName() == 'TEXTAREA'
    return (@_specificTypes.intersection([@_tagName()])[0] || 'text') if @_isInput()
    'other'
