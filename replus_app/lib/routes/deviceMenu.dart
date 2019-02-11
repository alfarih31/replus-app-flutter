import 'package:flutter/material.dart';
import 'package:replus_app/widgets/expansionTile.dart';
import 'package:replus_app/widgets/customAppBar.dart';
import 'package:replus_app/widgets/flutter_slidable/flutter_slidable.dart';
import 'package:replus_app/widgets/replusRemote.dart';
import 'package:replus_app/widgets/widgets.dart';

class DeviceMenuBottomSheet extends StatefulWidget {
  final List devices;
  final Function saveDevice;
  final Function deleteDevice;
  final Function setupDevice;
  final String room;
  DeviceMenuBottomSheet({
    this.devices,
    this.saveDevice,
    this.deleteDevice,
    this.room,
    this.setupDevice,});

  @override
  _DeviceMenuBottomSheet createState() => new _DeviceMenuBottomSheet(
    devices: devices,
    room: room,
    saveDevice: saveDevice,
    deleteDevice: deleteDevice,
    setupDevice: setupDevice,
  );
}


class _DeviceMenuBottomSheet extends State<DeviceMenuBottomSheet> {
  final ScrollController listViewScroll = ScrollController();
  final GlobalKey<AppExpansionTileState> expansionTile = new GlobalKey();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
  final List devices;
  final Function saveDevice;
  final Function deleteDevice;
  final Function setupDevice;
  final String room;
  final SlidableController deviceSlide = SlidableController();
  ShowSnackBar snackBar;
  _DeviceMenuBottomSheet({
    this.devices,
    this.saveDevice,
    this.deleteDevice,
    this.room,
    this.setupDevice,});

  Future confirmDeviceDelete(int index) async {
    snackBar.show(
      action: 'Deleting',
      active: true,
      status: false,
      type: 'device',
    );
    bool status = await deleteDevice(devices[index]['name'], index);
    snackBar.show(
      action: 'Deleting',
      active: false,
      status: status,
      type: 'device',
    );
    devices.removeAt(index);
  }

  void deviceDeleteDialog(int index, BuildContext context) {
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
                width: 1.0
              )
            ),
            width: 337,
            height: 152,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 336,
                  height: 102,
                  child: Card(
                    elevation: 0.0,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(padding: EdgeInsets.all(2.0),),
                        Icon(Icons.warning, size: 53, color: Colors.yellow[700],),
                        SizedBox(
                          width: 335,
                          height: 35,
                          child: Card(
                            elevation: 0.0,
                            color: Colors.white,
                            child: Text('Are you sure want to delete this device?',
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
                          confirmDeviceDelete(index);
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

  Future confirmDeviceSetup(SaveParams params) async {
    snackBar.show(
      action: 'Setup',
      active: true,
      status: false,
      type: 'device',
    );
    bool status = await setupDevice(
      deviceName: devices[params.index]['name'],
      on: params.on,
      off: params.off,
      index: params.index,
    );
    if(params.on != null) devices[params.index]['command']['on'] = params.on;
    if(params.off != null) devices[params.index]['command']['off'] = params.off;
    snackBar.show(
      action: 'Setup',
      active: false,
      status: status,
      type: 'device',
    );
  }

  Future confirmDeviceAdd({String deviceName, String deviceCode, String type}) async {
    snackBar.show(
      action: 'Adding',
      active: true,
      status: false,
      type: 'device',
    );
    bool status = await widget.saveDevice([
        deviceName,
        deviceCode,
        type,
      ]);
    setState(() {
      snackBar.show(
        action: 'Adding',
        active: false,
        status: status,
        type: 'device',
      );
    });
  }

  Widget replusVision(Map device, int index, BuildContext context) {
    return Slidable(
      controller: deviceSlide,
      delegate: SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      movementDuration: Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.blueGrey,
            ),
            bottom: BorderSide(
              color: Colors.blueGrey,
            ),
          ),
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(7.0),
              child: CircleAvatar(
                backgroundColor: Colors.grey[200],
                minRadius: 5.0,
                maxRadius: 28.0,
                child: Icon(Icons.remove_red_eye,
                  size: 40.0, color: Colors.blue[300],),
              ),
            ),
            Text('${device['name']}', style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.weekend),
                      Padding(padding: EdgeInsets.all(2.0),),
                      Text('Room: $room'),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('Type: ${device['type']}'),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          onTap: () => deviceDeleteDialog(index, context),
          icon: Icons.delete,
        ),
      ],
    );
  }

  Widget buildDevice(Map device, int index, BuildContext context) {
    return device['type'] == 'replus-remote' ? new ReplusRemote(
          device: device,
          index: index,
          roomName: room,
          onCommand: device['command']['on'],
          offCommand: device['command']['off'],
          deviceSlide: deviceSlide,
          saveSetup: confirmDeviceSetup,
          deviceDeleteDialog: deviceDeleteDialog,
        ) : replusVision(device, index, context);
  }

  @override
  void initState() {
    super.initState();
    snackBar = ShowSnackBar(scaffoldKey: scaffoldKey,);
  }
  @override
  Widget build(BuildContext context) {
    int j = 0;
    final List<Widget> mainComponent = [
      AddNewDevice(expansionTile: expansionTile, saveDevice: confirmDeviceAdd, showSnackBar: snackBar.show,),
      ColumnDivider(width: 100, color: Colors.grey[300],),
    ];
    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar(
        onTap: () {
          expansionTile.currentState.collapse();
          deviceSlide.slideOpen ? deviceSlide.activeState.close() : null;
          },
        appBar: AppBar(
          title: Text('Devices', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white,),),
          leading: Icon(Icons.devices, size: 45, color: Colors.white,),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Room', style: TextStyle(color: Colors.white, fontSize: 13.0)),
                    Icon(Icons.weekend, color: Colors.white,),
                    Text('Name', style: TextStyle(color: Colors.white, fontSize: 13.0)),
                  ],
                ),
                RowDivider(
                  height: 40.0,
                  color: Colors.white,
                ),
                Text('$room', style: TextStyle(color: Colors.white, fontSize: 15.0)),
                Padding(padding: EdgeInsets.all(5.0)),
              ],
            ),
          ],
          backgroundColor: Colors.blue[450],
        ),
      ),
      body: Container(
        height: 600,
        color: Colors.white,
        child: GestureDetector(
          onTap: () {
            expansionTile.currentState.collapse();
            deviceSlide.slideOpen ? deviceSlide.activeState.close() : null;
            },
          child: ListView.builder(
            controller: listViewScroll,
            scrollDirection: Axis.vertical,
            itemCount: devices != null ? devices.length*2+2 : 2,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              if (i < 2) return mainComponent[i];
              else {
                if(i%2 == 0){
                  j += 1;
                  return buildDevice(devices[j-1], j-1, context);
                }
                else return Padding(padding: EdgeInsets.all(5.0),);
              }
              }
          ),
        )
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}

