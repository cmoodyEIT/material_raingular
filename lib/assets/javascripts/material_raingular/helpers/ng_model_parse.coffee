REGEXP = /(.+)(?:\.(.+)|\[(.+)?\])/
@Helpers ?= {}
class Helpers.NgModelParse
  constructor: (@model,@$scope) ->
    parsed = []
    returned = @model.match(REGEXP) || [null,@model]
    for res,index in returned.slice(1,3)
      res ||= @$scope.$eval(returned[3])
      parsed.merge(if returned[0] then Helpers.NgModelParse(res,@$scope) else [res])
    return parsed
