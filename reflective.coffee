object =
  extend: (fields) ->
    o = (fields) -> arguments.callee.extend fields
    o[n] = v for n,v of this
    o[n] = v for n,v of fields
    o

Reflective = {}

Reflective.object = object.extend
  clone: -> do @extend

Reflective.library = Reflective.object
  exportables: {}
  withExports: (l) ->
    x = @exportables
    x[n] = 1 for n in l
    x
  getExports: () ->
    exports = {}
    adapt = (m, l) ->
      # adapt a library method into a public function
      () -> m.apply l, arguments
    for f of @exportables
      exports[f] = adapt @[f], @
    exports

exports.Reflective = Reflective
