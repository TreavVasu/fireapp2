import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
      print('running...');
      return ListTile(
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(document['name']),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.teal,
              ),
              padding: const EdgeInsets.all(10.0),
              child: Text(
                document['votes'].toString(),
              ),
            )
          ],
        ),
        onTap: () {
          //document.reference.updateData({'votes': document['votes'] + 1});
          Firestore.instance.runTransaction((transaction) async {
            DocumentSnapshot freshSnap =
                await transaction.get(document.reference);
            await transaction.update(freshSnap.reference, {
              'votes': freshSnap['votes'] + 1,
            });
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Titile'),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('bandnames').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Loading');
            }
            print(snapshot.data.documents.length.toString());
            return ListView.builder(
              itemExtent: 80.0,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) =>
                  _buildListItem(context, snapshot.data.documents[index]),
            );
          }),
    );
  }
}
