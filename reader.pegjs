{
  function Pair(car, cdr) {
    this.car = car;
    this.cdr = cdr;
  }

  var dot = {type: 'dot'};
  var nil = {type: 'nil'};

  function _toSexp(arr, idx, accu) {
    if (idx < 0) {
      return accu;
    }

    var car = toSexp(arr[idx]);
    return _toSexp(arr, --idx, new Pair(car, accu));
  }

  // JS array to Lisp list
  function toSexp(arr) {
    if (!Array.isArray(arr)) {
      return arr;
    }

    var len = arr.length;
    if (len > 2 && arr[len - 2] === dot) {
      return _toSexp(arr, len - 3, toSexp(arr[len - 1]));
    }
    return _toSexp(arr, len - 1, nil);
  }
}

start
  = InterTokenSpace data:Data {
      return data;
    }
  / InterTokenSpace { return []; }

Data
  = data:(Datum InterTokenSpace)+ {
      return data.map(function (t) {
        var d = t[0];
        return Array.isArray(d) ? toSexp(d) : d;
      });
    }

Token
  = Keyword
  / Variable
  / Boolean
  / Character
  / String
  / Number

LineTerminator
  = [\n\r]

Comment
  = ";" (!LineTerminator .)*

WhiteSpace
  = [ \t\n\r]

_ "whitespace"
  = WhiteSpace+

Atomosphere
  = _
  / Comment

InterTokenSpace
  = Atomosphere* { return "" }

Delimiter
  = _
  / [()";]
  / !.+   /* End of input */

Identifier
  = first:Initial rest:Subsequent* {
      return first + rest.join("");
    }
  / PeculiaIdentifier

Initial
  = Letter
  / SpecialInitial

Letter
  = [a-zA-Z]

SpecialInitial
  = [!$%&*/:<=>?\^_~]

Subsequent
  = Initial
  / Digit
  / SpecialSubsequent

SpecialSubsequent
  = [+\-\.@]

PeculiaIdentifier
  = [+\-]

Keyword
  = keyword:(SyntacticKeyword &Delimiter) {
      return {type: 'symbol', value: keyword[0]};
    }

SyntacticKeyword
  = ExpressionKeyword
  / 'else'i
  / 'define'i
  / 'unquote-splicing'i
  / 'unquote'i

ExpressionKeyword
  = 'quote'i
  / 'lambda'i
  / 'if'i
  / 'set!'i
  / 'begin'i
  / 'cond'i
  / 'and'i
  / 'or'i
  / 'case'i
  / 'letrec'i
  / 'let*'i
  / 'let'i
  / 'do'i
  / 'delay'i
  / 'quasiquote'i

Variable
  = !Keyword identifier:Identifier &Delimiter {
      return { type: 'symbol', value: identifier};
    }

Boolean
  = '#t' &Delimiter {
      return {type: 'boolean', value: true};
    }
  / '#f' &Delimiter {
      return {type: 'boolean', value: false};
    }

Character
  = '#\\' val: CharacterName &Delimiter {
      return {type: 'character', value: val};
    }
  / '#\\' val:. &Delimiter {
      return {type: 'character', value: val};
    }

CharacterName
  = 'space' { return " "; }
  / "newline" { return "\n"; }

String
  = '"' val:StringElement* '"' {
      return {type: 'string', value: val.join("")};
    }

StringElement
  = '\\\\' { return '\\'; }
  / '\\"' { return '"'; }
  / [^"\\]


// Only supports floating point numbers and integers
Number
  = val:Float &Delimiter {
      return {type: 'float', value: val};
    }
  / val:Integer &Delimiter {
      return {type: 'integer', value: val};
    }

Integer
  = DecimalPrefix val:Decimal { return val; }
  / Hexadecimal
  / BinaryDecimal
  / OctDecimal

Float
  = i:Decimal frac:Fraction exp:Exponent {
      return parseFloat(i + frac + exp);
    }
  / i:Decimal frac:Fraction {
      return parseFloat(i + frac);
    }
  / i:Decimal '.' {
      return parseFloat(i);
    }
  / i:Decimal '.'? exp:Exponent {
      return parseFloat(i + exp);
    }
  / frac:Fraction exp:Exponent {
      return parseFloat(frac + exp);
    }
  / frac:Fraction {
      return parseFloat(frac);
    }

Decimal
  = sign:Sign first:Digit19 rest:Digits {
      return parseInt(sign + first + rest);
    }
  / sign:Sign digit:Digit {
      return parseInt(sign + digit);
    }

Hexadecimal
  = HexPrefix digits:DigitsHex { return parseInt(digits, 16); }

BinaryDecimal
  = BinaryPrefix digits:DigitsBinary { return parseInt(digits, 2); }

OctDecimal
  = OctPrefix digits:DigitsOct { return parseInt(digits, 8); }

Fraction
  = '.' digits:Digits { return '.' + digits; }

Exponent
  = e:ExponentMarker s:Sign digits:Digits {
      return e + s + digits;
    }

DecimalPrefix
  = '#d'?

HexPrefix
  ='#x'

OctPrefix
  = '#o'

BinaryPrefix
  = '#b'

ExponentMarker
  = [esfdl] { return "e"; }

Sign
  = [\-+]?

Digits
  = digits:Digit+ {
      return digits.join("");
    }

DigitsHex
  = digits:DigitHex+ {
      return digits.join("");
    }

DigitsOct
  = digits:DigitOct+ {
      return digits.join("");
    }

DigitsBinary
  = digits:DigitBinary+ {
      return digits.join("");
    }

Digit
  = [0-9]

Digit19
  =[1-9]

DigitHex
  = [0-9a-fA-F]

DigitOct
  = [0-7]

DigitBinary
  = [01]

// FIXME: Quasiquote is not context free
Datum
  = QuotePrefix Datum
  / QuotePrefix Datum
  / UnquotePrefix Datum
  / UnquotePrefix Datum
  / CompoundDatum
  / SimpleDatum

SimpleDatum
  = Token

CompoundDatum
  = List
  / EmptyList

EmptyList
  = QuotePrefix '(' InterTokenSpace ')' { return []; }

List
  = '(' list:ListDatum+ InterTokenSpace ')' {
      return list;
    }
  / '(' head:ListDatum+ InterTokenSpace '.' last:ListDatum InterTokenSpace ')' {
      head.splice(head.length, 0, dot, last);
      return head;
    }

ListDatum
  = InterTokenSpace datum:Datum {
      return datum;
    }

QuotePrefix
  = Quote
  / Quasiquote

Quote
  = "'" { return {type: 'symbol', value: 'quote'}; }

Quasiquote
  = '`' { return {type: 'symbol', value: 'quasiquote'}; }

UnquotePrefix
  = UnquoteSplicing
  / Unquote

UnquoteSplicing
  = ',@' { return {type: 'symbol', value: 'unquote-splicing'}; }

Unquote
  = ',' { return {type: 'symbol', value: 'unquote'}; }
