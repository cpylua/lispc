start
	= InterTokenSpace tokens:Tokens {
			return tokens;
		}
	/ InterTokenSpace { return []; }

Tokens
	= tokens:(Token InterTokenSpace)+ {
			return tokens.map(function (t) {
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
	/ !.+		/* End of input */

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
	= [!$%&*/:<=>?^_~]

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
			return {type: 'keyword', value: keyword[0]};
		}

SyntacticKeyword
	= ExpressionKeyword
	/ 'else'i
	/ '=>'
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
			return { type: 'variable', value: identifier};
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