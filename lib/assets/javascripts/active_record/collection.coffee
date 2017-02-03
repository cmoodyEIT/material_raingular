class ActiveRecord.$Collection extends Array
  $inject: (args...) ->
    @$injector ||= angular.element(document.body).injector()
    @[item] = @$injector.get(item) for item in args
  constructor: (@$promise,callback,error,@update_url,@destroy_url) ->
    @$resolved = false
    @$inject('$paramSerializer')
    @$promise?.then(@$processResponse).then(callback,error)
  $processResponse: (response)=>
    for item in response.data
      @.push(ActiveRecord.$Resource.initialize(item,@update_url,@destroy_url))
    @$resolved = true
    return response.data
