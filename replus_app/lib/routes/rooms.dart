import 'dart:convert' show json;
import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:replus_app/api.dart';
import 'package:replus_app/widgets/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:replus_app/widgets/deviceMenu.dart';

final FlutterSecureStorage cache = FlutterSecureStorage();
final chars = "abcdefghijklmnopqrstuvwxyz0123456789";
final floatingKey = Key(randomString(5));
API apiClient;
String _uid;
ShowSnackBar snackBar;
Map deviceList;
List roomList;
Map cacheData;

List<dynamic> groupList;
List<String> groups = ['No group', '1', '2'];
Map roomState = new Map();

String randomString(int strlen) {
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
      groupList = json.decode(cacheData['groupList']);
    } else {
      await apiClient.refreshToken();
      List userData = await apiClient.getUserData();
      roomList = userData[0];
      deviceList = userData[1][0];
      groupList = userData[2];
      await cache.write(key: 'deviceList', value: json.encode(deviceList));
      await cache.write(key: 'roomList', value: json.encode(roomList));
      await cache.write(key: 'groupList', value: json.encode(groupList));
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
  ListItemController({this.scaffoldKey,});

  @override
 _ListItemController createState() => new _ListItemController(scaffoldKey: scaffoldKey,);
}

class _ListItemController extends State<ListItemController> {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TextEditingController roomNameInputController = new TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Map deviceList;
  List roomList;
  bool onDevice = false;
  _ListItemController({this.scaffoldKey});

  void removeRoom(int index) {
    setState(() {
      deviceList.remove(roomList[index]['id']);
      roomState.remove(roomList[index]['id']);
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

  Future confirmAddRoom(Null) async {
    snackBar.show('Adding', true, true);
    String id;
    String tempTitle = roomNameInputController.text;
    roomNameInputController.clear();
    id = await apiClient.roomAdd(tempTitle);
    if (id == 'false') {
      await apiClient.refreshToken();
      id = await apiClient.roomAdd(tempTitle);
    }
    if (id != 'false') {
      addRoom(id, tempTitle);
      snackBar.show('Adding', false, true);
    } else snackBar.show('Adding', false, false);
  }

  void roomAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          title: 'Add room',
          hintText: 'Room name',
          labelText: 'Enter room name',
          caption: 'Room Name:',
          validate: 'Room name cannot be empty',
          icon: Icons.weekend,
          controller: roomNameInputController,
          formKey: formKey,
          onPressed: confirmAddRoom,
        );
      }
    );
  }

  void floatingState(bool state) {
    setState(() => onDevice = state);
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
        key: new Key(randomString(20)),
        itemCount: roomList.length,
        itemBuilder: (BuildContext context, index) {
          Map room = roomList[index];
          List devices = deviceList['${room['id']}'];
          bool isExpanded = roomState.containsKey(room['id']) ? roomState[room['id']] : false;
          return new CreateListItem(index: index, room: room, devices: devices, removeRoom: removeRoom, floatingState: floatingState,isExpanded: isExpanded, scaffoldKey: scaffoldKey,);
        },
      ),
      floatingActionButton: onDevice ? null : Container(
        width: 100.0,
        color: Colors.transparent,
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 50.0,
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.weekend, size: 20.0),
                  Icon(Icons.add, size: 15.0,),
                ],
              ),
              Container(
                height: 40.0,
                width: 1.1,
                color: Colors.lightBlue[200],
                margin: const EdgeInsets.only(left: 10.0, right: 10.0),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Add',),
                  Text('room', style: TextStyle(fontSize: 10.0),textAlign: TextAlign.center,),
                ],
              ),
            ],
          ),
          onPressed: () => onDevice ? {} : roomAddDialog(),
        ),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}

class CreateListItem extends StatefulWidget{
  CreateListItem({
    Key key,
    this.index,
    this.room,
    this.devices,
    this.removeRoom,
    this.floatingState,
    this.isExpanded,
    this.scaffoldKey})
    : super(key : key);
  final Map room;
  final int index;
  final List devices;
  final ValueChanged<int> removeRoom;
  final ValueChanged<bool> floatingState;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isExpanded;

