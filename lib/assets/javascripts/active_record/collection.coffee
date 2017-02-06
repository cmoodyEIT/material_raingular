class ActiveRecord.$Collection extends Array
  $inject: (args...) ->
    @$injector ||= angular.element(document.body).injector()
    @[item] = @$injector.get(item) for item in args
  constructor: (@$promise,callback,error,@options) ->
    @$resolved = false
    @$inject('$paramSerializer')
    @$promise?.then(@$processResponse).then(callback,error)
  $processResponse: (response)=>
    for item in response.data
      @.push(ActiveRecord.$Resource.initialize(item,@options))
    @$resolved = true
    return response.data
