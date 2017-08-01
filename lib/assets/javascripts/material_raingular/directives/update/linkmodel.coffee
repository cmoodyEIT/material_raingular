class DirectiveModels.MrUpdateModel extends AngularLinkModel
  @inject(
    '$parse'
    '$timeout'
  )
  initialize: ->
    [@ngModelCtrl,@mrCallbackCtrl] = @$controller
    @parsed = Helpers.NgModelParse(@$attrs.ngModel,@$scope)
    @atom = @parsed.pop()
    @parent = @parsed.pop()
    @parentVal = ->
      @parsedScope = @$scope
      @parsedScope = @$parse(atom)(@parsedScope) for atom in @parsed
      @$parse(@parent)(@parsedScope)
    @atomVal   = @$parse(@atom)
    @_resourcify()
    @_bind()

  @register(Directives.MrUpdate)

  _klass: ->
    @$attrs.mrUpdateKlass || @_factory() || @parent.classify()
  _resourcify: ->
    return unless @parentVal()
    ActiveRecord.$Resource._resourcify(@parentVal(),@_klass())
  _update: ->
    @_resourcify()
    return unless @parentVal()
    @parentVal().$save.bind(@parentVal())().then((data) => @mrCallbackCtrl?.evaluate(data))
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
      @_update()

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
        @_update()
      ,delay

  _watcher: ->
    @$scope.$watch @_modelVal(), (updated,old) =>
      return if old == undefined
      @_update()
  _specificTypes: ['radio','date','checkbox','hidden']
  _factory:       -> @_options().factory
  _options:       -> @$scope.$eval(@$attrs.mrOptions || '{}')
  _type:          -> @$attrs.type?.toLowerCase()
  _tagName:       -> @$element[0].tagName
  _modelName:     -> @$attrs.ngModel
  _modelVal:      -> @$parse(@$attrs.ngModel)
  _isInput:       -> @_tagName() == 'INPUT'
  _funcName: ->
    return 'textarea' if @_tagName() == 'TEXTAREA'
    return (@_specificTypes.intersection([@_type()])[0] || 'text') if @_isInput()
    'other'
