import 'package:flutter/material.dart';
import 'package:no_to_do_app/model/nodo_item.dart';
import 'package:no_to_do_app/util/database_client.dart';
import 'package:no_to_do_app/util/date_formartter.dart';

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
                        onLongPress: () => _updateItem(_itemList[index], index),
                        trailing: new Listener(
                          key: new Key(_itemList[index].itemName),
                          child: new Icon(Icons.remove_circle, color: Colors.redAccent,),
                          onPointerDown: (pointerEvent) => _deleteNoDo(_itemList[index].id, index),


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
               Navigator.pop(context);

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
      items.forEach((item) {
        NoDoItem noDoItem = NoDoItem.map(item);
        setState(() {
          _itemList.add(NoDoItem.map(item));
        });
        print("Db items: ${noDoItem.itemName}");
      });
    }

  void _deleteNoDo(int id, int index) async {
    debugPrint('Deleted item');
    await db.deleteItem(id);

    setState(() {
      _itemList.removeAt(index);
    });

  }

  void _updateItem(NoDoItem item, int index) {
    var alert = new AlertDialog(
      title: new Text("Update Item"),
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
                controller:  _textEditingController,
                autofocus: true,
                decoration: new InputDecoration(
                  labelText: "Item",
                  hintText: "eg. Dont buy stuff",
                  icon: new Icon(Icons.update)),
          ))
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () async {
              NoDoItem newItemUpdated = NoDoItem.fromMap({"itemName": _textEditingController.text,
                                                          "dateCreated" : dateFormatted(),
                                                            "id" : item.id
              });

              _handleSubmittedUpdate(index, item);
              await db.updateItem(newItemUpdated);

              setState(() {
                _readNoDoList();
              });

              Navigator.pop(context);

            },
            child: new Text("Update")),
        new FlatButton(onPressed: () => Navigator.pop(context),
                        child: new Text("Cancel"))
      ],
    );
    showDialog(context: context, builder: (_) {
      return alert;
    });
  }

  void _handleSubmittedUpdate(int index, NoDoItem item) {
    setState(() {
        _itemList.removeWhere((element){
          _itemList[index].itemName == item.itemName;
        });
    });
  }
}
