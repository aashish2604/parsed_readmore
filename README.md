<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->
# **Parsed Readmore**

A package which allows to enter text which can be collapsed and expanded. Moreover, it will automatically parse the urls present in the text into hyperlinks.

![Demo Gif](https://github.com/aashish2604/parsed_readmore/blob/main/assets/resized_parsed_readmore_final.gif)

# Features

* Expandable and Collapsable text.
* Trimming can either be done on basis of length or number of lines.
* Option to include a customised delimiter.
* Automatically parses the urls present in the text into hyperlinks which launches the browser on click event.
* All the text components including the parsed urls, delimiter, clickable texts, etc can be given seperate custom styles.

# Installation

Run this command in your terminal
```dart
flutter pub add parsed_readmore
```
Or add it manually in your project's pubspec.yaml (and run an implicit flutter pub get):
```dart
dependencies:
  parsed_readmore: 
```

<!-- 
### OR

```dart

``` -->

# Usage Example

### For detailed implementation refer to the example

#### Import parsed_readmore.dart
```dart
import 'package:parsed_readmore/parsed_readmore.dart';
```

The code below will implement all features of the widget with the default values which are :
* trimMode = TrimMode.length
* delimiter = ' ...'
* trimLength = 240
* trimExpandedText = 'show less',
* trimCollapsedText = 'read more',

```dart
ParsedReadMore(inputString)
```

If you need to use some customized values for different elements of the widget just add values to the relevant parameters.
```dart
ParsedReadMore(
    inputString,
    urlTextStyle: TextStyle(color: Colors.green, fontSize: 20, decoration: TextDecoration.underline),
    trimMode: TrimMode.line,
    trimLines: 4,
    delimiter: '  ***',
    delimiterStyle: TextStyle(color: Colors.black, fontSize: 20),
    style: TextStyle(color: Colors.orange, fontSize: 20),
    trimCollapsedText: 'expand',
    trimExpandedText: 'compress',
    moreStyle: TextStyle(color: Colors.red, fontSize: 20),
    lessStyle: TextStyle(color: Colors.blue, fontSize: 20),
)
```

# Issues

Please file any issues, bugs or feature request as an issue on the GitHub page. If you have some idea for feature upgrade, feel free to contact me through email [aashish.260401@gmail.com](aashish.260401@gmail.com).

