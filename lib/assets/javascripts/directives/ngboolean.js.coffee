angular.module 'NgBoolean', ['Factories', 'FactoryName','RailsUpdater']

  .directive 'ngBoolean', ($injector,factoryName,RailsUpdater) ->
    restrict: 'A'
    require:  ['ngModel','?ngCallback','?ngTrackBy']

    link: (scope, element, attributes, ngControllers) ->
      updater     = RailsUpdater.new(scope,ngControllers,attributes.ngModel,attributes.ngOverride)
      element.bind 'click', ->
        updater.update(element.val())
