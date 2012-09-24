root = global

root.compile = (ast) ->
  (compileForm(form, 0) + ";" for form in ast).join '\n\n'

compileForm = (form, indent) ->
  space = genIndentSpace indent
  switch form.type
    when 'boolean' then "#{space}LispBoolean.create(#{form.toJsString()})"
    when 'character' then "#{space}LispCharacter.create(#{form.toJsString()})"
    when 'string' then "#{space}LispString.create(#{form.toJsString()})"
    when 'integer' then "#{space}LispInteger.create(#{form.toJsString()})"
    when 'float' then "#{space}LispFloat.create(#{form.toJsString()})"
    when 'nil' then "#{space}LispNil"
    when 'symbol' then "#{space}#{form.toJsString()}"
    when 'pair' then compileCompound form, indent

compileCompound = (form, indent) ->
  if isTaggedList form, 'if'
    compileIf form, indent
  else if isTaggedList form, 'define'
    compileDefine form, indent
  else if isTaggedList form, 'begin'
    compileBegin form, indent
  else if isTaggedList form, 'lambda'
    compileLambda form, indent
  else if isTaggedList form, 'let'
    compileLet form, indent
  else
    compileFuncall form, indent

compileFuncall = (form, indent) ->
  fn = compileForm car(form), indent + 1
  outspace = genIndentSpace indent
  inspace = genIndentSpace indent + 1
  sym = genVariable "args"
  args = compileValues cdr(form), indent + 2
  """
#{outspace}(function(){
#{inspace}#{sym} = [
#{args.join ",\n"}
#{inspace}];
#{inspace}return #{fn.lstrip()}.apply(this, #{sym});
#{outspace}}).call(this)
  """

compileValues = (args, indent) ->
  rest = args
  values = []
  while rest.isPair()
    values.push compileForm car(rest), indent
    rest = cdr rest
  values

compileLet = (form, indent) ->
  clauses = cadr form
  body = cddr form
  formals = getClauseFormals clauses
  values = getClauseValues clauses
  fn = makeLambda formals, body
  funcall = makeFuncall fn, values
  compileFuncall funcall, indent

mapClauses = (clauses, fn) ->
  rest = clauses
  result = []
  while rest.isPair()
    result.push fn.call null, rest
    rest = cdr rest
  # convert to pairs
  list = LispNil
  len = result.length - 1
  for i in [0..len]
    list = LispPair.create result[len - i], list
  list

getClauseFormals = (clauses) ->
  mapClauses clauses, caar

getClauseValues = (clauses) ->
  mapClauses clauses, cadar

makeFuncall = (fn, args) ->
  LispPair.create fn, args

compileLambda = (form, indent) ->
  params = getParams cadr form
  expressions = makeBegin cddr form
  space = genIndentSpace indent
  """
#{space}(function() {
#{space}  return function(#{params}) {
#{compileBegin expressions, indent + 2};
#{space}  };
#{space}}).call(this)
  """

getParams = (formals) ->
  params = []
  rest = formals
  while rest.isPair()
    params.push car(rest).toJsString().strip()
    rest = cdr rest
  params.join ", "

makeBegin = (exprs) ->
  tag = LispSymbol.create "begin"
  LispPair.create tag, exprs

compileBegin = (form, indent) ->
  sequences = cdr form
  codes = []
  while sequences.isPair()
    codes.push compileForm car(sequences), indent + 1
    sequences = cdr sequences
  idx = codes.length - 1
  rest = codes[...idx]
  last = codes[idx]
  space = genIndentSpace indent
  if rest.length > 0
    codes = """
#{space}(function() {
#{rest.join ';\n'};
#{space}  return #{last.lstrip()};
#{space}}).call(this)
    """
  else
    codes = """
#{space}(function() {
#{space}  return #{last.lstrip()};
#{space}}).call(this)
    """

compileDefine = (form, indent) ->
  if cdddr(form) is LispNil and cadr(form).isSymbol()
    compileDefineVariable form, indent
  else if cadr(form).isPair() and cddr(form) isnt LispNil
    compileDefineFunction form, indent

compileDefineFunction = (form, indent) ->
  fn = caadr form
  formals = cdadr form
  exprs = cddr form
  tform = makeDefineVar fn, LispPair.create makeLambda(formals, exprs), LispNil
  compileForm tform, indent

makeLambda = (formals, exprs) ->
  lambda = LispSymbol.create 'lambda'
  LispPair.create lambda, LispPair.create formals, exprs

makeDefineVar = (variable, lambda) ->
  define = LispSymbol.create 'define'
  LispPair.create define, LispPair.create variable, lambda

compileDefineVariable = (form, indent) ->
  variable = cadr(form).toJsString()
  value = compileForm caddr(form), indent
  space = genIndentSpace indent
  """
#{space}var #{variable.lstrip()} = #{value.lstrip()}
  """

compileIf = (form, indent) ->
  test = compileForm cadr(form), indent + 1
  consequent = compileForm caddr(form), indent + 2
  alternative = compileForm cadddr(form), indent + 2

  sym = genVariable 'iftest'
  space = genIndentSpace indent
  code = """
#{space}(function() {
#{space}  var #{sym} = #{test.lstrip()};
#{space}  if (#{sym} === LispFalse) {
#{space}    return #{consequent.lstrip()};
#{space}  } else {
#{space}    return #{alternative.lstrip()};
#{space}  }
#{space}}).call(this)
"""

genVariable = (prefix, n = 5) ->
  choices = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  len = choices.length
  sym = "__#{prefix}_"
  for i in [0...n]
    idx = Math.floor Math.random() * len
    sym = "#{sym}#{choices.charAt(idx)}"
  "#{sym}__"

genIndentSpace = (level, space = "  ") ->
  result = ""
  for i in [0...level]
    result += space
  result
