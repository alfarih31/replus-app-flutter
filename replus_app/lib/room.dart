import 'package:flutter/material.dart';
import 'package:replus_app/api.dart';
import 'package:replus_app/widgets/widgets.dart';

API apiClient;
String _uid;
ShowSnackBar snackBar;

class MainRoom extends StatelessWidget {
  MainRoom({this.uid, this.userData});
  final String uid;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final List userData;

  Future<void> init() async {
    apiClient = new API(uid: uid);
    _uid = uid;
    snackBar = new ShowSnackBar(scaffoldKey: scaffoldKey);
    await apiClient.initDone;
    return;
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<void>(
      future: init(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
            List roomList = userData[0];
            Map deviceList = userData[1][0];
            return new ListItemController(roomList: roomList, deviceList: deviceList, scaffoldKey: scaffoldKey,);
        } else return Center(
          child: new CircularProgressIndicator(),
          );
      }
    );
  }
}

class ListItemController extends StatefulWidget {
  final List roomList;
  final Map deviceList;
  final GlobalKey<ScaffoldState> scaffoldKey;
  ListItemController({this.roomList, this.deviceList, this.scaffoldKey});

  @override
 _ListItemController createState() => new _ListItemController(deviceList: deviceList, roomList: roomList, scaffoldKey: scaffoldKey,);
}

class _ListItemController extends State<ListItemController> {
  final List roomList;
  final Map deviceList;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TextEditingController roomNameInputController = new TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  _ListItemController({this.deviceList, this.roomList, this.scaffoldKey});

  void removeItem(int index) {
    setState(() {
      deviceList.remove(roomList[index]['id']);
      roomList.removeAt(index);
    });
  }

  void addItem(String roomID, String roomName) {
    Map roomData = {
      'owner': _uid,
      'name': roomName,
      'id': roomID,
      'remotes':[],
      'home': {},
      'group': null,
    };
    setState(() => roomList.add(roomData));
  }

  Future confirmSave() async {
    snackBar.show('Adding', true);
    String roomID = await apiClient.roomAdd(roomNameInputController.text);
    snackBar.show('Adding', false);
    addItem(roomID, roomNameInputController.text);
  }

