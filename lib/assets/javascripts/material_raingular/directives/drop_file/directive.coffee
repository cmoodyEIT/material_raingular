class Directives.MrDropFile extends AngularDirective
  restrict: 'A'
  require:  ['ngModel','?mrCallback']
  @register(MaterialRaingular.app)
