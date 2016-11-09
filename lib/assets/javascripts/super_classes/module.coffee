moduleKeywords = ['extended', 'included']
@Modules = {}
class @Module
  @extend: (obj) ->
    obj = obj.prototype || obj
    for key, value of obj when key not in moduleKeywords
      @[key] = value

    obj.extended?.apply(@)
    this

  @include: (obj) ->
    obj = obj.prototype || obj
    for key, value of obj when key not in moduleKeywords
      # Assign properties to the prototype
      @::[key] = value

    obj.included?.apply(@)
    this
