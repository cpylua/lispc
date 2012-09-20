root = global

root.compile = (ast) ->
  (compileForm(form, 0) + ";" for form in ast).join '\n\n'

compileForm = (form, indent) ->
  switch form.type
    when 'boolean' then "LispBoolean.create(#{form.toJsString()})"
    when 'character' then "LispCharacter.create(#{form.toJsString()})"
    when 'string' then "LispString.create(#{form.toJsString()})"
    when 'integer' then "LispInteger.create(#{form.toJsString()})"
    when 'float' then "LispFloat.create(#{form.toJsString()})"
    when 'nil' then "LispNil"
    when 'symbol' then form.toJsString()
    when 'pair' then compileCompound form, indent

compileCompound = (form, indent) ->
  if isTaggedList form, 'if'
    compileIf form, indent
  else if isTaggedList form, 'define'
    compileDefine form, indent

compileDefine = (form, indent) ->
  if cdddr(form) is LispNil and cadr(form).isSymbol()
    compileDefineVariable form, indent
  else if cadr(form).isPair() and cddr(form) isnt LispNil
    compileDefineFunction form, indent

compileDefineVariable = (form, indent) ->
  variable = cadr(form).toJsString()
  value = compileForm caddr(form), indent
  """
var #{variable} = #{value}
  """

compileIf = (form, indent) ->
  test = compileForm cadr(form), indent + 1
  consequent = compileForm caddr(form), indent + 2 
  alternative = compileForm cadddr(form), indent + 2

  sym = genVariable 'iftest'
  code = """
(function() {
  var #{sym} = #{test.lstrip()};
  if (#{sym} === LispFalse) {
    return #{consequent.lstrip()};
  } else {
    return #{alternative.lstrip()};
  }
}).call(this)
"""
  pad = genIndentSpace indent
  (pad + line for line in code.split "\n").join "\n"

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
