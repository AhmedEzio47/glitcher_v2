import 'package:flutter/material.dart';

class HelpCenter extends StatefulWidget {
  @override
  _HelpCenterState createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  // final flutterWebViewPlugin = FlutterWebviewPlugin();
  // String selectedUrl = 'https://www.gl1tch3r.com/category/help-center';
  // // ignore: prefer_collection_literals
  // final Set<JavascriptChannel> jsChannels = [
  //   JavascriptChannel(
  //       name: 'Print',
  //       onMessageReceived: (JavascriptMessage message) {
  //         print(message.message);
  //       }),
  // ].toSet();
  // GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     key: _scaffoldKey,
  //     appBar: AppBar(
  //       title: Text(Strings.help_center),
  //       flexibleSpace: gradientAppBar(),
  //       centerTitle: true,
  //     ),
  //     // We're using a Builder here so we have a context that is below the Scaffold
  //     // to allow calling Scaffold.of(context) so we can show a snackbar.
  //     body: SafeArea(
  //       child: Container(
  //         height: MediaQuery.of(context).size.height,
  //         width: MediaQuery.of(context).size.width,
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: <Widget>[
  //             Flexible(
  //                 flex: 10,
  //                 child: Stack(
  //                   children: <Widget>[
  //                     WebviewScaffold(
  //                       url: selectedUrl,
  //                       javascriptChannels: jsChannels,
  //                       mediaPlaybackRequiresUserGesture: false,
  //                       withZoom: true,
  //                       withLocalStorage: true,
  //                       hidden: true,
  //                       initialChild: Container(
  //                         color: Colors.deepPurple,
  //                         child: const Center(
  //                           child: CircularProgressIndicator(
  //                             backgroundColor: Colors.cyanAccent,
  //                             strokeWidth: 10,
  //                           ),
  //                         ),
  //                       ),
  //                       bottomNavigationBar: BottomAppBar(
  //                         child: Row(
  //                           children: <Widget>[
  //                             IconButton(
  //                               icon: const Icon(Icons.arrow_back_ios),
  //                               onPressed: () {
  //                                 flutterWebViewPlugin.goBack();
  //                               },
  //                             ),
  //                             IconButton(
  //                               icon: const Icon(Icons.arrow_forward_ios),
  //                               onPressed: () {
  //                                 flutterWebViewPlugin.goForward();
  //                               },
  //                             ),
  //                             IconButton(
  //                               icon: const Icon(Icons.autorenew),
  //                               onPressed: () {
  //                                 flutterWebViewPlugin.reload();
  //                               },
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 )),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
