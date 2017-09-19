class $paramSerializer extends AngularServiceModel
  @register(MaterialRaingular.app)
  @inject('$httpParamSerializer')
  clean: (obj) -> @$httpParamSerializer @update(obj)
  update: (obj) ->
    res = {}
    for key,val of @strip(obj)
      continue if val == obj['$' + key + '_was']
      continue if val?.toString() == obj['$' + key + '_was']?.toString()
      continue if [undefined,null].includes(val) && [undefined,null].includes(obj["$#{key}_was"])
      continue if ActiveRecord.$Collection.isCollection(val)
      res[key] = val
    res
  strip: (obj) ->
    res = {}
    for key,val of obj
      continue if ['$','_'].includes(key[0]) || key in ['constructor','initialize']
      continue if ActiveRecord.$Collection.isCollection(val)
      res[key] = if (typeof val == 'object' && val != null && !val instanceof Date) then @strip(val) else val
    res
  create: (obj) ->
    res = {}
    for key,val of @strip(obj)
      continue unless val
      res[key] = val
    res
