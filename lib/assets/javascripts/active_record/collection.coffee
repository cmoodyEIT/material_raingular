class ActiveRecord.$Collection extends Array
  @isCollection: (obj) ->
    return true if (obj instanceof @)
    return false unless (obj instanceof Array)
    return true if obj.$activeCollection
    obj.$activeCollection = !!obj.reduce(((a,b) -> a?.$activeRecord || b?.$activeRecord),false)
    return obj.$activeCollection

  $activeCollection: true
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
    return @
