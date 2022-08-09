# dart-json

A simple JSON parser for Dart

## Usage

```dart
import 'package:dart_json/dart_json.dart';

final text = '''
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

Map<String, dynamic> val = JSON().parse(text);
print(JSON().stringify(val));
```

## License

MIT License
