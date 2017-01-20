# //= require material_raingular/directives/create/directive
# //= require material_raingular/helpers/ng_model_parse
class MrCreateModel extends AngularLinkModel
  @inject(
    '$injector'
    '$timeout'
    'factoryName'
    '$parse'
  )

  initialize: ->
    @$element.bind 'click', @create
    @CallbackCtrl = @$controller
  create: ($event) =>
    factory = @_parentFactory()?['create_' + @_modelName().singularize()] || @_factory().create
    factory @_params(), (data) =>
      @CallbackCtrl.evaluate(data) if @CallbackCtrl
      @$timeout =>
        if @_isCollection()
          @_models().last().push(data)
        else
          @_parentModel()[@_modelName()] = data

  #Private
  _modelPieces: ->
    Helpers.NgModelParse(@$attrs.mrCreate,@$scope)
  _models: ->
    models = [@$scope]
    for piece,index in @_modelPieces()
      models.push @$parse(piece)(models[index])
    models
  _modelName: ->
    @$attrs.mrModelName || @_modelPieces().last()
  _model: ->
    @_models().last()
  _parentModelName: ->
    @_modelPieces()[@_modelPieces().length - 2]
  _parentModel: ->
    @_models()[@_models().length - 2]
  _factory: ->
    @$injector.get @factoryName(@_modelName()).singularize()
  _parentFactory: ->
    return unless @_parentModelName()
    @$injector.get @factoryName(@_parentModelName()).singularize()
  _params: ->
    params={}
    params[@_modelName().singularize()] = {}
    if @_parentModelName()
      params[@_modelName().singularize()][@_parentModelName().singularize() + '_id'] = @_parentModel().id
      params[@_parentModelName().singularize() + '_id'] = @_parentModel().id
    params
  _isCollection: ->
    @_modelName().pluralize() == @_modelName()
  @register(Directives.MrCreate)
