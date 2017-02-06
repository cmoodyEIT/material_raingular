class ActiveRecord.$Resource extends Module
  @include AngularInjectableModel
  constructor: (@$promise,callback,error,@_options) ->
    @$activeRecord = true
    @_options ||= {}
    @$resolved = false
    @$inject('$paramSerializer','$http','$q','$timeout','$rootScope')
    @$promise?.then(@$processResponse.bind(@)).then(callback,error)
  $updatingKeys: []
  $activeRecord: true
  @initialize: (resource,options) ->
    record = new @(null,null,null,options)
    record.$processResponse(data: resource)
    return record
  @_resourcify: (obj,klass) ->
    return if obj.$activeRecord
    record = @initialize(obj,{klass: klass})
    obj[key] = val for key,val of record

  $deferProcessResponse: (response) ->
    promise = @$timeout => @$processResponse.bind(@)(response,true)
    return promise

  $processResponse: (response,apply) ->
    @$resolved = true
    for key,val of response.data
      @[key] = val if @[key] == @['$' + key + '_was'] || key in @$updatingKeys
      @['$' + key + '_was'] = val unless key[0] in ['$','_']
    @$updatingKeys = []
    return response.data

  _defaultWrap: -> @_options.klass.underscore()
  _defaultPath: -> '/' + @_options.klass.tableize() + '/:id'
  $updateUrl:  ->
    path = @_options.updateUrl || @_defaultPath()
    path = path.replace(':id', @.id || '').replace(/\/$/,'')
    path += '.json' unless path.match(/\.json$/)
    path
  $destroyUrl: ->
    path = @_options.destroyUrl || @_defaultPath()
    path = path.replace(':id', @.id)
    path += '.json' unless path.match(/\.json$/)
    path
  $save: (callback,error)->
    if @$promise
      @$promise = @$promise.then(@_save.bind(@)).then(callback,error) if (@$promise.$$state.status != 0 || !@$resolved)
    else
      @$promise = @_save.bind(@)().then(callback,error)
  _save: ->
    res = @$paramSerializer.update(@)
    unless Object.keys(res).length > 0
      defer = @$q.defer()
      defer.resolve(@)
      return defer.promise
    @$updatingKeys = Object.keys(res)
    method = if @.id then 'put' else 'post'
    params = {}
    params[@_options.paramWrapper || @_defaultWrap()] = if @.id then @$paramSerializer.update(@) else @$paramSerializer.create(@)
    @["$" + key + "_was"] = val for key,val of res
    return @$http[method](@$updateUrl(),params).then(@$deferProcessResponse.bind(@))
  $destroy: (callback,error)->
    @$promise.$$state.status = 0
    @$promise = @_destroy().then(callback,error)
  _destroy: =>
    return @$http.delete(@$destroyUrl()).then(@$processResponse.bind(@))
