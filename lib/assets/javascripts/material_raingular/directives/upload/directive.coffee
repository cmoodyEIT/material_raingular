class Directives.MrUpload extends AngularDirective
  restrict: 'E'
  replace: true
  require:  ['ngModel','?mrCallback']
  template: (element,attributes) ->
    disabled = typeof(attributes.disabled) != 'undefined'
    '<span class="mr-upload" style="outline: none">
      <div class="mr-progress-bar">
        <span class="bar" style="width: {{progress || 0}}%;"></span><span class="text" style="margin-left: -{{uploadProgress() || 0}}%;">{{uploadProgress()}}%</span>
      </div>
      <input accept="{{accept()}}" ng-model="ngModel" type="file" ng-class="{image: fileUploadShow(\'image\')}" ' + (if disabled then 'disabled ' else '') + '/>
      <img ng-show="fileUploadShow(\'image\')" ng-src="{{fileData().thumb}}" />
      <div class="button" ng-show="fileUploadShow(\'button\')">
        Select File
      </div>
      <a download="" href="{{fileData().path}}" ng-show="fileUploadShow(\'text\')" target="_blank">{{fileData().name}}</a></span>'
  @register(MaterialRaingular.app)
