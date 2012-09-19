{
  var valTrue = {type: 'boolean', value: true},
      valFalse = {type: 'boolean', value: false};

  function LispCharacter(val) {
    return {type: 'character', value: val};
  }

  function LispString(val) {
    return {type: 'string', value: val};
  }

  function LispInteger(val) {
    return {type: 'integer', value: val};
  }

  function LispFloat(val) {
    return {type: 'float', value: val};
  }

  function LispSymbol(val) {
    return {type: 'symbol', value: val};
  }

  var dot = {type: 'dot'};
}

start
  = InterTokenSpace data:Data {
      return data;
    }
  / InterTokenSpace { return []; }

Data
  = data:(Datum InterTokenSpace)+ {
      return data.map(function (t) {
        return t[0];
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
      return new LispSymbol(keyword[0]);
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
      return new LispSymbol(identifier);
    }

Boolean
  = '#t' &Delimiter {
      return valTrue;
    }
  / '#f' &Delimiter {
      return valFalse;
    }

Character
  = '#\\' val: CharacterName &Delimiter {
      return new LispCharacter(val);
    }
  / '#\\' val:. &Delimiter {
      return new LispCharacter(val);
    }

CharacterName
  = 'space' { return " "; }
  / "newline" { return "\n"; }
  / "tab" { return '\t'; }

String
  = '"' val:StringElement* '"' {
      return new LispString(val.join(""));
    }

StringElement
  = '\\\\' { return '\\'; }
  / '\\"' { return '"'; }
  / [^"\\]


// Only supports floating point numbers and integers
Number
  = val:Float &Delimiter {
      return new LispFloat(val);
    }
  / val:Integer &Delimiter {
      return new LispInteger(val);
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

List
  = '(' list:ListDatum* InterTokenSpace ')' {
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
  = "'" { return new LispSymbol('quote'); }

Quasiquote
  = '`' { return new LispSymbol('quasiquote'); }

UnquotePrefix
  = UnquoteSplicing
  / Unquote

UnquoteSplicing
  = ',@' { return new LispSymbol('unquote-splicing'); }

Unquote
  = ',' { return new LispSymbol('unquote'); }
