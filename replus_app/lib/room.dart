import 'dart:convert' show json;
import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:replus_app/api.dart';
import 'package:replus_app/widgets/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterSecureStorage cache = FlutterSecureStorage();
final chars = "abcdefghijklmnopqrstuvwxyz0123456789";
API apiClient;
String _uid;
ShowSnackBar snackBar;
Map cacheData;
List roomList;
Map deviceList;

String RandomString(int strlen) {
  Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
  String result = "";
  for (var i = 0; i < strlen; i++) {
    result += chars[rnd.nextInt(chars.length)];
  }
  return result;
}
class MainRoom extends StatefulWidget{
  MainRoom({this.uid});
  final String uid;

  @override
  _MainRoom createState() => new _MainRoom(uid: uid);
}

class _MainRoom extends State<MainRoom> with AutomaticKeepAliveClientMixin<MainRoom> {
  _MainRoom({this.uid});
  final String uid;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  bool initDone = false;

  Future<bool> init() async {
    apiClient = new API(uid: uid);
    snackBar = new ShowSnackBar(scaffoldKey: scaffoldKey);
    _uid = uid;
    cacheData = await cache.readAll();
    if(cacheData['fetched'] == '1') {
      deviceList= json.decode(cacheData['deviceList']);
      roomList = json.decode(cacheData['roomList']);
    } else {
      await apiClient.refreshToken();
      List userData = await apiClient.getUserData();
      roomList = userData[0];
      deviceList = userData[1][0];
      await cache.write(key: 'deviceList', value: json.encode(deviceList));
      await cache.write(key: 'roomList', value: json.encode(roomList));
      await cache.write(key: 'fetched', value: '1');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: new FutureBuilder<bool>(
        future: init(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            if(snapshot.hasData){
              return new ListItemController(scaffoldKey: scaffoldKey,);
            }
          } else return Container(
            color: Colors.white70,
            width: 600,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                Padding(padding: EdgeInsets.all(5.0),),
                Text('Fetching user data...', style: TextStyle(fontSize: 12.0, color: Colors.blueGrey),),
              ],
            ),
          );
        }
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ListItemController extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  ListItemController({this.scaffoldKey});

  @override
 _ListItemController createState() => new _ListItemController(scaffoldKey: scaffoldKey,);
}

class _ListItemController extends State<ListItemController> {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TextEditingController roomNameInputController = new TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  _ListItemController({this.scaffoldKey});

  void removeRoom(int index) {
    setState(() {
      deviceList.remove(roomList[index]['id']);
      roomList.removeAt(index);
      cache.write(key: 'roomList', value: json.encode(roomList));
      cache.write(key: 'deviceList', value: json.encode(deviceList));
    });
  }

  void addRoom(String roomID, String roomName) {
    Map roomData = {
      'owner': _uid,
      'name': roomName,
      'id': roomID,
      'remotes':[],
      'home': {},
      'group': null,
    };
    setState(() {
      roomList.add(roomData);
      cache.write(key: 'roomList', value: json.encode(roomList));
      });
  }

