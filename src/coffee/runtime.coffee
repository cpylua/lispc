root = global
local = {}

local.lispMultiply = (args...) ->
  result = 1
  for obj in args
    result *= obj.value
  LispFloat.create result

local.lispGreaterThan = (x, y) ->
  LispBoolean.create x.value > y.value

local.lispDisplay = (args...) ->
  for obj in args
    obj.display()
  LispNil

local.lispWrite = (args...) ->
  for obj in args
    obj.write()
  LispNil


# export runtime primitives
getCompilerSymbol = (sym) -> LispSymbol.create(sym).toJsString()

lispFunctions = {
  'lispMultiply': '*'
  'lispGreaterThan': '>'
  'lispDisplay': 'display'
  'lispWrite': 'write'
}

root.setupLispRuntime = ->
  for k, v of lispFunctions
    root[getCompilerSymbol v] = local[k]
