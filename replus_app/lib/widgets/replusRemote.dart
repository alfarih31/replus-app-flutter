import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:replus_app/widgets/expansionTile.dart';
import 'package:replus_app/widgets/flutter_slidable/flutter_slidable.dart';

final List<String> types = <String>['TV', 'AC'];
final List<String> acBrand = ['Daikin', 'Dast', 'LG', 'Mitsubishi',
                        'Panasonic', 'Panasonic Old', 'Samsung', 'Toshiba'];
final Map tvBrandMap = {
  'Changhong' : '2903',
  'LG' : '0595',
  'Panasonic' : '2619',
  'Samsung' : '1970',
  'Sanyo' : '1530',
  'Sharp' : '1429',
  'Sony': '1319',
  'Toshiba' : '0339',
  'Phillips' : '0636',
  'Sharp TV': 'T001',
};

final Map modeMap = {
  'Auto': '0',
  'Cooling': '1',
  'Dehumidifying': '2',
  'Heating': '3',
};

final Map fanMap = {
  'Auto': '0',
  'Low': '1',
  'Medium': '2',
  'High': '3',
};

final List<String> tvBrand = List<String>.from(tvBrandMap.keys.toList());
Map tvCodeSetMap = new Map();
Map acBrandMap = new Map();


String getModeName(String modeNum) {
  String name;
  if(modeNum == '0') name = 'Auto';
  else if(modeNum == '1') name = 'Cooling';
  else if(modeNum == '2') name = 'Dehumidifying';
  else if(modeNum == '3') name = 'Heating';
  return name;
}

String getFanName(String fanNum) {
  String name;
  if(fanNum == '0') name = 'Auto';
  else if(fanNum == '1') name = 'Low';
  else if(fanNum == '2') name = 'Medium';
  else if(fanNum == '3') name = 'High';
  return name;
}

String format(String text) {
  return text.toLowerCase().replaceAll(new RegExp(r"\s+\b|\b\s"), "");
}


class SaveParams {
  final int index;
  final String on;
  final String off;
  SaveParams({this.index, this.on, this.off});
}

class ReplusRemote extends StatefulWidget {
  final Map device;
  final int index;
  final String roomName;
  final Function saveSetup;
  final Function deviceDeleteDialog;
  final String onCommand;
  final String offCommand;
  final SlidableController deviceSlide;
  ReplusRemote({
    this.device,
    this.index,
    this.roomName,
    this.saveSetup,
    this.onCommand,
    this.offCommand,
    this.deviceSlide,
    this.deviceDeleteDialog});

  @override
  _ReplusRemote createState() => new _ReplusRemote(device: device, index: index, roomName: roomName);
}

class _ReplusRemote extends State<ReplusRemote> {
  final Map device;
  final int index;
  final String roomName;
  _ReplusRemote({this.device, this.index, this.roomName});
  final GlobalKey<AppExpansionTileState> setupExpansionTile = new GlobalKey();

  String tempOnCommand, onCommand;
  String tempOffCommand, offCommand;
  bool onSetup, onSaving;
  int n = 0;

  void handleOnCommand(String command) => tempOnCommand = command;
  void handleOfCommand(String command) => tempOffCommand = command;

  Future confirmDeviceSetup(int index) async {
    if((tempOffCommand == null && tempOnCommand == null)
    || (tempOffCommand == offCommand && tempOnCommand == onCommand)) setupExpansionTile.currentState.collapse();
    else {
      setState(() => onSaving = !onSaving);
      await widget.saveSetup(new SaveParams(index: index, off: tempOffCommand, on: tempOnCommand));
      onSaving = !onSaving;
      onCommand = tempOnCommand;
      offCommand = tempOffCommand;
      setState(() {});
    }
  }