  Future confirmAdd() async {
    snackBar.show('Adding', true);
    String roomID;
    String tempTitle = roomNameInputController.text;
    roomNameInputController.clear();
    try {
      roomID = await apiClient.roomAdd(tempTitle);
    } catch(err) {
      await apiClient.refreshToken();
      roomID = await apiClient.roomAdd(tempTitle);
    }
    snackBar.show('Adding', false);
    addRoom(roomID, tempTitle);
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
              borderRadius: BorderRadius.circular(25.0),
            ),
            width: 370.0,
            height: 230.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 370,
                  height: 55,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0),
                      ),
                      color: Colors.blue[300],
                    ),
                    //color: Colors.blue[300],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(padding: EdgeInsets.all(4.0),),
                        Icon(Icons.weekend, size: 45, color: Colors.white,),
                        Padding(padding: EdgeInsets.all(4.0),),
                        Material(
                          color: Colors.transparent,
                          child: Text('Add room', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white,),),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.transparent,
                  width: 340.0,
                  height: 175.0,
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(padding: EdgeInsets.all(5.0),),
                          Row(
                            children: <Widget>[Text('Room Name:', style: TextStyle(color: Colors.blue, fontSize: 22.0),)],
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Please type your desired room name...',
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                )
                              ),
                            controller: roomNameInputController,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if(value.isEmpty) return 'Please type desired room name';
                            },
                          ),
                        ],
                      ),
                    ),
                    floatingActionButton: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            IconButton(
                              highlightColor: Colors.blueGrey[300],
                              icon: Icon(Icons.clear, color: Colors.red, size: 35.0),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Padding(padding: EdgeInsets.all(12.0),),
                            IconButton(
                              highlightColor: Colors.blueGrey[300],
                              icon: Icon(Icons.save, color: Colors.blue, size: 35.0,),
                              onPressed: () {
                                if(formKey.currentState.validate()) {
                                  Navigator.of(context).pop();
                                  confirmAdd();
                                }
                              },
                            ),
                          ],
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
  void dispose() {
    roomNameInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: new ListView.builder(
        key: new Key(RandomString(20)),
        itemCount: roomList.length,
        itemBuilder: (BuildContext context, index) {
          Map room = roomList[index];
          List devices = deviceList['${room['id']}'];
          return new CreateListItem(index: index, room: room, devices: devices, removeRoom: removeRoom, scaffoldKey: scaffoldKey,);
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
  CreateListItem({Key key, this.index, this.room, this.devices, this.removeRoom, this.scaffoldKey})
    : super(key : key);
  final Map room;
  final int index;
  final List devices;
  final ValueChanged<int> removeRoom;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _CreateListItem createState() => new _CreateListItem(index: index, room: room, devices: devices, scaffoldKey: scaffoldKey,);
}

class _CreateListItem extends State<CreateListItem> {
  bool isExpanded, onRename, isEnabled;
  final Map room;
  final List devices;
  final int index;
  double iPos = 0.0;
  double height = 250.0;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TextEditingController titleController = new TextEditingController();
  String currentTitle;
  _CreateListItem({this.index, this.room, this.devices, this.scaffoldKey});

  void changeTrailing(bool val) => setState(() => isExpanded = val);

  void changeState(bool state) => setState(() => onRename = state);

  Widget createItem(String title, IconData icon, String subtitle, Function handleTap) {
    return GestureDetector(
      onTap: handleTap,
      child: Column(
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
      ),
    );
  }

  Future confirmRename() async {
    if(currentTitle == titleController.text) return changeState(!onRename);
    setState(()=> isEnabled = !isEnabled);
    snackBar.show('Renaming', true);
    try {
      snackBar.show('Renaming',
                !await apiClient.roomEdit(titleController.text, 'undefined', room['id']));
    } catch(err) {
      await apiClient.refreshToken();
      snackBar.show('Renaming',
                !await apiClient.roomEdit(titleController.text, 'undefined', room['id']));
    }
    currentTitle = titleController.text;
    roomList[index]['name'] = currentTitle;
    await cache.write(key: 'roomList', value: json.encode(roomList));
    setState(() {isEnabled = !isEnabled; onRename = !onRename;});
  }

  Future confirmDelete() async {
    setState(() => isEnabled = !isEnabled);
    snackBar.show('Deleting', true);
    try{
      snackBar.show('Deleting',
                !await apiClient.roomDelete(room['id']));
    } catch(err) {
      await apiClient.refreshToken();
      snackBar.show('Deleting',
                !await apiClient.roomDelete(room['id']));
    }
    widget.removeRoom(index);
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

  void showDeviceBottomSheet() {
    scaffoldKey.currentState.showBottomSheet(
      (BuildContext context) {
        print(height);
        return new GestureDetector(
          onVerticalDragStart: (DragStartDetails details) {
            iPos = details.globalPosition.dx;
          },
          onVerticalDragUpdate: (DragUpdateDetails details) {
            double distance = details.globalPosition.dx - iPos;
            double addition = distance/100;
            showDeviceBottomSheet();
          },
          onVerticalDragEnd: (DragEndDetails details) {
            iPos = 0.0;
            setState(() => height);
          },
          child: Container(
            color: Colors.transparent,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
                color: Colors.white
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 55,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                        color: Colors.blue[300],
                      ),
                      //color: Colors.blue[300],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(padding: EdgeInsets.all(4.0),),
                          Icon(Icons.weekend, size: 45, color: Colors.white,),
                          Padding(padding: EdgeInsets.all(4.0),),
                          Material(
                            color: Colors.transparent,
                            child: Text('Add room', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white,),),
                          ),
                        ],
                      ),
                    ),
                  ),
                  devices != null ? ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Text(devices[index]['room']),
                      );
                    },
                  ) : Container(width: 0,height: 0,),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget showDetail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Card(
          child: createItem('Devices', Icons.devices, devices == null ? '0' : '${devices.length}', showDeviceBottomSheet),
        ),
        Card(
          child: createItem('Remotes', Icons.settings_remote, '${room['remotes'].length}', null),
        ),
        Card(
          child: createItem('Location', Icons.room, 'Location info', null),
        ),
      ],
    );
  }

  Widget createTile() {
    return Card(
      elevation: 2.0,
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
                      onPressed: () {(onRename && isEnabled) ? confirmRename() : (isEnabled) ? changeState(!onRename) : null;},
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
  void initState() {
    super.initState();
    isExpanded = false;
    onRename = false;
    isEnabled = true;
    currentTitle = room['name'];
    titleController.text = currentTitle;
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return createTile();
  }
}
