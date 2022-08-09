abstract class Token {
  String token;
  Token(this.token);

  @override
  String toString() {
    return token.toString();
  }

  String tokenString();

  String type() {
    return runtimeType.toString();
  }
}

class Str extends Token {
  final String str;
  Str(this.str) : super('String');

  @override
  String tokenString() => 'String';
  get value => str;
  @override
  String type() => 'String($str)';
}

class Num extends Token {
  final double num;
  Num(this.num) : super('Number');
  @override
  String tokenString() => 'Number';
  get value => num;
  @override
  String type() => 'Number($num)';
}

class True extends Token {
  True() : super('True');
  @override
  String tokenString() => 'True';
}

class False extends Token {
  False() : super('False');
  @override
  String tokenString() => 'False';
}

class Null extends Token {
  Null() : super('Null');
  @override
  String tokenString() => 'Null';
}

class Ident extends Token {
  final String ident;
  Ident(this.ident) : super('Iden');
  get value => ident;
  @override
  String toString() => ident;
  @override
  String tokenString() => 'Iden($ident)';
}

class LBrace extends Token {
  LBrace() : super('LBrace');
  @override
  String tokenString() => 'LBrace';
}

class RBrace extends Token {
  RBrace() : super('RBrace');
  @override
  String tokenString() => 'RBrace';
}

class LBracket extends Token {
  LBracket() : super('LBracket');
  @override
  String tokenString() => 'LBracket';
}

class RBracket extends Token {
  RBracket() : super('RBracket');
  @override
  String tokenString() => 'RBrakcet';
}

class Colon extends Token {
  Colon() : super('Colon');
  @override
  String tokenString() => 'Colon';
}

class Comma extends Token {
  Comma() : super('Comma');
  @override
  String tokenString() => 'Comma';
}

class Eof extends Token {
  Eof() : super('EOF');
  @override
  String tokenString() => 'EOF';
}

class Space extends Token {
  Space() : super('Space');
  @override
  String tokenString() => 'Space';
}

class Error extends Token {
  final String error;
  Error(this.error) : super('Error');
  @override
  String toString() => 'Error($error)';
  @override
  String tokenString() => 'Error';
}

class Lexer {
  late final String input;
  int position = 0;
  String ch = ' ';

  Lexer({required this.input});

  void _read() {
    if (position >= input.length) {
      ch = '\q';
    } else {
      ch = String.fromCharCode(input.codeUnitAt(position++));
    }
  }

  void _skipWhiteSpace() {
    while (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r') {
      _read();
    }
  }

  Token readStr() {
    var str = '';
    while (true) {
      _read();
      if (ch == '"') {
        return Str(str);
      } else if (ch == '\\') {
        _read();
        if (ch == '"') {
          str += '"';
        } else if (ch == '\\') {
          str += '\\';
        } else {
          throw 'Unsupported escape sequence: \\$ch';
        }
        continue;
      }
      str += ch;
      continue;
    }
  }

  String readNum() {
    var num = '';
    if (ch == '-') {
      num += ch;
      _read();
    }

    if (!isNumber(ch)) {
      return num;
    }

    if (ch == '0') {
      num += ch;
      _read();
      if (isNumber(ch)) {
        return num;
      }
    } else if (isNumber(ch)) {
      num += ch;
      _read();
      while (isNumber(ch)) {
        num += ch;
        _read();
      }
    }

    if (ch == '.') {
      num += ch;
      _read();
      while (isNumber(ch)) {
        num += ch;
        _read();
      }
    }

    if (ch == 'e' || ch == 'E') {
      num += ch;
      _read();
      if (!(ch == '+' || ch == '-')) {
        return num;
      }
      num += ch;
      _read();
      while (isNumber(ch)) {
        num += ch;
        _read();
      }
    }

    return num;
  }

  String readIden() {
    var iden = '';
    while (ch != ',' && ch != ':' && ch != ']' && ch != '}') {
      iden += ch;
      _read();
    }
    position--;
    return iden;
  }

