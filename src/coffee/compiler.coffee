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
    when 'symbol' then form.toJsString()
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
    params.push car(rest).toJsString()
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

compileDefineVariable = (form, indent) ->
  variable = cadr(form).toJsString()
  value = compileForm caddr(form), indent
  space = genIndentSpace indent
  """
#{space}var #{variable} = #{value.lstrip()}
  """

compileIf = (form, indent) ->
  test = compileForm cadr(form), indent + 1
  consequent = compileForm caddr(form), indent + 1
  alternative = compileForm cadddr(form), indent + 1

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