class AddNewDevice extends StatefulWidget {
  final GlobalKey<AppExpansionTileState> expansionTile;
  final Function showSnackBar;
  final Function saveDevice;
  AddNewDevice({this.expansionTile, this.showSnackBar, this.saveDevice});

  @override
  _AddNewDevice createState() => new _AddNewDevice();
}

class _AddNewDevice extends State<AddNewDevice> {

  final TextEditingController deviceNameInput = TextEditingController();
  final TextEditingController activationCodeInput = TextEditingController();
  final GlobalKey<FormState> formKey = new GlobalKey();
  int radioVal;
  bool isExpanded;
  String type;

  Widget buildDeviceNameInput() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Enter device name',
        hintText: 'Device name',
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      maxLength: 6,
      controller: deviceNameInput,
      keyboardType: TextInputType.text,
      validator: (value) {
        if(value.isEmpty) return 'Device name cannot be empty';
        else if(type == 'replus-remote') {
            if(value.length != 4) return 'Replus-remote name\'s have 4 characters long';
        }
      },
    );
  }

  Widget buildActivationInput() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Enter device activation code',
        hintText: 'Activation code',
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      obscureText: true,
      controller: activationCodeInput,
      keyboardType: TextInputType.text,
      validator: (value) {
        if(value.isEmpty) return 'Activation code cannot be empty';
      },
    );
  }

  // Handle choice for radio button
  void handleChoice(int choice) => setState(() {
    radioVal = choice;
    switch(radioVal) {
    case 0:
      type = 'replus-remote';
      break;
    case 1:
      type = 'replus-vision';
      break;
    }
  });

  void handleClear(){
    deviceNameInput.clear();
    activationCodeInput.clear();
    FocusScope.of(context).requestFocus(FocusNode());
    handleChoice(-1);
  }

  Future confirmDeviceAdd() async {
    final String deviceName = deviceNameInput.text;
    final String deviceCode = activationCodeInput.text;
    if (formKey.currentState.validate()){
      await widget.saveDevice(
        deviceName:deviceName,
        deviceCode:deviceCode,
        type:type,
      );
      handleClear();
    }
  }

  @override
  void initState() {
    super.initState();
    radioVal = -1;
    isExpanded = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Colors.green,
          width: 3.5,
        ),
        color: Colors.transparent,
      ),
      margin: EdgeInsets.only(left: 7.0, right: 7.0, top: 10.0),
      child: AppExpansionTile(
        key: widget.expansionTile,
        leading: Icon(Icons.devices, color: Colors.blue, size: 30.0,),
        backgroundColor: Colors.transparent,
        title: Text('Add new device',),
        trailing: Icon(isExpanded ? Icons.cancel : Icons.add_circle_outline, color: Colors.green, size: 30.0,),
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 7.0, right: 7.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(padding:EdgeInsets.all(2.0)),
                      buildActivationInput(),
                      Padding(padding:EdgeInsets.all(5.0)),
                      buildDeviceNameInput(),
                      Padding(padding:EdgeInsets.all(2.0)),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('Device Type:'),
                    Radio(
                      value: 0,
                      groupValue: radioVal,
                      onChanged: handleChoice,
                    ),
                    Text('Replus-remote'),
                    Padding(padding: EdgeInsets.all(2.0),),
                    Radio(
                      value: 1,
                      groupValue: radioVal,
                      onChanged: handleChoice,
                    ),
                    Text('Replus-vision'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      onPressed: handleClear,
                      child: Icon(Icons.clear_all, color: Colors.red, size: 40,),
                    ),
                    FlatButton(
                      onPressed: confirmDeviceAdd,
                      child: Icon(Icons.save, color: Colors.blue, size: 40,),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
        onExpansionChanged: (state) => setState(() => isExpanded = !isExpanded),
      ),
    );
  }
}