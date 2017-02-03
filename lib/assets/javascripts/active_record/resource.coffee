class ActiveRecord.$Resource extends Module
  @include AngularInjectableModel
  constructor: (@$promise,callback,error,@_updateUrl,@_destroyUrl) ->
    @$resolved = false
    @$inject('$paramSerializer','$http','$q')
    @$promise?.then(@$processResponse).then(callback,error)
  $updatingKeys: []
  $activeRecord: true
  @initialize: (resource,update_url,destroy_url) ->
    record = new @(null,null,null,update_url,destroy_url)
    record.$processResponse(data: resource)
    return record
  $processResponse: (response) =>
    @$resolved = true
    for key,val of response.data
      @[key] = val if @[key] == @['$' + key + '_was'] || key in @$updatingKeys
      @['$' + key + '_was'] = val
    @$updatingKeys = []
    return response.data
  $updateUrl:  ->
    path = @_updateUrl.replace(':id', @.id)
    path += '.json' unless path.match(/\.json$/)
    path
  $destroyUrl: ->
    path = @_destroyUrl.replace(':id', @.id)
    path += '.json' unless path.match(/\.json$/)
    path
  $save: (callback,error)->
    if @$promise
      @$promise = @$promise.then(@_save.bind(@)).then(callback,error) if (@$promise.$$state.status != 0 || !@$resolved)
    else
      @$promise = @_save().then(callback,error)
  _save: ->
    res = @$paramSerializer.strip(@)
    unless Object.keys(res).length > 0
      defer = @$q.defer()
      defer.resolve(@)
      return defer.promise
    @$updatingKeys = Object.keys(res)
    method = if @.id then 'put' else 'post'
    return @$http[method](@$updateUrl(),@$paramSerializer.strip(@)).then(@$processResponse)
  $destroy: (callback,error)->
    @$promise = (if @promise then @$promise.then(@_destroy) else @_destroy()).then(callback,error)
  _destroy: =>
    return @$http.delete(@$destroyUrl()).then(@$processResponse)