  @override
  _CreateListItem createState() => new _CreateListItem(index: index, room: room, devices: devices, isExpanded: isExpanded, scaffoldKey: scaffoldKey,);
}

class _CreateListItem extends State<CreateListItem> {
  bool isExpanded, onRename, isEnabled, onGroupAdd;
  final Map room;
  final List devices;
  final int index;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final GlobalKey<FormState> titleFormKey = new GlobalKey();
  final GlobalKey<FormState> groupFormKey = new GlobalKey();
  final TextEditingController titleController = new TextEditingController();
  final TextEditingController groupController = new TextEditingController();
  String currentTitle, currentGroup, tempGroup;
  _CreateListItem({this.index, this.room, this.devices, this.isExpanded, this.scaffoldKey});

  void changeTrailing(bool state) => setState(() {
    roomState.update(room['id'], (dynamic _state) => state, ifAbsent: () => state);
    isExpanded = state;
  });

  void changeState(bool state) => setState(() => onRename = state);

  Widget createItem(String title, IconData icon, String subtitle, Function handleTap) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      animationDuration: Duration(milliseconds: 1000),
      splashColor: Colors.blue,
      elevation: 4.0,
      highlightColor: Colors.blue[100],
      color: Colors.white,
      onPressed: handleTap,
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

  Future confirmRoomRename() async {
    if(currentTitle == titleController.text) return setState(() => onRename = !onRename);
    if(titleFormKey.currentState.validate()) {
      setState(()=> isEnabled = !isEnabled);
      snackBar.show('Renaming', true, true);
      bool status = await apiClient.roomEdit(titleController.text, 'undefined', room['id']);
      if (!status) {
        await apiClient.refreshToken();
        status = await apiClient.roomEdit(titleController.text, 'undefined', room['id']);
      }
      snackBar.show('Renaming', false, status);
      if (status) {
        currentTitle = titleController.text;
        roomList[index]['name'] = currentTitle;
        await cache.write(key: 'roomList', value: json.encode(roomList));
        setState(() {isEnabled = !isEnabled; onRename = !onRename;});
      }
    }
  }

