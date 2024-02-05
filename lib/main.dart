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
      for (int i = 0; i < contacts.length; i++) {
        print(contacts[i].phones?[0].label);
        print(contacts[i].phones?[0].value);
      }
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
        child: Icon(Icons.add),
      ),
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
            title: Text(name[i].givenName + ' ' + name[i].familyName ?? 'No Name'),
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
  var givenName = TextEditingController();
  var familyName = TextEditingController();
  var phoneNumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('New Person', style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),),
          SizedBox(height: 20),
          TextField(
            controller: givenName,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'First Name',
            )
          ),
          SizedBox(height: 30),
          TextField(
            controller: familyName,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Second Name',
            )
          ),
          SizedBox(height: 30),
          TextField(
            controller: phoneNumber,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Phone Number',
            )
          ),
          SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () async {
                      var newContact = Contact();
                      newContact.givenName = givenName.text;
                      newContact.familyName = familyName.text;
                      newContact.phones = [Item(label: "home", value: phoneNumber.text)];
                      print(newContact.phones?[0].label);
                      ContactsService.addContact(newContact);
                      addOne(newContact);
                      Navigator.pop(context);
                      },
                    child: Text('OK')),
                TextButton(
                  onPressed: (){Navigator.pop(context);},
                  child: Text('Cancel'),
                ),
              ],
            ),
          )
        ],
      ),
    ),);
  }
}
