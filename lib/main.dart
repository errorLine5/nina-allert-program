import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'background.dart';

/// Global service instance for background tasks
late FlutterBackgroundService service;

/// Initialize app and background service
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  service = await initializeService();
  runApp(const MyApp());
}

/// creates an instance of the _MyAppState state class,
/// which handles dynamic data and user interface
/// construction.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// Model class for configuration items (IP, Port, etc.).
/// The class allows you to create objects with a fixed title.
(title) and editable content (content)
class MyItem {
  final String title;
  String content; // Mutable to allow user edits

  // Constructor to initialize MyItem with title and content
  MyItem(this.title, this.content);
}

/// Model class for error/alert items
class Error {
  final IconData icona;
  final String object;
  final String content;
  final DateTime timestamp;
  final Color color;

  // Constructor to initialize Error object with relevant details
  Error(this.icona, this.object, this.content, this.timestamp, this.color);
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  // Default configuration items
  final List<MyItem> items = [
    MyItem("IP address", "test.mosquitto.org"),
    MyItem("Port", "1883"),
    MyItem("Topic", "test"),
    MyItem("Tags", ""),
  ];

  // List to store error/alert messages
  final List<Error> errors = [];

  // Controllers for scrolling and tabs
  ScrollController scrollView = ScrollController();
  late TabController tabView;

  /// initialize the widget with a TabController to 
  /// manage a tabbed view and set up a listener to
  /// receive errors from the background service.
  @override
  void initState() {
    // Initialize tab controller with 2 tabs
    tabView = TabController(length: 2, vsync: this);

    // Listen for errors from background service
    service.on('updateErrors').listen((event) {
      if (event == null) return;

      final errorData = event as Map<String, dynamic>;
      setState(() {
        print(errorData);
        // Add new error to the list with appropriate icon and color
        errors.add(Error(
            Icons.error_outline,
            errorData['object'] ?? 'unknown',
            errorData['content'] ?? 'unknown error',
            DateTime.now(),
            errorData['object'] == null ? Colors.red : Colors.green));
      });
    });

    super.initState();
  }

  /// Contains all the logic intended for the graphical
  /// representation of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
      home: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        // Show save button only on configuration tab
        floatingActionButton: tabView.index == 1
            ? FloatingActionButton(
                onPressed: () async {
                  // Save all configuration items to persistent storage
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('ip_address', items[0].content);
                  await prefs.setString('port', items[1].content);
                  await prefs.setString('topic', items[2].content);
                  await prefs.setString('tags', items[3].content);

                  // Restart background service to apply new settings
                  service.invoke('stopService');
                  await Future.delayed(const Duration(seconds: 1));
                  service = await initializeService();
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.save),
              )
            : null,
        body: NestedScrollView(
          // Custom scrollable app bar with background image
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                title: Container(
                  margin: const EdgeInsets.only(bottom: 1.0),
                  padding: const EdgeInsets.all(8.0),
                  constraints: const BoxConstraints(
                    minHeight: 40.0,
                  ),
                  child: const Text(
                    'n.a.p. \nnina alert application',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    double height = constraints.maxHeight;
                    double minHeight = 100;
                    double adjustedHeight =
                        height <= minHeight ? minHeight : height;
                    return FlexibleSpaceBar(
                      background: Container(
                        height: adjustedHeight,
                        child: Image.asset(
                          'assets/nebula.webp',
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
                bottom: PreferredSize(
                  preferredSize: Size(double.infinity, 30),
                  child: Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: tabView,
                      tabs: const [
                        Tab(
                          icon: Icon(
                            Icons.warning_amber_outlined,
                            color: Colors.red,
                          ),
                          text: 'errors',
                        ),
                        Tab(
                          icon: Icon(
                            Icons.settings,
                            color: Colors.grey,
                          ),
                          text: 'configuration',
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          // Main content area with two tabs
          body: TabBarView(
            controller: tabView,
            children: [
              // First tab: Error/Alert list
              ListView.builder(
                itemCount: errors.length + 1,
                itemBuilder: (context, index) {
                  // First item is the clear all button (if errors exist)
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: errors.isEmpty
                          ? const SizedBox.shrink()
                          : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8D0F0F),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  errors.clear();
                                  service.invoke('silence');
                                });
                              },
                              icon: const Icon(Icons.delete_sweep,
                                  color: Colors.white),
                              label: const Text(
                                'Clear All Alerts',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    );
                  }

                  // Display error cards
                  final item = errors[index - 1];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  item.icona,
                                ),
                                Text(
                                  item.object,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    fontFamily: 'Verdana',
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(item.content,
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      fontFamily: 'Verdana',
                                    )),
                              ],
                            ),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.delete, color: Colors.white70),
                            onPressed: () {
                              setState(() {
                                service.invoke('silence');
                                errors.removeAt(index - 1);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Second tab: Configuration items
              ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              fontSize: 18.0,
                              fontFamily: 'Verdana',
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextField(
                            decoration: InputDecoration(
                              hintText: item.content,
                            ),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15.0,
                              fontFamily: 'Verdana',
                            ),
                            onChanged: (newContent) {
                              setState(() {
                                item.content = newContent;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
