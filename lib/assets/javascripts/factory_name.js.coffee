angular.module 'FactoryName', []
  .factory 'factoryName', ->
    return (modelName) ->
      raw_factory = modelName.split('_')
      factory=[]
      for word in raw_factory
        factory.push(word.charAt(0).toUpperCase() + word.slice(1))
      factory = factory.join('')
      return factory
