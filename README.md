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

A Flutter package which allows the user to enter text which can be collapsed and expanded based on user defined trimming conditions. Nevertheless, it will automatically parse the urls present in the text into clickable hyperlinks. It also allows the user to enter a highlight text on which some custom text style can be applied.

# Features

* Expandable and Collapsable text.
* Trimming can either be done on basis of length or number of lines.
* Option to include a customised delimiter.
* Automatically parses the urls present in the text into hyperlinks which launches the browser on click event (default behaviour).
* All the text components including the parsed urls, delimiter, clickable texts, etc can be given seperate custom styles.
* Addition of user defined action on clicking the hyperlinks **(latest addition)**.
* Option to add custom text styles for target text **(latest addition)**.

# Installation

Run this command in your terminal
```dart
flutter pub add parsed_readmore
```
Or add it manually in your project's pubspec.yaml (and run an implicit flutter pub get):
```dart
dependencies:
  parsed_readmore: latest_version
```

Import parsed_readmore.dart in the file where you wish to use
```dart
import 'package:parsed_readmore/parsed_readmore.dart';
```

# Usage Example
 For detailed implementation refer to the "Example" tab

 We will be using a common input string to demonstrate the different uses cases of this package.
 ```dart
  const inputString = "When using custom values we have specified 'the' to be our target text for highlighting  with purple italic font.\n We know that the website https://google.com is a very useful website. (rti..notNow should not be parsed) But Instagram.com is more fun to use. We should not forget the contribution of wikipedia.com played in the growth of web. If you like this package do consider liking it so that it could be useful to more developers like you. Thank you for your time";
 ```

### Without using package (Plain Text)
[Plain Text](https://github.com/aashish2604/parsed_readmore/assets/79049365/f3388857-f02d-4cb6-af94-72be64cbd40d)

Here we are using the simple Text() widget available in Flutter by default.
```dart
  Text(inputString);
```
We can clearly see that no url is parsed here into clickable texts and there is no option to expand and collapse the texts.

### Using package with default values


[Default Package](https://github.com/aashish2604/parsed_readmore/assets/79049365/0e3f1b75-9091-410a-bf75-5a0d93915e4e)


```dart
ParsedReadMore(inputString)
```

The code above will implement all features of the widget with the default values which are :
* trimMode = TrimMode.length
* delimiter = ' ...'
* trimLength = 240
* trimExpandedText = 'show less',
* trimCollapsedText = 'read more',
* if onTapLink == null --> url will be launched in extrenal browser.

Here the urls are parsed into clickable links which open external browser on tapping. The text is also collapsable and expandable

### Using package with custom values


[Custom Package](https://github.com/aashish2604/parsed_readmore/assets/79049365/f6c1f846-c73e-491f-8172-1be67212c723)


```dart
ParsedReadMore(
    inputString,
    urlTextStyle: TextStyle(color: Colors.green, fontSize: 20, decoration: TextDecoration.underline),
    trimMode: TrimMode.line,
    trimLines: 4,
    delimiter: '  ***',
    delimiterStyle: TextStyle(color: Colors.black, fontSize: 20),
    style: TextStyle(color: Colors.orange, fontSize: 20),
    onTapLink: (url) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '$url is displayed because we have used custom onTap function for hyperlinks')));
    },
    highlightText: TargetTextHighlight(
        targetText: 'the',
        style: const TextStyle(
            fontSize: 20.0,
            fontStyle: FontStyle.italic,
            color: Colors.purple)),
    trimCollapsedText: 'expand',
    trimExpandedText: 'compress',
    moreStyle: TextStyle(color: Colors.red, fontSize: 20),
    lessStyle: TextStyle(color: Colors.blue, fontSize: 20),
)
```
In this case we can see that all of our custom parameters specified above are visible in the text. We have different textstyles for urls, highlight text and the leftover text. Moreover, we have a custom delimiter and a user defined onTapLink function for the hyperlinks which opens a snackbar instead of launching the urls. The expand and collapse tags are also having custom text values with seperate user defined text styles.

# Issues

Please file any issues, bugs or feature request as an issue on the GitHub page. If you have some idea for feature upgrade, feel free to contact me through email [aashish.260401@gmail.com](mailto:aashish.260401@gmail.com).

