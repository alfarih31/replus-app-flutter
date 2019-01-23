import 'package:flutter/material.dart';
import 'package:replus_app/widgets/expansionTile.dart';
import 'package:replus_app/widgets/customAppBar.dart';

class ShowSnackBar {
  final GlobalKey<ScaffoldState> scaffoldKey;
  ShowSnackBar({this.scaffoldKey});

  void show(String action, bool active, bool status) {
    final snackbar =  active ?
                  SnackBar(
                    backgroundColor: Colors.blueGrey,
                    content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('$action room...'),
                      CircularProgressIndicator(),
                      ],
                    ),
                  ) :
                  SnackBar(
                    backgroundColor: Colors.blueGrey,
                    duration: Duration(seconds: 2),
                    content: Text(status ? '$action room success' : '$action room failed'),
                    action: SnackBarAction(
                      label: 'OK',
                      onPressed: () {},
                    ),
                  );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }
}

class CustomDialog extends StatelessWidget {
  final String title, hintText, caption, validate, labelText;
  final IconData icon;
  final ValueChanged onPressed;
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  CustomDialog({this.hintText,
                this.title,
                this.caption,
                this.labelText,
                this.validate,
                this.icon,
                this.onPressed,
                this.controller,
                this.formKey});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Container(
        color: Colors.white10,
        alignment: Alignment.center,
        child: Container(
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.white,
            border: Border.all(
              color: Colors.blueGrey,
              width: 2.0,
            )
          ),
          margin: EdgeInsets.only(left: 20.0, right:20.0),
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: <Widget>[
              SizedBox(
                height: 55,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                    color: Colors.blue[300],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.all(4.0),),
                      Icon(icon, size: 45, color: Colors.white,),
                      Padding(padding: EdgeInsets.all(4.0),),
                      Material(
                        color: Colors.transparent,
                        child: Text(title, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white,),),
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
                  body: Container(
                    margin: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[Text(caption, style: TextStyle(color: Colors.blue, fontSize: 22.0),)],
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: labelText,
                              hintText: hintText,
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                )
                              ),
                            autofocus: true,
                            controller: controller,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if(value.isEmpty) return validate;
                            },
                          ),
                        ],
                      ),
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
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              Navigator.of(context).pop();
                            },
                          ),
                          Padding(padding: EdgeInsets.all(12.0),),
                          IconButton(
                            highlightColor: Colors.blueGrey[300],
                            icon: Icon(Icons.save, color: Colors.blue, size: 35.0,),
                            onPressed: () {
                              if(formKey.currentState.validate()) {
                                Navigator.of(context).pop();
                                onPressed(Null);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  resizeToAvoidBottomPadding: false,
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}

class DeviceMenuBottomSheet extends StatefulWidget {
  final List devices;
  final TextEditingController deviceNameInput = TextEditingController();
  final TextEditingController activationCodeInput = TextEditingController();
  final saveDevice;
  final String room;
  DeviceMenuBottomSheet({this.devices, this.saveDevice, this.room});
  @override
  _DeviceMenuBottomSheet createState() => new _DeviceMenuBottomSheet();
}

class _DeviceMenuBottomSheet extends State<DeviceMenuBottomSheet> {
  final ScrollController listViewScroll = ScrollController();
  final GlobalKey<AppExpansionTileState> expansionTile = new GlobalKey();
  final GlobalKey<FormState> formKey = new GlobalKey();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
  List textField;
  List<Widget> mainComponent;
  String type;
  bool isExpanded;
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
      maxLength: 4,
      controller: widget.deviceNameInput,
      keyboardType: TextInputType.text,
      validator: (value) {
        if(value.isEmpty) return 'Please input device name!';
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
        if(value.isEmpty) return 'Please input activation code!';
      },
    );
  }

  void showSnackBar(String action, bool stat, bool active){
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
    print(type);
  }

  void handleClear(){
    widget.deviceNameInput.clear();
    widget.activationCodeInput.clear();
    FocusScope.of(context).requestFocus(FocusNode());
    handleChoice(-1);
  }

  Future confirmSave() async {
    String deviceName = widget.deviceNameInput.text;
    String deviceCode = widget.activationCodeInput.text;
    if (formKey.currentState.validate()){
      showSnackBar('Adding', true, true);
      bool status = await widget.saveDevice([
          deviceName,
          deviceCode,
          type,
        ]);
      showSnackBar('Adding', status, false);
      handleClear();
    }
  }

  Widget buildDevice(Map device) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Colors.green,
          width: 2.0,
        ),
      ),
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Icon(Icons.settings_remote, size: 30.0),
          ),
          Container(
            child: Text('${device['name']}', style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('Room: ${widget.room}'),
                        Text('Type: ${device['type']}'),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      )
    );
  }

  @override
  void initState(){
    isExpanded = false;
    j = 0;
    radioVal = -1;
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
        margin: EdgeInsets.only(left: 7.0, right: 7.0,),
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
                        onPressed: confirmSave,
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
      Padding(padding: EdgeInsets.all(5.0),),
      Container(
        height: 1.1,
        width: 100,
        color: Colors.grey[300],
        margin: const EdgeInsets.only(left: 10.0, right: 10.0),
      ),
    ];
    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar(
        onTap: () => expansionTile.currentState.collapse(),
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
          backgroundColor: Colors.blue[300],
        ),
      ),
      body: Container(
        height: 600,
        color: Colors.white,
        child: GestureDetector(
          onTap: () => expansionTile.currentState.collapse(),
          child: ListView.builder(
            controller: listViewScroll,
            scrollDirection: Axis.vertical,
            itemCount: widget.devices != null ? widget.devices.length*2 + 3 : 3,
            shrinkWrap: true,
            padding: EdgeInsets.all(7.0),
            itemBuilder: (context, i) {
              if (i < 3) return mainComponent[i];
              else {
                if (i%2 == 0) {
                  j+=1;
                  return buildDevice(widget.devices[j-1]);
                } else return Padding(padding: EdgeInsets.all(5.0),);
              }
            },
          ),
        )
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}