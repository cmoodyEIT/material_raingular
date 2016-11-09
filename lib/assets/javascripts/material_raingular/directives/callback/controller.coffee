class DirectiveModels.MrCallbackModel extends AngularDirectiveModel
  @inject(
    '$attrs'
    '$parse'
    '$scope'
  )
  evaluate: (returnData)->
    for callback in @$attrs.mrCallback.split(';')
      [match,func,args] = callback.match(/(.*)\((.*)\)/)
      data = []
      if !!args
        for arg in args.split(',')
          data.push @$scope.$eval(arg)
      data.push returnData
      callbackFunc = @$parse(func)(@$scope) || @$parse(func)(window)
      callbackFunc(data...)
