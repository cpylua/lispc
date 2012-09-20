root = global

root.compile = (ast) ->
  (compileForm(form, 0) + ";" for form in ast).join '\n\n'

compileForm = (form, indent) ->
  switch form.type
    when 'boolean', 'character', 'integer', 'float', 'string', 'nil'
      "#{form.toJsString()}"
    when 'symbol' then compileSymbol form
    when 'pair' then compileCompound form, indent

compileCompound = (form, indent) ->
  if isTaggedList form, 'if'
    code = compileIf form, indent
    "#{code}"

compileIf = (form, indent) ->
  test = compileForm cadr(form), indent + 1
  consequent = compileForm caddr(form), indent + 2 
  alternative = compileForm cadddr(form), indent + 2

  sym = genVariable 'iftest'
  code = """
(function() {
  var #{sym} = #{test.lstrip()};
  if (#{sym} === false) {
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
