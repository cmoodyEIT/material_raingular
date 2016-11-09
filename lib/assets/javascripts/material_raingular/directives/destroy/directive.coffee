class Directives.MrDestroy extends AngularDirective
  restrict: 'A'
  require: ['ngModel','?mrCallback']
  @register(MaterialRaingular.app)
