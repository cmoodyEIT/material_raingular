angular.module 'NgBoolean', ['Factories', 'FactoryName','RailsUpdater']

  .directive 'ngBoolean', ($injector,factoryName,RailsUpdater) ->
    restrict: 'A'
    require:  ['ngModel','?ngCallback','?ngTrackBy']

    link: (scope, element, attributes, ngControllers) ->
      updater     = RailsUpdater.new(scope,ngControllers,attributes.ngModel,attributes.ngOverride)
      element.bind 'click', ->
        if element[0].tagName == 'INPUT'
          updater.update(element.val())
        else
          bool = !ngControllers[0].$modelValue
          updater.update(bool)
          ngControllers[0].$setViewValue(bool)
