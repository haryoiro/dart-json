// ignore: depend_on_referenced_packages
import 'package:dart_json/parser.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void main() {
  test('lex all', () {
    var lex = Lexer(input: '"hello"');
    while (true) {
      Token token = lex.next();
      if (token is Eof) {
        break;
      }
      print(token.tokenString());
    }
  });

  test('lex str', () {
    final tests = [
      Tuple2('"hello":', [Str('hello'), Colon()]),
      Tuple2('"hello\\"world"', [
        Str('hello"world'),
      ]),
    ];

    for (var test in tests) {
      var lex = Lexer(input: test.item1);
      var tokens = [];
      while (true) {
        Token token = lex.next();
        if (token is Eof) {
          break;
        }
        tokens.add(token);
        print(token.tokenString());
      }

      for (var i = 0; i < tokens.length; i++) {
        expect(tokens[i].tokenString(), test.item2[i].tokenString());
      }
    }
  });

  test('lex number', () {
    final tests = [
      Tuple2('123', [Num(123)]),
      Tuple2('-123', [Num(-123)]),
      Tuple2('123.123', [Num(123.123)]),
      Tuple2('-123.123', [Num(-123.123)]),
      Tuple2('123.123e-123', [Num(123.123e-123)]),
      Tuple2('123.123e+123', [Num(123.123e+123)]),
    ];

    for (var test in tests) {
      var lex = Lexer(input: test.item1);
      var tokens = [];
      while (true) {
        Token token = lex.next();
        if (token is Eof) {
          break;
        }
        tokens.add(token);
        print(token.tokenString());
      }
      for (var i = 0; i < tokens.length; i++) {
        expect(tokens[i].tokenString(), test.item2[i].tokenString());
      }
    }
  });

  test('lex', () {
    final text = '''{
      "foo": "bar",
      "baz": true,
      "qux": null,
      "obj": {
          "inner": "inner text",
          "innerArray": [
              "array1",
              "array2",
              "array3"
          ]
      }
     }''';

    var lex = Lexer(input: text);
    var tokens = [];
    while (true) {
      Token token = lex.next();
      if (token is Eof) {
        break;
      }
      tokens.add(token);
    }
    for (var i = 0; i < tokens.length; i++) {
      print(tokens[i].tokenString());
    }
    print(tokens);
  });

  test('parse all', (() {
    final texts = '''
      {
        "foo": "bar",
        "baz": true,
        "qux": null,
        "obj": {
            "inner": "inner text",
            "innerArray": [
                "array1",
                "array2",
                "array3"
            ]
        }
      }
    ''';

    Map<String, dynamic> val = JSON().parse(texts);

    print(val);
  }));

  test('parse array', (() {
    final texts = '''
      {
        "array": [
          "foo",
          "bar",
          "baz"
        ]
      }
    ''';
    Map<String, dynamic> val = JSON().parse(texts);
    print(val);
  }));

  test('stringify', (() {
    final texts = '''
      {
        "foo": "bar",
        "baz": true,
        "qux": null,
        "obj": {
            "inner": "inner text",
            "innerArray": [
                "array1",
                "array2",
                "array3"
            ]
        }
      }
    ''';
    Map<String, dynamic> val = JSON().parse(texts);
    print(JSON().stringify(val));
  }));
}
