import 'package:flutter/material.dart';
import 'package:parsed_readmore/parsed_readmore.dart';

const String inputData =
    "When using custom values we have specified 'the' to https://google.com is a very useful website. (rti..notNow should not be parsed) But Instagram.com is more fun to use. We should not forget the contribution of wikipedia.com played in the growth of web. If you like this package do consider liking it so that it could be useful to more developers like you. Thank you for your time";

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
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Parsed Read More'),
            bottom: const TabBar(tabs: [
              Tab(
                text: 'Without',
              ),
              Tab(
                text: 'Default',
              ),
              Tab(
                text: 'Custom',
              ),
            ]),
          ),
          body: const TabBarView(children: [
            WithoutPackage(),
            DefaultValuesPackage(),
            CustomValuesPackage(),
          ])),
    );
  }
}

class WithoutPackage extends StatelessWidget {
  const WithoutPackage({super.key});

  @override
  Widget build(BuildContext context) {
    const TextStyle labelTextStyle = TextStyle(
        fontSize: 24, color: Colors.grey, fontWeight: FontWeight.bold);

    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Without using the package", style: labelTextStyle),
            SizedBox(height: 12),
            Text(inputData),
          ],
        ),
      ),
    );
  }
}

class DefaultValuesPackage extends StatelessWidget {
  const DefaultValuesPackage({super.key});

  @override
  Widget build(BuildContext context) {
    const TextStyle labelTextStyle = TextStyle(
        fontSize: 24, color: Colors.grey, fontWeight: FontWeight.bold);

    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Using package with default values", style: labelTextStyle),
            SizedBox(height: 12),

            //Package widget using only default values.
            ParsedReadMore(TextHighlightParser(data: inputData)),
          ],
        ),
      ),
    );
  }
}

class CustomValuesPackage extends StatelessWidget {
  const CustomValuesPackage({super.key});

  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(fontSize: 20);
    const TextStyle labelTextStyle = TextStyle(
        fontSize: 24, color: Colors.grey, fontWeight: FontWeight.bold);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Using package with custom values',
              style: labelTextStyle,
            ),
            const SizedBox(height: 12),
            ParsedReadMore(
              TextHighlightParser(
                data: inputData,
                urlTextStyle: textStyle.copyWith(
                  color: Colors.green,
                  decoration: TextDecoration.underline,
                ),
                trimMode: TrimMode.line,
                maxLines: 2,
                onTapLink: (url) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        """'$url' is displayed because we have used custom onTap function for hyperlinks""",
                      ),
                    ),
                  );
                },
              ),
              readMoreDelimiter: '+++',
              readLessDelimiter: ' ---',
              readMoreDelimiterStyle: textStyle.copyWith(color: Colors.black),
              readLessDelimiterStyle: textStyle.copyWith(color: Colors.black),
              style: textStyle.copyWith(color: Colors.grey),
              readMoreText: ' expand',
              readLessText: ' compress',
              readMoreTextStyle: textStyle.copyWith(color: Colors.blue),
              readLessTextStyle: textStyle.copyWith(color: Colors.pink),
            ),
            const SizedBox(height: 64),

            const Divider(),
            const SizedBox(height: 64),

            const Text(
              'Using package with multiple highlights targets',
              style: labelTextStyle,
            ),
            const SizedBox(height: 12),

            //Package widget using custom values
            ParsedReadMore(
              TextHighlightParser(
                data: inputData,
                targetTextHighlights: TargetTextHighlights([
                  TargetTextHighlight(
                    priority: 1,
                    targetText: 'We',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontStyle: FontStyle.italic,
                      color: Colors.blue[900],
                    ),
                  ),
                  const TargetTextHighlight(
                    priority: 2,
                    targetText: 't',
                    highlightInUrl: true,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.purple,
                    ),
                  ),
                  TargetTextHighlight(
                    priority: 3,
                    targetText: 'e',
                    highlightInUrl: true,
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.orange,
                    ),
                    onTap: (range) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "${range.textInside(inputData)} is between ${range.start} and ${range.end}"),
                        ),
                      );
                    },
                  ),
                ]),
                shouldEnableExpandCollapse: false,
                trimMode: TrimMode.none,
              ),
              style: textStyle.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
