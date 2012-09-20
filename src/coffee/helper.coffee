util = require 'util'

root = global

root.pmsg = (fmt, args...) ->
  val = util.format fmt, args...
  process.stdout.write val

root.perror = (fmt, args...) ->
  val = util.format fmt, args...
  process.stderr.write val

root.plog = (fmt, args...) ->
  val = util.format fmt, args...
  util.log val

root.xperror = (fmt, args...) ->
  perror(fmt, args...)
  process.exit()

root.isTaggedList = (el, tag) ->
  el.isPair() and el.car.isSymbol() and el.car.value is tag

root.car = (el) -> if el.isPair() then el.car else LispNil
root.cdr = (el) -> if el.isPair() then el.cdr else LispNil
root.cadr = (el) -> car cdr el
root.cddr = (el) -> cdr cdr el
root.caar = (el) -> car car el
root.cdar = (el) -> cdr car el
root.caadr = (el) -> car car cdr el
root.cdadr = (el) -> cdr car cdr el
root.caddr = (el) -> car cdr cdr el
root.cdddr = (el) -> cdr cdr cdr el
root.caaar = (el) -> car car car el
root.cdaar = (el) -> cdr car car el
root.cadar = (el) -> car cdr car el
root.cddar = (el) -> cdr cdr car el
root.caaaar = (el) -> car car car car el
root.caaadr = (el) -> car car car cdr el
root.caadar = (el) -> car car cdr car el
root.caaddr = (el) -> car car cdr cdr el
root.cadaar = (el) -> car cdr car car el
root.cadadr = (el) -> car cdr car cdr el
root.caddar = (el) -> car cdr cdr car el
root.cadddr = (el) -> car cdr cdr cdr el
root.cdaaar = (el) -> cdr car car car el
root.cdaadr = (el) -> cdr car car cdr el
root.cdadar = (el) -> cdr car cdr car el
root.cdaddr = (el) -> cdr car cdr cdr el
root.cddaar = (el) -> cdr cdr car car el
root.cddadr = (el) -> cdr cdr car cdr el
root.cdddar = (el) -> cdr cdr cdr car el
root.cddddr = (el) -> cdr cdr cdr cdr el

String::strip = -> if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""
String::lstrip = -> @replace /^\s+/g, ""
String::rstrip = -> @replace /\s+$/g, ""