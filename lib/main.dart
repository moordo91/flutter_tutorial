import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

void main() {
  runApp( MaterialApp(
      home: MyApp()
    )
  );
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  getPermission() async {
    var status = await Permission.contacts.status;
    if (status.isGranted) {
      print('Granted');
      var contacts = await ContactsService.getContacts();
      // var newPerson = Contact();
      // newPerson.givenName = 'Mina';
      // newPerson.familyName = 'Song';
      setState(() {
        name = contacts;
      });

    } else if (status.isDenied) {
      print('Denied');
      Permission.contacts.request();
      openAppSettings();
    }
  }

  var total = 0;
  var name = [];

  addOne(newName){
    setState(() {
      name.add(newName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(context: context, builder: (context){
            return DialogUI(addOne: addOne);
          });
        },
      ),
      // appBar: AppBar( title: Text('앱제목'),),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: [IconButton(onPressed: (){getPermission();}, icon: Icon(Icons.contacts))],
        title: Text(
          "Contacts",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: name.length,
        itemBuilder: (c, i){
          return ListTile(
            leading: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Image.asset('assets/dog.png'),
            ),
            title: Text(name[i].givenName ?? 'No Name'),
          );
        }),
      bottomNavigationBar: BottomTab(),
    );
  }
}

class BottomTab extends StatelessWidget {
  const BottomTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.phone),
          Icon(Icons.message),
          Icon(Icons.contact_page)
        ],
      ),
    );
  }
}

class DialogUI extends StatelessWidget {
  DialogUI({super.key, this.addOne});
  final addOne;
  var inputData = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Dialog', style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),),
          SizedBox(height: 10),
          TextField(
            controller: inputData,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: '입력',
            )
          ),
          SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: (){
                      var newContact = Contact();
                      newContact.givenName = inputData.text;
                      ContactsService.addContact(newContact);
                      addOne(newContact);
                      Navigator.pop(context);
                      },
                    child: Text('완료')),
                TextButton(
                  onPressed: (){Navigator.pop(context);},
                  child: Text('취소'),
                ),
              ],
            ),
          )
        ],
      ),
    ),);
  }
}
