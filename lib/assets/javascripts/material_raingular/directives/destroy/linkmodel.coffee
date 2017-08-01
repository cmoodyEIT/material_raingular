# //= require material_raingular/directives/destroy/directive
class MrDestroyModel extends AngularLinkModel
  REPEAT_TYPES: ['ng-repeat','ng-repeat-start','md-virtual-repeat']
  REGEXP: /^\s*(.*?)\s+in\s+(.*?)(?:\s+track\s+by\s+([\s\S]+?))?$/
    # 1: model name
    # 2: collection name
    # 3: track by value
  @inject(
    '$parse'
    'factoryName'
    '$timeout'
  )
  initialize: ->
    @_setForm()
    @$element.bind 'click', @destroy
    @_resourcify()
  @register(Directives.MrDestroy)
  _resourcify: ->
    ActiveRecord.$Resource._resourcify(@_model(),@_factory())

  destroy: =>
    return if @$attrs.disabled || @form.disabled
    @_resourcify()
    @$timeout => @_list().drop(@_model())
    factory = @$injector.get(@_options().factory || @factoryName(@_matchedExpression()[1]))
    @_model().$destroy @_callBack

  _callBack: (data)   => @$controller[1]?.evaluate(data)
  _model:             -> @$controller[0].$viewValue
  _list:              -> @_options().list || @$scope.$eval(@_matchedExpression()[2].split('|')[0])
  _options:           -> @$scope.$eval(@$attrs.mrOptions || '{}')
  _factory:           -> @_options().factory || @_matchedExpression()[1].classify()
  _matchedExpression: -> @_repeatStatement().match(@REGEXP)
  _repeatStatement:   -> (@REPEAT_TYPES.map (type) => @_repeatElement().getAttribute(type)).$inject('|')
  _repeatElement: ->
    repeatElement = @$element[0]
    until (@REPEAT_TYPES.map (type) => repeatElement.hasAttribute(type)).$inject('|')
      repeatElement = repeatElement.parentElement
      break if !repeatElement
    repeatElement
  _setForm: ->
    @form = @$element[0]
    until @form.nodeName == 'FORM' || !@form
      @form = @form.parentNode
      break if !@form
    @form ||= @$element[0]
