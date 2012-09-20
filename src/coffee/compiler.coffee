root = global

root.compile = (ast) ->
  for e in ast
    e.write()
    pmsg "\n"
    # e.display()
    # pmsg "\n"
  "hello"
