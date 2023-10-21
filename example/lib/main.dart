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
    const String inputData =
        "When using custom values we have specified 'the' to be our target text for highlighting  with purple italic font.\n We know that the website https://google.com is a very useful website. (rti..notNow should not be parsed) But Instagram.com is more fun to use. We should not forget the contribution of wikipedia.com played in the growth of web. If you like this package do consider liking it so that it could be useful to more developers like you. Thank you for your time";
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Without using package",
              style: labelTextStyle,
            ),
            SizedBox(
              height: 10,
            ),
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
    const String inputData =
        "When using custom values we have specified 'the' to be our target text for highlighting  with purple italic font.\n We know that the website https://google.com is a very useful website. (rti..notNow should not be parsed) But Instagram.com is more fun to use. We should not forget the contribution of wikipedia.com played in the growth of web. If you like this package do consider liking it so that it could be useful to more developers like you. Thank you for your time";
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Using package with default values",
              style: labelTextStyle,
            ),
            SizedBox(
              height: 10,
            ),

            //Package widget using only default values.
            ParsedReadMore(inputData),
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
    const String inputData =
        "When using custom values we have specified 'the' to be our target text for highlighting  with purple italic font.\n We know that the website https://google.com is a very useful website. (rti..notNow should not be parsed) But Instagram.com is more fun to use. We should not forget the contribution of wikipedia.com played in the growth of web. If you like this package do consider liking it so that it could be useful to more developers like you. Thank you for your time";
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
              onTapLink: (url) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "'$url' is displayed because we have used custom onTap function for hyperlinks")));
              },
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
    );
  }
}
