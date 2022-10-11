// source: https://towardsdev.com/in-app-update-in-flutter-desktop-using-github-4b9c6a281510
// https://www.youtube.com/watch?v=XvwX-hmYv0E&ab_channel=RetroPortalStudio
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/application.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'In App Updates in Flutter Desktop App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'In App Updates in Flutter Desktop App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isDownloading = false;
  double downloadProgress = 0;
  String downloadedFilePath = "";
  Future<Map<String, dynamic>> loadJsonFromGithub() async {
    final response = await http.read(Uri.parse(
        "https://raw.githubusercontent.com/Borgerod/post_install_app_update_test/main/app/app_version_check/version.json"));
    return jsonDecode(response);
  }

  Future<void> openExeFile(String filePath) async {
    await Process.start(filePath, ["-t", "-l", "1000"]).then((value) {});
  }

  Future<void> openDMGFile(String filePath) async {
    await Process.start(
        "MOUNTDEV=\$(hdiutil mount '$filePath' | awk '/dev.disk/{print\$1}')",
        []).then((value) {
      debugPrint("Value: $value");
    });
  }

  Future downloadNewVersion(String appPath) async {
    final fileName = appPath.split("/").last;
    isDownloading = true;
    setState(() {});

    final dio = Dio();

    downloadedFilePath =
        "${(await getApplicationDocumentsDirectory()).path}/$fileName";
    await dio.download(
      "https://raw.githubusercontent.com/Borgerod/post_install_app_update_test/main/app/app_version_check/$appPath",
      downloadedFilePath,
      onReceiveProgress: (received, total) {
        final progress = (received / total) * 100;
        debugPrint('Rec: $received , Total: $total, $progress%');
        downloadProgress = double.parse(progress.toStringAsFixed(1));
        setState(() {});
      },
    );
    debugPrint("File Downloaded Path: $downloadedFilePath");
    if (Platform.isWindows) {
      await openExeFile(downloadedFilePath);
    }
    isDownloading = false;
    setState(() {});
  }

  showUpdateDialog(Map<String, dynamic> versionJson) {
    final version = versionJson['version'];
    final updates = versionJson['description'] as List;
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(10),
            title: Text("Latest Version $version"),
            children: [
              Text("What's new in $version"),
              const SizedBox(
                height: 5,
              ),
              ...updates
                  .map((e) => Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "$e",
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ))
                  .toList(),
              const SizedBox(
                height: 10,
              ),
              if (version > ApplicationConfig.currentVersion)
                TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      if (Platform.isMacOS) {
                        downloadNewVersion(versionJson["macos_file_name"]);
                      }
                      if (Platform.isWindows) {
                        downloadNewVersion(versionJson["windows_file_name"]);
                      }
                    },
                    icon: const Icon(Icons.update),
                    label: const Text("Update")),
            ],
          );
        });
  }

  Future<void> _checkForUpdates() async {
    final jsonVal = await loadJsonFromGithub();
    debugPrint("Response: $jsonVal");
    showUpdateDialog(jsonVal);
    // if (jsonVal['version'] > ApplicationConfig.currentVersion) {
    //   setState(() {
    //     ApplicationConfig.currentVersion = jsonVal['version'];
    //   }
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Current Version is ${ApplicationConfig.currentVersion}',
                ),
                if (!isDownloading && downloadedFilePath != "")
                  Text("File Downloaded in $downloadedFilePath")
              ],
            ),
            if (isDownloading)
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black.withOpacity(0.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    Text(downloadProgress.toStringAsFixed(1) + " %")
                  ],
                ),
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _checkForUpdates,
        tooltip: 'Check for Updates',
        child: const Icon(Icons.update),
      ),
    );
  }
}


// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;

// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:app_version_check/app_version_check.dart' as versionJson;

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);
//   final String title;
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   Future<Map<String, dynamic>> versionJson = loadJsonFromGithub();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
      
//       if (version > ApplicationConfig.currentVersion)
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: TextButton.icon(
//           onPressed: () {
//             Navigator.pop(context);
//             if (Platform.isMacOS) {
//               // var versionJson;
//               downloadNewVersion(versionJson["macos_file_name"]);
//             }
//             if (Platform.isWindows) {
//               // var versionJson;
//               downloadNewVersion(versionJson["macos_file_name"]);
//             }
//           },
//           icon: const Icon(Icons.update),
//           label: const Text("Update"),
//         ),
//       ),
//     );
//   }

//   Future downloadNewVersion(String appPath) async {
//     final fileName = appPath.split("/").last;
//     var isDownloading = true;
//     setState(() {});
//     final dio = Dio();
//     var downloadedFilePath =
//         "${(await getApplicationDocumentsDirectory()).path}/$fileName";

//     await dio.download(
//       "GITHUB_LINK/$appPath",
//       downloadedFilePath,
//       onReceiveProgress: (recieved, total) {
//         final progress = (recieved / total) * 100;
//         debugPrint("Rec: $recieved, Total: $total, $progress%");
//         var downloadProgress = double.parse(progress.toStringAsFixed(1));
//         setState(() {});
//       },
//     );
//     debugPrint("File Downloaded Path: $downloadedFilePath");
//     if (Platform.isWindows) {
//       await openExeFile(downloadedFilePath);
//     }
//     isDownloading = false;
//     setState(() {});

//     return "";
//   }
// }

// Future<void> openExeFile(String filePath) async {
//   await Process.start(filePath, ["-t", "-l", "1000"]).then((value) {});
// }

// Future<void> _checkForUpdates() async {
//   final jsonVal = await loadJsonFromGithub();
//   debugPrint("Presonsive: $jsonVal");
//   showUpdateDialog(jsonVal);
// }

// Future<Map<String, dynamic>> loadJsonFromGithub() async {
//   final response = await http.read(Uri.parse(""));
//   return jsonDecode(response);
// }

// // TODO FINISH THIS
// void showUpdateDialog(Map<String, dynamic> jsonVal) {}

// // Future versionJson(String version) async {
// //   return "";
// // }
