import 'package:flutter/material.dart';
import 'package:parsed_readmore/parsed_readmore.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ParsedReadMoreDemo(),
    );
  }
}

class ParsedReadMoreDemo extends StatefulWidget {
  const ParsedReadMoreDemo({Key? key}) : super(key: key);

  @override
  State<ParsedReadMoreDemo> createState() => _ParsedReadMoreDemoState();
}

class _ParsedReadMoreDemoState extends State<ParsedReadMoreDemo> {
  final TextStyle textStyle = const TextStyle(fontSize: 20);
  final TextStyle labelTextStyle = const TextStyle(
      fontSize: 24, color: Colors.grey, fontWeight: FontWeight.bold);
  static const String inputData =
      "We know that https://google.com is a very useful website. (rti..notNow should not be parsed) But Instagram.com is more fun to use. We should not forget the contribution of wikipedia.com played in the growth of web. If you like this package do consider liking it so that it could be useful to more developers like you. Thank you for your time";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parsed Read More'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Without using package",
                style: labelTextStyle,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(inputData),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Divider(
                  thickness: 3,
                ),
              ),

              Text(
                "Using package with default values",
                style: labelTextStyle,
              ),
              const SizedBox(
                height: 10,
              ),

              //Package widget using only default values.
              const ParsedReadMore(inputData),

              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Divider(
                  thickness: 3,
                ),
              ),
              Text(
                'Using package with custom values',
                style: labelTextStyle,
              ),
              const SizedBox(
                height: 10,
              ),

              //Package widget using custom values
              ParsedReadMore(
                inputData,
                urlTextStyle: textStyle.copyWith(
                    color: Colors.green, decoration: TextDecoration.underline),
                trimMode: TrimMode.line,
                trimLines: 4,
                delimiter: '  ***',
                highlightText: TargetTextHighlight(
                    targetText: 'the',
                    style: const TextStyle(
                        fontSize: 20.0,
                        fontStyle: FontStyle.italic,
                        color: Colors.purple)),
                delimiterStyle: textStyle.copyWith(color: Colors.black),
                style: textStyle.copyWith(color: Colors.orange),
                trimCollapsedText: 'expand',
                trimExpandedText: 'compress',
                moreStyle: textStyle.copyWith(color: Colors.red),
                lessStyle: textStyle.copyWith(color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
