import 'package:flutter/material.dart';
import 'package:kite/feature/game/page/wordle/widgets/alert_dialog.dart';

import 'add.dart';

class LibraryAppointmentPage extends StatelessWidget {
  const LibraryAppointmentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图书馆预约'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            ListTile(
              title: Text("2022年3月15日下午场"),
              subtitle: Text("未入馆"),
              onTap: () async {
                final result = await showAlertDialog(
                  context,
                  title: 'Title',
                  content: [],
                  // actionTextList: ['text'],
                  actionWidgetList: [
                    TextButton(
                      onPressed: () {},
                      child: Text('as'),
                    ),
                  ],
                );
                print(result);
              },
            ),
            ListTile(
              title: Text("2022年3月15日上午场"),
              subtitle: Text("未按预约时间入馆"),
              trailing: Icon(
                Icons.error,
                color: Colors.red,
              ),
            ),
            ListTile(
              title: Text("2022年3月15日上午场"),
              subtitle: Text("已入馆"),
              trailing: Icon(
                Icons.check,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return AddAppointment();
          }));
        },
      ),
    );
  }
}
