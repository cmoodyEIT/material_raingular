# //= require material_raingular/directives/destroy/directive
class MrDestroyModel extends AngularLinkModel
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
  @register(Directives.MrDestroy)

  destroy: =>
    return if @$attrs.disabled || @form.disabled
    @$timeout =>
      @_list().drop(@_model())
    factory = @$injector.get(@_options().factory || @factoryName(@_matchedExpression()[1]))
    factory.destroy {id: @_model().id}, @_callBack

  _callBack: (data)   => @$controller[1]?.evaluate(data)
  _model:             -> @$controller[0].$viewValue
  _list:              -> @_options().list || @$scope.$eval(@_matchedExpression()[2].split('|')[0])
  _options:           -> @$scope.$eval(@$attrs.mrOptions || '{}')
  _matchedExpression: -> @_repeatElement().getAttribute('ng-repeat').match(@REGEXP)
  _repeatElement: ->
    repeatElement = @$element[0]
    until repeatElement.hasAttribute 'ng-repeat'
      repeatElement = repeatElement.parentNode
      break if !repeatElement
    repeatElement
  _setForm: ->
    @form = @$element[0]
    until @form.nodeName == 'FORM' || !@form
      @form = @form.parentNode
      break if !@form
    @form ||= @$element[0]