  Future confirmRoomDelete() async {
    setState(() => isEnabled = !isEnabled);
    snackBar.show('Deleting', true, true);
    bool status = await apiClient.roomDelete(room['id']);
    if (!status) {
      await apiClient.refreshToken();
      status = await apiClient.roomDelete(room['id']);
    }
    snackBar.show('Deleting', false, status);
    if(status) widget.removeRoom(index);
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
              border: Border.all(
                color: Colors.yellow[700],
                width: 1.0,
              )
            ),
            width: 320,
            height: 152,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 319,
                  height: 102,
                  child: Card(
                    elevation: 0.0,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.warning, size: 53, color: Colors.yellow[700],),
                        SizedBox(
                          width: 318,
                          height: 35,
                          child: Card(
                            elevation: 0.0,
                            color: Colors.white,
                            child: Text('Are you sure want to delete this room?',
                              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Container(
                          height: 1.0,
                          width: 250,
                          color: Colors.grey[300],
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
                            Icon(Icons.cancel, color: Colors.blue,),
                            Text('Cancel', style: TextStyle(color: Colors.blue),),
                          ],
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      FlatButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(Icons.check, color: Colors.red),
                            Text('Ok', style: TextStyle(color: Colors.red),),
                          ],
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          confirmRoomDelete();
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

  Future confirmAddDevice(List data) async {
    Map device = {
      'name': data[0],
      'room': room['id'],
      'type': data[2],
      'owner': _uid,
      'command': new Map(),
      };
    bool status = await apiClient.deviceAdd(
        data[0], data[1], room['id'], data[2]);
    if(!status) {
      await apiClient.refreshToken();
      status = await apiClient.deviceAdd(
        data[0], data[1], room['id'], data[2]);
    }
    if(status) {
      print(deviceList['${room['id']}']);
      deviceList['${room['id']}'].add(device);
      await cache.write(key: 'deviceList', value: json.encode(deviceList));
      return true;
    } else return false;
  }

  Future confirmDeleteDevice(String deviceName, int index) async {
    bool status = await apiClient.deviceDelete(deviceName);
    if(!status) {
      await apiClient.refreshToken();
      status = await apiClient.deviceDelete(deviceName);
    }
    if(status) {
      devices.removeAt(index);
      deviceList['${room['id']}'].toList().removeAt(index);
      await cache.write(key: 'deviceList', value: json.encode(deviceList));
      return true;
    } else return false;
  }

  void showDeviceBottomSheet() {
    widget.floatingState(true);
    scaffoldKey.currentState.showBottomSheet(
      (BuildContext context) {
        return DeviceMenuBottomSheet(devices: devices, room: room['name'], saveDevice: confirmAddDevice, deleteDevice: confirmDeleteDevice,);
      }
    ).closed.whenComplete(() => widget.floatingState(false));
  }

  Widget showDetail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: createItem('Devices', Icons.devices, devices == null ? '0' : '${devices.length}', showDeviceBottomSheet),
        ),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: createItem('Remotes', Icons.settings_remote, '${room['remotes'].length}', null),
        ),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: createItem('Location', Icons.room, 'Location info', null),
        ),
      ],
    );
  }

  Widget createTile() {
    return Card(
      elevation: 2.0,
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        leading: Icon(Icons.weekend),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.group, size: 16,),
                Padding(padding: EdgeInsets.only(right: 2.0),),
                onGroupAdd ? Flexible(
                  child: DropdownButton<String>(
                    value: tempGroup,
                    isExpanded: true,
                    isDense: true,
                    onChanged: (String newGroup) => setState(() => tempGroup = newGroup),
                    items: [{'name':'No Group'}].map((dynamic group) {
                        return new DropdownMenuItem<String>(
                          value: group['name'],
                          child: new Text(group['name']),
                        );
                      }).toList(),
                  ),
                ) : Text(currentGroup,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
                ),
                onGroupAdd ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      onPressed:  () => setState(() {
                        onGroupAdd = !onGroupAdd;
                        isEnabled = !isEnabled;
                        tempGroup = currentGroup;
                        }),
                      icon: Icon(Icons.close),
                      color: Colors.red,
                    ),
                    IconButton(
                      onPressed:  () => setState(() {
                        onGroupAdd = !onGroupAdd;
                        isEnabled = !isEnabled;
                        currentGroup = tempGroup;
                        }),
                      icon: Icon(Icons.check),
                      color: Colors.green,
                    ),
                  ],
                ) : Container(width: 0, height: 0,),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(padding: EdgeInsets.only(right: 18.0),),
                Flexible(
                  child: onRename ? Form(
                    key: titleFormKey,
                    child: TextFormField(
                      controller: titleController,
                      validator: (value) {
                        if(value.isEmpty) return 'Room name cannot be empty!';
                      },
                    )
                  ) : Text(currentTitle,),
                ),
              ],
            ),
          ],
        ),
        children: <Widget>[
          showDetail(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                onPressed: onGroupAdd ? null : () => setState(() {onGroupAdd = !onGroupAdd; isEnabled = !isEnabled;}),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.group_add),
                    Padding(padding: EdgeInsets.only(right: 5.0),),
                    Text('Add to group'),
                  ],
                ),
              ),
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
                      onPressed: () {(onRename && isEnabled) ? changeState(!onRename) : (isEnabled) ? roomDeleteDialog() : null;},
                    ),
                    FlatButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(onRename ? Icons.check : Icons.edit, color: isEnabled ? Colors.blue : Colors.grey, size: 17.0),
                          Text(onRename ? 'Ok' : 'Rename', style: TextStyle(color: isEnabled ? Colors.blue : Colors.grey),),
                        ],
                      ),
                      onPressed: () {(onRename && isEnabled) ? confirmRoomRename() : (isEnabled) ? changeState(!onRename) : null;},
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
        onExpansionChanged: changeTrailing,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    onRename = false;
    isEnabled = true;
    onGroupAdd = false;
    currentTitle = room['name'];
    currentGroup = room.containsKey('group') ? room['group'] : 'No Group';
    titleController.text = currentTitle;
    groupController.text = currentGroup;
    tempGroup = currentGroup;
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
