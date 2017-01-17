REGEXP = /(.+)(?:\.(.+)|\[(.+)?\])/
@Helpers ?= {}
class Helpers.NgModelParse
  constructor: (@model,@$scope) ->
    parsed = @model.match(REGEXP)
    return [parsed[1], parsed[2] || @$scope.$eval(parsed[3])]
