class $paramSerializer extends AngularServiceModel
  @register(MaterialRaingular.app)
  @inject('$httpParamSerializer')
  clean: (obj) -> @$httpParamSerializer @strip(obj)
  changed: (obj) ->
    res = {}
    for key,val of obj
      continue if val == obj['$' + key + '_was']
      res[key] = val
    res
  strip: (obj) ->
    res = {}
    for key,val of @changed(obj)
      continue if ['$','_'].includes(key[0]) || key in ['constructor','initialize']
      res[key] = if typeof val == 'object' && val != null then @clean(val) else val
    res
