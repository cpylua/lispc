root = global
local = {}

local.lispMultiply = (args...) ->
  result = 1
  for obj in args
    result *= obj.value
  LispFloat.create result

local.lispPlus = (args...) ->
  result = 0
  for obj in args
    result += obj.value
  LispFloat.create result

local.lispMinus = (args...) ->
  if args.length is 1
    return -args.value
  result = args[0].value
  for obj in args[1..]
    result -= obj.value
  LispFloat.create result

local.lispGreaterThan = (x, y) ->
  LispBoolean.create x.value > y.value

local.lispLessThan = (x, y) ->
  LispBoolean.create x.value < y.value

local.lispDisplay = (args...) ->
  for obj in args
    obj.display()
  LispNil

local.lispNewline = ->
  LispString.create("\n").display()
  LispNil

local.lispWrite = (args...) ->
  for obj in args
    obj.write()
  LispNil

local.lispCons = (car, cdr) ->
  LispPair.create car, cdr

local.lispCar = car
local.lispCdr = cdr
local.lispCadr = cadr
local.lispCddr = cddr
local.lispCaar = caar
local.lispCdar = cdar
local.lispCaadr = caadr
local.lispCdadr = cdadr
local.lispCaddr = caddr
local.lispCdddr = cdddr
local.lispCaaar = caaar
local.lispCdaar = cdaar
local.lispCadar = cadar
local.lispCddar = cddar
local.lispCaaaar = caaaar
local.lispCaaadr = caaadr
local.lispCaadar = caadar
local.lispCaaddr = caaddr
local.lispCadaar = cadaar
local.lispCadadr = cadadr
local.lispCaddar = caddar
local.lispCadddr = cadddr
local.lispCdaaar = cdaaar
local.lispCdaadr = cdaadr
local.lispCdadar = cdadar
local.lispCdaddr = cdaddr
local.lispCddaar = cddaar
local.lispCddadr = cddadr
local.lispCdddar = cdddar
local.lispCddddr = cddddr


# export runtime primitives
getCompilerSymbol = (sym) -> LispSymbol.create(sym).toJsString()

lispFunctions = {
  'lispMultiply': '*'
  'lispPlus': '+'
  'lispMinus': '-'
  'lispGreaterThan': '>'
  'lispLessThan': '<'
  'lispDisplay': 'display'
  'lispNewline': 'newline'
  'lispWrite': 'write'
  'lispCons': 'cons'
  "lispCar": "car"
  "lispCdr": "cdr"
  "lispCadr": "cadr"
  "lispCddr": "cddr"
  "lispCaar": "caar"
  "lispCdar": "cdar"
  "lispCaadr": "caadr"
  "lispCdadr": "cdadr"
  "lispCaddr": "caddr"
  "lispCdddr": "cdddr"
  "lispCaaar": "caaar"
  "lispCdaar": "cdaar"
  "lispCadar": "cadar"
  "lispCddar": "cddar"
  "lispCaaaar": "caaaar"
  "lispCaaadr": "caaadr"
  "lispCaadar": "caadar"
  "lispCaaddr": "caaddr"
  "lispCadaar": "cadaar"
  "lispCadadr": "cadadr"
  "lispCaddar": "caddar"
  "lispCadddr": "cadddr"
  "lispCdaaar": "cdaaar"
  "lispCdaadr": "cdaadr"
  "lispCdadar": "cdadar"
  "lispCdaddr": "cdaddr"
  "lispCddaar": "cddaar"
  "lispCddadr": "cddadr"
  "lispCdddar": "cdddar"
  "lispCddddr": "cddddr"
}

root.setupLispRuntime = ->
  for k, v of lispFunctions
    root[getCompilerSymbol v] = LispLambda.create local[k]
