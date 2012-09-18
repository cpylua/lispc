// Generated by CoffeeScript 1.3.3
(function() {
  var reader, util;

  reader = require('./reader');

  util = require('util');

  util.log(reader);

}).call(this);


// Generated by CoffeeScript 1.3.3
(function() {
  var parseOpts, perror, pmsg, usage, util,
    __slice = [].slice;

  util = require('util');

  parseOpts = function() {
    process.stdout.write("in");
    return usage();
  };

  usage = function() {
    var file;
    file = process.argv[1];
    return pmsg("Usage: node %s SOURCE [TARGET]", file);
  };

  pmsg = function() {
    var args, fmt, val;
    fmt = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    val = util.format.apply(util, [fmt].concat(__slice.call(args)));
    return process.stdout.write(val);
  };

  perror = function() {
    var args, fmt, val;
    fmt = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    val = util.format.apply(util, [fmt].concat(__slice.call(args)));
    return process.stderr.write(val);
  };

}).call(this);