  void roomAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white10,
          alignment: AlignmentDirectional.center,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            width: 370.0,
            height: 230.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 369,
                  height: 55,
                  child: Card(
                    color: Colors.blue[300],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(padding: EdgeInsets.all(4.0),),
                        Icon(Icons.weekend, size: 45, color: Colors.white,),
                        Padding(padding: EdgeInsets.all(4.0),),
                        Text('Add room', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.white10,
                  width: 340.0,
                  height: 165.0,
                  child: Scaffold(
                    body: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[Text('Room Name:', style: TextStyle(color: Colors.blue, fontSize: 22.0),)],
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Please input your desired room name...',
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                )
                              ),
                            controller: roomNameInputController,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if(value.isEmpty) return 'Please input desired room name';
                            },
                          ),
                        ],
                      ),
                    ),
                    floatingActionButton: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.clear, color: Colors.blue, size: 35.0),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Padding(padding: EdgeInsets.all(3.0),),
                        IconButton(
                          icon: Icon(Icons.save, color: Colors.blue, size: 35.0,),
                          onPressed: () {
                            if(formKey.currentState.validate()) {
                              Navigator.of(context).pop();
                              confirmSave();
                            }
                          },
                        ),
                      ],
                    ),
                    resizeToAvoidBottomPadding: false,
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      body: new ListView.builder(
        itemCount: roomList.length,
        itemBuilder: (ctxt, index) {
          final Map room = roomList[index];
          List devices = deviceList['${room['id']}'];
          return CreateListItem(index: index, room: room, devices: devices, removeItem: removeItem, scaffoldKey: scaffoldKey,);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => roomAddDialog(),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}

class CreateListItem extends StatefulWidget{
  final Map room;
  final int index;
  final List devices;
  final ValueChanged<int> removeItem;
  final GlobalKey<ScaffoldState> scaffoldKey;
  CreateListItem({this.index, this.room, this.devices, this.removeItem, this.scaffoldKey});

  @override
  _CreateListItem createState() => new _CreateListItem(index: index, room: room, devices: devices, scaffoldKey: scaffoldKey,);
}

class _CreateListItem extends State<CreateListItem> {
  bool isExpanded, onRename, isEnabled;
  final Map room;
  final List devices;
  final int index;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TextEditingController titleController = new TextEditingController();
  String currentTitle;
  _CreateListItem({this.index, this.room, this.devices, this.scaffoldKey});

  @override
  void initState() {
    super.initState();
    isExpanded = false;
    onRename = false;
    isEnabled = true;
    currentTitle = room['name'];
    titleController.text = currentTitle;
  }

  void changeTrailing(bool val) => setState(() => isExpanded = val);

  void changeState(bool state) => setState(() => onRename = state);

  Widget createItem(String title, IconData icon, String subtitle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(title, style:TextStyle(fontWeight: FontWeight.bold)),
            Icon(icon, size: 50.0),
            Text(subtitle),
          ],
        )
      ],
    );
  }

  Widget showDetail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Card(
          child: createItem('Devices', Icons.devices, devices == null ? '0' : '${devices.length}'),
        ),
        Card(
          child: createItem('Remotes', Icons.settings_remote, '${room['remotes'].length}'),
        ),
        Card(
          child: createItem('Location', Icons.room, 'Location info'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future confirmChange() async {
    if(currentTitle == titleController.text) return changeState(!onRename);
    setState(() => isEnabled = !isEnabled);
    snackBar.show('Renaming', true);
    snackBar.show('Renaming',
                !await apiClient.roomEdit(titleController.text, 'undefined', room['id']));
    currentTitle = titleController.text;
    setState(() {onRename = !onRename; isEnabled = !isEnabled;});
  }

  Future confirmDelete() async {
    setState(() => isEnabled = !isEnabled);
    snackBar.show('Deleting', true);
    snackBar.show('Deleting',
                !await apiClient.roomDelete(room['id']));
    widget.removeItem(index);
    setState(() => isEnabled = !isEnabled);
  }

  void roomDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white10,
          alignment: AlignmentDirectional.center,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            width: 320,
            height: 187,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 319,
                  height: 138,
                  child: Card(
                    elevation: 0.0,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(padding: EdgeInsets.all(2.0),),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: RawMaterialButton(
                            shape: CircleBorder(),
                            elevation: 0.5,
                            child: Icon(Icons.warning, size: 53, color: Colors.yellow[700],),
                            onPressed: () {},
                            fillColor: Colors.yellow[500],
                          ),
                        ),
                        SizedBox(
                          width: 318,
                          height: 46,
                          child: Card(
                            elevation: 0.0,
                            color: Colors.white,
                            child: Text('Are you sure want to delete this room?',
                              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(Icons.cancel, color: Colors.red,),
                            Text('Cancel', style: TextStyle(color: Colors.red),),
                          ],
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      FlatButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(Icons.check, color: Colors.blue,),
                            Text('Ok', style: TextStyle(color: Colors.blue),),
                          ],
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          confirmDelete();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget createTile() {
    return Card(
      child: Column(
        children: <Widget>[
          ExpansionTile(
            trailing: isExpanded ? Icon(Icons.keyboard_arrow_down) : Icon(Icons.keyboard_arrow_up),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.weekend),
                Padding(padding: EdgeInsets.all(5.0),),
                Flexible(
                  child: onRename ? TextFormField(
                    controller: titleController,
                    ) : Text(currentTitle, style: TextStyle(fontWeight: FontWeight.bold,),),
                ),
              ],
            ),
            children: <Widget>[
              showDetail(),
              ButtonTheme.bar(
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(onRename ? Icons.cancel : Icons.delete, color: isEnabled ? Colors.red: Colors.grey, size: 17.0),
                          Text(onRename ? 'Cancel' : 'Delete', style: TextStyle(color: isEnabled ? Colors.red : Colors.grey)),
                        ],
                      ),
                      onPressed: () {(onRename && isEnabled) ? changeState(!onRename) : (isEnabled) ? roomDeleteDialog(): null;},
                    ),
                    FlatButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(onRename ? Icons.check : Icons.edit, color: isEnabled ? Colors.blue : Colors.grey, size: 17.0),
                          Text(onRename ? 'Ok' : 'Rename', style: TextStyle(color: isEnabled ? Colors.blue : Colors.grey),),
                        ],
                      ),
                      onPressed: () {(onRename && isEnabled) ? confirmChange() : (isEnabled) ? changeState(!onRename) : null;},
                    )
                  ],
                ),
              ),
            ],
            onExpansionChanged: changeTrailing,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext ctxt) {
    return createTile();
  }
}
