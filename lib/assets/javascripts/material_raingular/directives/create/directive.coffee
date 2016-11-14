class Directives.MrCreate extends AngularDirective
  restrict: 'A'
  require: '?mrCallback'
  @register(MaterialRaingular.app)
