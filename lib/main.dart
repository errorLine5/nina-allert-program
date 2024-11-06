import 'package:flutter/material.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class MyItem {
  final String title;
  String content; // Rendi il campo content modificabile

  MyItem(this.title, this.content);
}

class Error {
  final IconData icona;
  final String object;
  final String content;

  Error(this.icona, this.object, this.content);
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  final List<MyItem> items = [
    MyItem("IP address", "192.168.1.30"),
    MyItem("Topic", "notifiche varie"),
    MyItem("Tags", "lista di tag"),
  ];

  final List<Error> errors = [
    Error(Icons.camera, "camera", "is not working"),
    Error(Icons.radar, "focuser", "is broken"),
    Error(Icons.mouse, "mount", "is broken"),
  ];

  ScrollController scrollView = ScrollController();
  late TabController tabView;

  @override
  void initState() {
    tabView = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: NestedScrollView(
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
                    return FlexibleSpaceBar(
                      background: Container(
                        height: height <= 30 ? 30 : height,
                        child: Image.network(
                          'https://static.vecteezy.com/ti/foto-gratuito/t2/37916193-ai-generato-latteo-modo-galassia-come-visto-a-partire-dal-terra-denso-cluster-di-stelle-e-celeste-polvere-la-creazione-di-un-incandescente-intricato-modello-contro-il-buio-cielo-concetto-di-astronomia-spazio-galassia-foto.jpeg',
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
          body: TabBarView(
            controller: tabView,
            children: [
              ListView.builder(
                itemCount: errors.length,
                itemBuilder: (context, index) {
                  final item = errors[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red[900],
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            item.icona,
                            color: Colors.grey,
                          ),
                          Text(
                            item.object,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              fontSize: 18.0,
                              fontFamily: 'Verdana',
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(item.content,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15.0,
                                fontFamily: 'Verdana',
                              )),
                        ],
                      ),
                    ),
                  );
                },
              ),
              ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  TextEditingController contentController =
                      TextEditingController(text: item.content);

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
                            controller: contentController,
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