  Widget showCurrentCommand(String command, int n) {
    if(command == null) return Card(
      elevation: 2.0,
      color: Colors.blueGrey[200],
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(n == 1 ? Icons.filter_1 : Icons.filter_2, size: 15.0,),
                Icon(Icons.warning),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('No push button'),
                Text('command'),
              ],
            )
          ],
        ),
      ),
    );
    final List<String> splitCommand = command.split('-');
    if(splitCommand.length == 2) {
      final String brand = splitCommand[0];
      final String command = splitCommand[1];
      final String mode = getModeName(command.substring(0, 1));
      final String fan = getFanName(command.substring(1,2));
      final String temp = command.substring(2);
      return Card(
        elevation: 2.0,
        color: Colors.blueGrey[200],
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(n == 1 ? Icons.filter_1 : Icons.filter_2, size: 15.0,),
                  Icon(Icons.ac_unit),
                  Text('${acBrandMap[brand]}'),
                ],
              ),
              Padding(padding: EdgeInsets.all(2.0),),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.power_settings_new),
                      Text(command == '0000' ? 'Off' : 'On'),
                    ],
                  ),
                  command != '0000' ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.menu),
                          Text('$mode'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.toys),
                          Text('$fan'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('$temp'),
                        ],
                      ),
                    ],
                  ) : Container(width: 0, height: 0,),
                ],
              ),
            ],
          ),
        )
      );
    } else {
      final String brand = command.substring(0, 4);
      final String power = command.substring(4);
      return Card(
        elevation: 2.0,
        color: Colors.blueGrey[200],
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(n == 1 ? Icons.filter_1 : Icons.filter_2, size: 15.0,),
                  Icon(Icons.tv),
                  Text('${tvCodeSetMap[brand]}'),
                ],
              ),
              Padding(padding: EdgeInsets.all(2.0),),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.power_settings_new),
                      Text(power == '16' ? 'Off' : 'On'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
      );
    }
  }

  @override
  void initState() {
    super.initState();
    onSetup = false;
    onSaving = false;
    onCommand = widget.onCommand;
    offCommand = widget.offCommand;
    tempOffCommand = offCommand;
    tempOnCommand = onCommand;
    tvBrandMap.forEach((brand, code) => tvCodeSetMap.addAll({code : brand}));
    acBrand.forEach((brand) => acBrandMap.addAll({format(brand) : brand}));
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      controller: widget.deviceSlide,
      delegate: SlidableScrollDelegate(),
      actionExtentRatio: 0.45,
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
        child: AppExpansionTile(
          key: setupExpansionTile,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.arrow_back_ios,
                color: Colors.black,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 5.0,right: 7.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      minRadius: 5.0,
                      maxRadius: 28.0,
                      child: Icon(Icons.settings_remote,
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
                ],
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
                        Text('Room: $roomName'),
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
          trailing: Icon(onSetup ? Icons.close : Icons.settings, color: Colors.blue[300], size: 40.0,),
          children: <Widget>[
            new CommandMenu(title: '1st Command', conCommand: onCommand, device: device, saveCommand: handleOnCommand),
            new CommandMenu(title: '2nd Command', conCommand: offCommand, device: device, saveCommand: handleOfCommand,),
            Center(
              child: onSaving ? CircularProgressIndicator() : FlatButton(
                onPressed: () => confirmDeviceSetup(index,),
                child: Icon(Icons.check),
              ),
            )
          ],
          onExpansionChanged: (state) => setState(() => onSetup = state),
        ),
      ),
      actions: <Widget>[
        showCurrentCommand(onCommand, 1),
        showCurrentCommand(offCommand, 2),
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          onTap: () => widget.deviceDeleteDialog(index, context),
          icon: Icons.delete,
        ),
      ],
    );
  }
}

class CommandMenu extends StatefulWidget {
  final String title;
  final String conCommand;
  final Map device;
  final ValueChanged<String> saveCommand;
  CommandMenu({this.device, this.title, this.conCommand, this.saveCommand});

  @override
  _CommandMenu createState() => new _CommandMenu();
}

class _CommandMenu extends State<CommandMenu>{

  String onPower,
          onType,
          onBrand,
          onMode,
          onFan;
  int onTemp;
  List<String> currentBrands, modes, fans;
  List<int> temps;
  List<String> powers = ['Off', 'On',];
  Map remoteData = new Map();
  bool onInit = true;

  double sWidth;

