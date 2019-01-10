import 'package:flutter/material.dart';
import 'package:no_to_do_app/model/nodo_item.dart';
import 'package:no_to_do_app/util/database_client.dart';

class NoToDoScreen extends StatefulWidget {
  @override
  _NoToDoScreenState createState() => _NoToDoScreenState();
}

class _NoToDoScreenState extends State<NoToDoScreen> {

  var db = new DatabaseHelper();
  final List<NoDoItem> _itemList = <NoDoItem>[];


  @override
  void initState() {
    super.initState();

    _readNoDoList();
  }

  final TextEditingController _textEditingController = new TextEditingController();

  void _handleSubmit(String text) async {
    _textEditingController.clear();

    NoDoItem noDoItem = new NoDoItem(text, DateTime.now().toIso8601String());
    int savedItemId = await db.saveItem(noDoItem);

    NoDoItem addedItem = await db.getItem(savedItemId);
    print("Item saved id: $savedItemId");

    setState(() {
      _itemList.insert(0, addedItem);
    });


  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black87,

      body: Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
                  padding: new EdgeInsets.all(8),
                  reverse: false,
                  itemCount: _itemList.length,
                  itemBuilder: (context, int index){
                    return new Card(
                      color: Colors.white10,
                      child: new ListTile(
                        title: _itemList[index],
                        onLongPress: () => debugPrint(""),
                        trailing: new Listener(
                          key: new Key(_itemList[index].itemName),
                          child: new Icon(Icons.remove_circle, color: Colors.redAccent,),
                          onPointerDown: (pointerEvent) => debugPrint(""),


                        ),
                      ),
                    );

                  })
          ),
          new Divider(
            height: 1,
          )
        ],
      ),

      floatingActionButton: new FloatingActionButton(
        tooltip: "Add Item",
          backgroundColor: Colors.redAccent,
          child: ListTile(
            title: Icon(Icons.add),
          ),
          onPressed: _showFormDialog),

    );
  }

  void _showFormDialog() {
     var alert = new AlertDialog(
       content: new Row(
         children: <Widget>[
           new Expanded(
               child: new TextField(
                 controller: _textEditingController,
                 autofocus: true,
                 decoration: new InputDecoration(
                   labelText: "Item",
                   hintText: "eg. Dont buy stuff",
                   icon: new Icon(Icons.note_add)
                 ),
               ))
         ],
       ),
       actions: <Widget>[
         new FlatButton(
             onPressed: () {
               _handleSubmit(_textEditingController.text);
               _textEditingController.clear();
             },
             child: Text("Save")),
         new FlatButton(
          onPressed: () => Navigator.pop(context),
             child: Text("Cancel"))
       ],
     );
     showDialog(context: context,
     builder: (_) {
       return alert;
     });
  }

    _readNoDoList() async {
      List items = await db.getItems();
      items.forEach((items) {
        NoDoItem noDoItem = NoDoItem.map(items);
        print("Db items: ${noDoItem.itemName}");
      });
    }
}
