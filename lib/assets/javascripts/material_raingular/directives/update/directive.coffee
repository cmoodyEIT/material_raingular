class Directives.MrUpdate extends AngularDirective
  restrict: 'A'
  require:  ['ngModel','?mrCallback','?ngTrackBy']
  @register(MaterialRaingular.app)