  void formatCommand() {
    String formattedCommand;
    if(onType == 'AC') {
      formattedCommand = onPower == 'Off' ? '${format(onBrand)}-0000':
      '${format(onBrand)}-${modeMap[onMode]}${fanMap[onFan] }${onTemp.toString()}';
    } else if(onType == 'TV') {
      formattedCommand= '${tvBrandMap[onBrand].toString().padLeft(4, '0')}${onPower == 'Off' ? 16 : 15}';
    }
    widget.saveCommand(formattedCommand);
  }

  void reMode(String brand) {
    modes = List<String>.from(remoteData[format(brand)].keys.toList());
    onMode = modes[0];
    reFan(onMode);
  }

  void reFan(String mode) {
    fans = List<String>.from(remoteData[format(onBrand)][mode].keys.toList());
    onFan = fans[0];
    temps = remoteData[format(onBrand)][mode][onFan];
    onTemp = temps[0];
  }

  Widget powerOption() {
    return SizedBox(
      width: sWidth*0.2,
      child: FormField(
        builder: (FormFieldState state) {
          return InputDecorator(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Power',
              labelText: 'Power',
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: onPower,
                isDense: true,
                onChanged: (String newPower) {
                  onPower = newPower;
                  this.setState(() {
                    formatCommand();
                    state.didChange(newPower);
                  });
                },
                items: powers.map((String power) {
                  return new DropdownMenuItem<String>(
                    value: power,
                    child: new Text('$power'),
                  );
                }).toList(),
              ),
            ),
          );
        },
      )
    );
  }

  Widget typeOption() {
    return SizedBox(
      width: sWidth*0.19,
      child: FormField(
        builder: (FormFieldState state) {
          return InputDecorator(
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'Type',
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: onType,
                isDense: true,
                onChanged: (String newType){
                  onType = newType;
                  if(onType == 'TV') {
                    currentBrands = tvBrand;
                    onBrand = currentBrands[0];
                    this.setState(() {
                    formatCommand();
                    state.didChange(newType);
                  });
                  }
                  else if(onType == 'AC') {
                    currentBrands = acBrand;
                    onBrand = currentBrands[0];
                    reMode(onBrand);
                    this.setState(() {
                    formatCommand();
                    state.didChange(newType);
                  });
                  }
                },
                items: types.map((String type) {
                  return new DropdownMenuItem<String>(
                    value: type,
                    child: new Text('$type'),
                  );
                }).toList(),
              ),
            ),
          );
        },
      )
    );
  }

  Widget brandOption() {
    return SizedBox(
      width: sWidth*0.31,
      child: FormField(
        builder: (FormFieldState state) {
          return InputDecorator(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Brand',
              labelText: 'Brand',
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: onBrand,
                isDense: true,
                onChanged: (String newBrand) {
                  onBrand = newBrand;
                  if(onType == 'AC') reMode(onBrand);
                  this.setState(() {
                    formatCommand();
                    state.didChange(newBrand);
                  });
                },
                items: currentBrands.map((String brand) {
                  return new DropdownMenuItem<String>(
                    value: brand,
                    child: new Text('$brand', overflow: TextOverflow.ellipsis,),
                  );
                }).toList(),
              ),
            )
          );
        },
      )
    );
  }

  // Mode and Fan DropDown
  Widget modeOption() {
    return SizedBox(
      width: sWidth*0.31,
      child: FormField(
        builder: (FormFieldState state) {
          return InputDecorator(
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'AC\'s Mode',
              hintText: 'AC\'s Mode',
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: onMode,
                isDense: true,
                onChanged: (String newMode) {
                  onMode = newMode;
                  reFan(onMode);
                  this.setState(() {
                    formatCommand();
                    state.didChange(newMode);
                  });
                },
                items: modes.map((String mode) {
                  return new DropdownMenuItem<String>(
                    value: mode,
                    child: new Text('$mode'),
                  );
                }).toList(),
              ),
            ),
          );
        },
      )
    );
  }

  Widget fanOption() {
    return SizedBox(
      width: sWidth*0.31,
      child: FormField(
        builder: (FormFieldState state) {
          return InputDecorator(
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'AC\'s Fan',
              hintText: 'AC\'s Fan',
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: onFan,
                isDense: true,
                onChanged: (String newFan) {
                  onFan = newFan;
                  this.setState(() {
                    formatCommand();
                    state.didChange(newFan);
                  });
                },
                items: fans.map((String fan) {
                  return new DropdownMenuItem<String>(
                    value: fan,
                    child: new Text('$fan'),
                  );
                }).toList(),
              ),
            )
          );
        },
      )
    );
  }

  Widget tempOption() {
    return SizedBox(
      width: sWidth*0.19,
      child: FormField(
        builder: (FormFieldState state) {
          return InputDecorator(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'AC\'s temp',
              labelText: 'AC\'s temp',
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: onTemp,
                isDense: true,
                onChanged: (int newTemp) {
                  onTemp = newTemp;
                  this.setState(() {
                    formatCommand();
                    state.didChange(newTemp);
                  });
                },
                items: temps.map((int temp) {
                  return new DropdownMenuItem<int>(
                    value: temp,
                    child: new Text('$temp'),
                  );
                }).toList(),
              ),
            ),
          );
        },
      )
    );
  }

  Future<void> initRemote() async {
    for (String brand in acBrand) {
      brand = format(brand);
      String jsonStr = await DefaultAssetBundle.of(context).loadString('assets/manifests/$brand/manifest.json');
      Map rawData = json.decode(jsonStr);
      Map formatData = new Map();

      rawData.forEach((mode, _fan) {
        Map fanData = new Map();
        _fan.forEach((fan, temp) {
          if (fan == '0') fanData.addAll({'Auto' : new List<int>.from(temp)});
          else if (fan == '1') fanData.addAll({'Low' : new List<int>.from(temp)});
          else if (fan == '2') fanData.addAll({'Medium' : new List<int>.from(temp)});
          else if (fan == '3') fanData.addAll({'High' : new List<int>.from(temp)});
        });

        if(mode == '0') formatData.addAll({'Auto' : fanData});
        else if(mode == '1') formatData.addAll({'Cooling' : fanData});
        else if(mode == '2') formatData.addAll({'Dehumidifying' : fanData});
        else if(mode == '3') formatData.addAll({'Heating' : fanData});
      });
      remoteData.addAll({'$brand' : formatData});
    }
    _initState();
    setState(() => onInit = false);
  }

  void _initState() {
    // If user have set one push button setting
    if(widget.conCommand != null) {
      final List _conCommand = widget.conCommand.split('-');
      if(_conCommand.length == 2 ) {
        final String _command = _conCommand[1];
        onBrand = acBrandMap[_conCommand[0]];
        currentBrands = acBrand;
        onMode = getModeName(_command.substring(0, 1));
        onFan = getFanName(_command.substring(1,2));
        reMode(onBrand);
        if(_command != '0000') {
          onTemp = int.parse('${_command.substring(2)}');
          onPower = powers[1];
        } else onPower = powers[0];
        onType = 'AC';
      } else {
        final int _command = int.parse(widget.conCommand.substring(4));
        onBrand = tvCodeSetMap['${widget.conCommand.substring(0, 4)}'];

        if(_command == 16) onPower = powers[0];
        else if(_command == 15) onPower = powers[1];
        currentBrands = tvBrand;
        onType = 'TV';
      }
    } else {
      onPower = powers[0];
    }
    setState(() {});
  }

  Widget buildMenu() {
    return Card(
      elevation: 2.0,
      child: ExpansionTile(
        title: Text(widget.title),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(2.0),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  powerOption(),
                  onType == 'AC' && onPower == 'On' ? modeOption() : Container(width: 0.0, height: 0.0,),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(2.0),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  typeOption(),
                  onType == 'AC' && onPower == 'On' ? fanOption() : Container(width: 0.0, height: 0.0,),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(2.0),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  onType != null ? brandOption() : Container(width: 0.0, height: 0.0,),
                  onMode != null && onType == 'AC' && onPower == 'On' ? tempOption() : Container(width: 0.0, height: 0.0,),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(2.0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() => super.initState();

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    return onInit ? FutureBuilder<void>(
      future: initRemote(),
      builder: (context, snap) {
        if(snap.connectionState == ConnectionState.waiting) return CircularProgressIndicator();
        else return buildMenu();
      },
    ) : buildMenu();
  }
}