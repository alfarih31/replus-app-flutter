import 'package:flutter/material.dart';
import 'package:replus_app/widgets/expansionTile.dart';
import 'package:replus_app/widgets/customAppBar.dart';
import 'package:replus_app/widgets/flutter_slidable/flutter_slidable.dart';

class DeviceMenuBottomSheet extends StatefulWidget {
  final List devices;
  final TextEditingController deviceNameInput = TextEditingController();
  final TextEditingController activationCodeInput = TextEditingController();
  final saveDevice;
  final deleteDevice;
  final String room;
  DeviceMenuBottomSheet({this.devices, this.saveDevice, this.deleteDevice, this.room,});
  @override
  _DeviceMenuBottomSheet createState() => new _DeviceMenuBottomSheet();
}

class _DeviceMenuBottomSheet extends State<DeviceMenuBottomSheet> {
  final ScrollController listViewScroll = ScrollController();
  final GlobalKey<AppExpansionTileState> expansionTile = new GlobalKey();
  final GlobalKey<FormState> formKey = new GlobalKey();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
  SlidableController deviceSlide;
  List textField;
  List<Widget> mainComponent;
  String type;
  bool isExpanded, isOpened;
  int radioVal, j;

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
      controller: widget.deviceNameInput,
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
      controller: widget.activationCodeInput,
      keyboardType: TextInputType.text,
      validator: (value) {
        if(value.isEmpty) return 'Activation code cannot be empty';
      },
    );
  }

  void showSnackBar(String action, bool active, bool stat){
    final snackbar =  active ?
                  SnackBar(
                    backgroundColor: Colors.blueGrey,
                    content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('$action device...'),
                      CircularProgressIndicator(),
                      ],
                    ),
                  ) :
                  SnackBar(
                    backgroundColor: Colors.blueGrey,
                    duration: Duration(seconds: 2),
                    content: Text(stat ? '$action device success' : '$action device failed'),
                    action: SnackBarAction(
                      label: 'OK',
                      onPressed: () {},
                    ),
                  );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void handleOpen(bool isOpen) {
    isOpened = isOpen;
  }

  void handleChoice(int choice){
    setState(() {
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
  }

  void handleClear(){
    widget.deviceNameInput.clear();
    widget.activationCodeInput.clear();
    FocusScope.of(context).requestFocus(FocusNode());
    handleChoice(-1);
  }

  Future confirmDeviceDelete(int index) async {
    showSnackBar('Deleting', true, true);
    bool status = await widget.deleteDevice(widget.devices[index]['name'], index);
    showSnackBar('Deleting', false, status);
    setState(() {});
  }

  void deviceDeleteDialog(int index) {
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
                        onPressed: () => setState(() => Navigator.of(context).pop()),
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

  Future confirmDeviceAdd() async {
    String deviceName = widget.deviceNameInput.text;
    String deviceCode = widget.activationCodeInput.text;
    if (formKey.currentState.validate()){
      showSnackBar('Adding', true, true);
      bool status = await widget.saveDevice([
          deviceName,
          deviceCode,
          type,
        ]);
      showSnackBar('Adding', false, status);
      handleClear();
    }
  }

  Widget buildDevice(Map device, int index) {
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
              padding: EdgeInsets.only(left: 10.0, right: 7.0),
              child: CircleAvatar(
                backgroundColor: Colors.grey[200],
                minRadius: 5.0,
                maxRadius: 35,
                child: Icon(device['type'] == 'replus-remote' ?
                  Icons.settings_remote : Icons.remove_red_eye,
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
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
                              Text('Room: ${widget.room}'),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text('Type: ${device['type']}'),
                            ],
                          ),
                          Padding(padding: EdgeInsets.all(5.0),),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.repeat_one),
                              Padding(padding: EdgeInsets.all(2.0),),
                              Column(
                                children: <Widget>[
                                  Text('On Command: ${device['command']['on']}'),
                                  Text('Off Command: ${device['command']['off']}'),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ],
        )
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Setup',
          color: Colors.blue[300],
          onTap: null,
          icon: Icons.settings,
        ),
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          onTap: () => deviceDeleteDialog(index),
          icon: Icons.delete,
        ),
      ],
    );
  }

  @override
  void initState(){
    isExpanded = false;
    j = 0;
    radioVal = -1;
    isOpened = false;
    deviceSlide = SlidableController(
      onSlideAnimationChanged: (Animation<double> openAnimation) => {},
      onSlideIsOpenChanged: handleOpen,
    );
    super.initState();
  }

  @override
  void dispose() {
    listViewScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    j = 0;
    mainComponent = [
      Container(
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
          key: expansionTile,
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
      ),
      Container(
        height: 1.1,
        width: 100,
        color: Colors.grey[300],
        margin: const EdgeInsets.all(10.0),
      ),
    ];
    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar(
        onTap: () {
          expansionTile.currentState.collapse();
          isOpened ? deviceSlide.activeState.close() : null;
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
                Container(
                  height: 40,
                  width: 1.1,
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  color: Colors.white,
                ),
                Text('${widget.room}', style: TextStyle(color: Colors.white, fontSize: 15.0)),
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
            isOpened ? deviceSlide.activeState.close() : null;
            },
          child: ListView.builder(
            controller: listViewScroll,
            scrollDirection: Axis.vertical,
            itemCount: widget.devices != null ? widget.devices.length*2+2 : 2,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              if (i < 2) return mainComponent[i];
              else {
                if(i%2 == 0){
                  j += 1;
                  return buildDevice(widget.devices[j-1], j-1);
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