parser = require './parser'

root = global

class LispObject
  isBoolean: -> false
  isCharacter: -> false
  isString: -> false
  isSymbol: -> false
  isInteger: -> false
  isFloat: -> false
  isNumber: -> @isInteger() or @isFloat()
  isPair: -> false
  isNil: -> false
  write: -> pmsg "%s", @toWriteString()

# boolean
class LispBoolean extends LispObject
  constructor: (@value) -> @type = 'boolean'
  isBoolean: -> true

  toString: ->
    s = if @value then "#t" else "#f"
    "#:LispBoolean[#{s}]"

  toWriteString: -> if @value then '#t' else '#f'

  toJsString: -> if @value then 'true' else 'false'

  display: -> @write()

  @create: (val) -> if val then LispTrue else LispFalse

root.LispTrue = new LispBoolean true
root.LispFalse = new LispBoolean false

# character
class root.LispCharacter extends LispObject
  constructor: (@value) -> @type = 'character'
  isCharacter: -> true

  escape: ->
    s = @value
    switch s
      when ' ' then s = 'space'
      when '\t' then s = 'tab'
      when '\n' then s ='newline' 
    s  

  toString: -> "#:LispCharacter[#\\#{@escape()}]"

  toWriteString: -> "#\\#{@escape()}"

  toJsString: ->
    switch @value
      when '\t' then '"\\t"'
      when '\n' then '"\\n"'
      when '"' then '"\\""'
      when '\\' then '"\\\\"'
      else "\"#{@value}\""

  display: -> pmsg "%s", @value

  @create: (val) -> new LispCharacter val

# string
class root.LispString extends LispObject
  constructor: (@value) -> @type = 'string'
  isString: -> true

  toString: -> "#:LispString[#{@value}]"

  toWriteString: ->
    s = @value.replace '\\', '\\\\'
    s = s.replace '"', '\\"'
    s = s.replace '\n', '\\n'
    s = s.replace '\r\n', '\\n'
    s = s.replace '\r', '\\n'
    s = s.replace '\t', '\\t'
    "\"#{s}\""

  toJsString: -> @toWriteString()

  display: -> pmsg "%s", @value

  @create: (val) -> new LispString val

# symbol
class root.LispSymbol extends LispObject
  constructor: (@value) -> @type = 'symbol'
  isSymbol: -> true

  toString: -> "#:LispSymbol[#{@value}]"

  toWriteString: -> @value

  toJsString: -> @value

  display: -> @write()

  @quote: new LispSymbol 'quote'
  @quasiquote: new LispSymbol 'quasiquote'
  @unquote: new LispSymbol 'unquote'
  @unquote_splicing: new LispSymbol 'unquote-splicing'

  @create: (val) ->
    switch val
      when 'quote' then LispSymbol.quote
      when 'quasiquote' then LispSymbol.quasiquote
      when 'unquote' then LispSymbol.unquote
      when 'unquote-splicing' then LispSymbol.unquote_splicing
      else new LispSymbol val

# number
class root.LispInteger extends LispObject
  constructor: (@value) -> @type = 'integer'
  isInteger: -> true

  toString: -> "#:LispNumber[Integer:#{@value}]"

  toWriteString: -> "#{@value}"

  toJsString: -> @toWriteString()

  display: -> @write()

  @create: (val) -> new LispInteger val

class root.LispFloat extends LispObject
  constructor: (@value) -> @type = 'float'
  isFloat: -> true

  toString: -> "#:LispNumber[Float:#{@value}]"

  toWriteString: -> "#{@value}"

  toJsString: -> @toWriteString()

  display: -> @write()

  @create: (val) -> new LispFloat val

# list
class LispNil extends LispObject
  constructor: -> @type = 'nil'; @value = null
  isNil: -> true

  toString: -> '#:LispNil'

  toWriteString: -> "()"

  toJsString: -> "null"

  display: -> @write()

root.LispNil = nil = new LispNil()

class root.LispPair extends LispObject
  constructor: (@car, @cdr) -> @type = 'pair'
  isPair: -> true

  toString: -> "#:LispPair[CAR:#{@car}, CDR:#{@cdr}]"

  toWriteString: ->
    rest = @
    content = []
    while rest.isPair()
      for t, abbre of LispPair.tags
        if isTaggedList rest, t
          cdr = rest.cdr.car.toWriteString() # cdr.car is guaranteed available
          content.push "#{abbre}#{cdr}"
          return content.join ' '
      first = rest.car
      rest = rest.cdr
      content.push first.toWriteString()
    # check for dotted-pair
    content.splice content.length, 0, '.', rest.toWriteString() unless rest.isNil()
    "(#{content.join ' '})"

  display: -> @write()

  @create: (car, cdr) -> new LispPair car, cdr

  @tags: {
    quote: "'"
    quasiquote: '`'
    unquote: ','
    "unquote-splicing": ',@'
  }

# reader
root.read = (prg) ->
  parseAST ast for ast in parser.parse prg

parseAST = (ast) ->
  return parseASTAtom ast unless Array.isArray ast
  len = ast.length
  if len > 2 and isDot ast[len - 2]
    parseASTRec ast, len - 3, parseAST ast[len - 1]
  else
    parseASTRec ast, len - 1, nil

parseASTRec = (ast, pos, accu) ->
  while pos >= 0
    car = parseAST ast[pos]
    accu = new LispPair car, accu
    pos = pos - 1
  accu

parseASTAtom = (atom) ->
  val = atom.value
  switch atom.type
    when 'boolean' then LispBoolean.create val
    when 'character' then LispCharacter.create val
    when 'string' then LispString.create val
    when 'integer' then LispInteger.create val
    when 'float' then LispFloat.create val
    when 'symbol' then LispSymbol.create val

isDot = (el) -> el.type is 'dot'