  Token next() {
    _read();
    _skipWhiteSpace();
    switch (ch) {
      case ' ':
        return Space();
      case '{':
        return LBrace();
      case '}':
        return RBrace();
      case '[':
        return LBracket();
      case ']':
        return RBracket();
      case ':':
        return Colon();
      case ',':
        return Comma();
      case '"':
        return readStr();
      case '\q':
        return Eof();
      default:
        if (isNumber(ch)) {
          String tok = readNum();
          return Num(double.parse(tok));
        } else {
          String iden = readIden();
          if (iden == 'true') {
            return True();
          } else if (iden == 'false') {
            return False();
          } else if (iden == 'null') {
            return Null();
          } else {
            return Ident(iden);
          }
        }
    }
  }
}

bool isNumber(String s) {
  return (s.codeUnitAt(0) >= 48 && s.codeUnitAt(0) <= 57) ||
      s == '+' ||
      s == '-';
}

bool isAlpha(String s) {
  return (s.codeUnitAt(0) >= 65 && s.codeUnitAt(0) <= 90) ||
      (s.codeUnitAt(0) >= 97 && s.codeUnitAt(0) <= 122);
}

class JSON {
  Lexer _lexer = Lexer(input: "");
  Token _tok = Error('Initial');
  int _depth = 0;
  int _indent = 2;

  JSON();

  void _next() {
    _tok = _lexer.next();
  }

  Map<String, dynamic> parse(String source) {
    _lexer = Lexer(input: source);
    dynamic value = _parseValue();
    return value as Map<String, dynamic>;
  }

  dynamic _parseValue() {
    _next();
    switch (_tok.tokenString()) {
      case 'LBrace':
        return _parseObject();
      case 'LBracket':
        return _parseArray();
      case 'String':
        return (_tok as Str).value;
      case 'Number':
        return (_tok as Num).value;
      case 'True':
        return true;
      case 'False':
        return false;
      case 'Null':
        return null;
      case 'Eof':
      default:
        throw 'Unexpected token: ${_tok.tokenString()}';
    }
  }

  Map<String, dynamic> _parseObject() {
    var obj = <String, dynamic>{};
    while (true) {
      _next();
      String key = (_tok as Str).value;
      _next();
      obj[key] = _parseValue();
      _next();
      if (_tok.tokenString() == 'Comma') {
        continue;
      } else if (_tok.tokenString() == 'RBrace') {
        return obj;
      } else {
        throw 'Unexpected token: ${_tok.tokenString()}';
      }
    }
  }

  List _parseArray() {
    var arr = [];
    while (true) {
      if (_tok.type() == 'RBracket') {
        break;
      }
      arr.add(_parseValue());
      _next();
    }
    return arr;
  }

  String stringify(Map<String, dynamic> json) {
    var sb = StringBuffer();
    sb.write("{\n");
    var first = true;
    for (var key in json.keys) {
      _depth++;
      if (!first) {
        sb.write(",\n");
      }
      first = false;
      sb
        ..write(_genIndent())
        ..write('"$key":')
        ..write(stringifyValue(json[key]));
      _depth--;
    }
    sb
      ..write(_genIndent())
      ..write("}\n");
    return sb.toString();
  }

  String stringifyValue(json) {
    var sb = StringBuffer();
    _depth++;
    if (json is String) {
      sb
        ..write(' ')
        ..write('"$json"');
    } else if (json is num) {
      sb
        ..write(' ')
        ..write(json.toString());
    } else if (json is bool) {
      sb
        ..write(' ')
        ..write(json ? 'true' : 'false');
    } else if (json is Map<String, dynamic>) {
      sb
        ..write(' ')
        ..write(stringify(json));
    } else if (json is List) {
      _depth++;
      sb.write('[\n');
      var first = true;
      for (var item in json) {
        if (!first) {
          sb.write(',\n');
        }
        first = false;
        sb
          ..write(_genIndent())
          ..write(stringifyValue(item));
      }
      _depth--;
      sb
        ..write('\n')
        ..write(_genIndent())
        ..write(']\n');
    } else {
      sb.write(" null");
    }
    _depth--;
    return sb.toString();
  }

  String _genIndent() {
    var sb = StringBuffer();
    for (var i = 0; i < _depth * _indent; i++) {
      sb.write(' ');
    }
    return sb.toString();
  }
}
