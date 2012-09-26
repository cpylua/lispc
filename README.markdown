Lisp => JavaScript compiler
===========

The Lisp languange here is a subset of Scheme. This project is
not meant to be a complete compiler for Scheme. Some primitive
functions are missing, and I won't implement them all.

Instructions
---------------

    cake build
    node lispc.js source.lisp target.js

Example
-----------

Here is a factorial function:

    (define (fact n)
      (if (< n 2)
        1
        (* n (fact (- n 1)))))

Compiles to(I know it's ugly...):

    var __fact__ = (function() {
      var __lambda_lzM2t__ = function(__n__) {
        return (function() {
          return (function() {
            var __iftest_jxQNg__ = (function(){
              __args_YVoW4__ = [
                __n__,
                LispInteger.create(2)
              ];
              return __$$lessthan$$__.value.apply(this, __args_YVoW4__);
            }).call(this);
            if (__iftest_jxQNg__ !== LispFalse) {
              return LispInteger.create(1);
            } else {
              return (function(){
                __args_kZlou__ = [
                  __n__,
                  (function(){
                    __args_bNG75__ = [
                      (function(){
                        __args_ru6Cs__ = [
                          __n__,
                          LispInteger.create(1)
                        ];
                        return __$$minus$$__.value.apply(this, __args_ru6Cs__);
                      }).call(this)
                    ];
                    return __fact__.value.apply(this, __args_bNG75__);
                  }).call(this)
                ];
                return __$$asterisk$$__.value.apply(this, __args_kZlou__);
              }).call(this);
            }
          }).call(this);
        }).call(this);
      };
      return LispLambda.create(__lambda_lzM2t__);
    }).call(this);
