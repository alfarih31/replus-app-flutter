library api;
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/io_client.dart';
class API{
  final String apiV2 = 'https://core.replus.co/api-v2';
  final String uid;
  Future _initDone;
  String accessToken;
  HttpClient httpClient;
  IOClient ioClient;
  var response;

  API({this.uid}) {
    _initDone = init();
  }

  bool certCheck(X509Certificate cert, String host, int port) => host == 'core.replus.co';

  Future init() async {
    httpClient = new HttpClient()
        ..badCertificateCallback = certCheck;
    ioClient = new IOClient(httpClient);
  }

  Future refreshToken() async {
    response = await ioClient.get('$apiV2/get-token?uid=$uid');
    if (response.statusCode == 200) accessToken = response.body;
    else throw Exception('FAILED_TO_LOAD_TOKEN');
  }

  Future <Map> getDevices() async {
    List<dynamic> _devices;
    String devices;
    response = await ioClient.get('$apiV2/get-devices?uid=$uid', headers: {'accesstoken': '$accessToken'});
    if (response.statusCode == 200) {
        devices = response.body;
        _devices = json.decode(devices);
        Map deviceInRoom = {};
        _devices.forEach((device) {
          String roomName = device['room'];
          if(deviceInRoom.containsKey(roomName)) deviceInRoom[roomName].add(device);
          else{
            Map room = {'$roomName': new List()};
            deviceInRoom.addAll(room);
            deviceInRoom['$roomName'].add(device);
          }
        });
      return deviceInRoom;
    } else return Map();
  }

  Future<List> getGroups() async {
    List<dynamic> _groups;
    String groups;
    response = await ioClient.get('$apiV2/get-groups?uid=$uid', headers: {'accesstoken': '$accessToken'});
    if (response.statusCode == 200) {
        groups = response.body;
        _groups = json.decode(groups);
      return _groups;
    } else return new List();
  }

  Future <List> getUserData() async {
    List<dynamic> _rooms;
    List<dynamic> userData = new List();
    String rooms;
    response = await ioClient.get('$apiV2/get-rooms?uid=$uid', headers: {'accesstoken':'$accessToken'});
    if (response.statusCode == 200) {
      rooms = response.body;
      _rooms = json.decode(rooms);
      userData.add(_rooms);
      try {
        userData.add([await getDevices()]);
        userData.add(await getGroups());
      } catch (e) {
        throw Exception(e);
      }
      return userData;
    } else return List();
  }

  Future<bool> roomEdit(String name, String group, String roomID) async {
    final Map body = {
      'name': name,
      'group': group,
      'uid': uid,
      'roomID': roomID,
    };
    response = await ioClient.put('$apiV2/room-edit',
                body: body,
                headers: {'accesstoken':'$accessToken'});
    if (response.statusCode == 200) return true;
    else return false;
  }

  Future<bool> roomDelete(String roomID) async {
    response = await ioClient.delete('$apiV2/room-delete?uid=$uid&roomID=$roomID',
                headers: {'accesstoken':'$accessToken'});
    if (response.statusCode == 200) return true;
    else return false;
  }

  Future<String> roomAdd(String name) async {
    final Map body = {
      'name': name,
      'uid': uid,
    };
    response = await ioClient.post('$apiV2/room-add',
                body: body,
                headers: {'accesstoken':'$accessToken'});
    if (response.statusCode == 200) return response.body.toString();
    else return 'false';
  }

  Future<bool> deviceAdd(String deviceID, String deviceCode, String room, String type) async {
    final Map body = {
      'deviceID': deviceID,
      'uid': uid,
      'deviceCode': deviceCode,
      'room': room,
      'type': type,
    };
    response = await ioClient.post('$apiV2/device-add',
                body: body,
                headers: {'accesstoken':'$accessToken'});
    if (response.statusCode == 200) return true;
    else return false;
  }

  Future <bool> deviceDelete(String device) async {
    response = await ioClient.delete('$apiV2/device-delete?uid=$uid&device=$device', headers: {'accesstoken': '$accessToken'});
    if (response.statusCode == 200) {
      return true;
    } else return false;
  }

  Future <bool> deviceSetup({String device, String on, String off}) async {
    final Map body = new Map();
    if(on != null) body.addAll({'onCommand' : on});
    if(off != null) body.addAll({'offCommand': off});

    response = await ioClient.put('$apiV2/device-setup?uid=$uid&device=$device',
                body: body,
                headers: {'accesstoken': '$accessToken'});
    if (response.statusCode == 200) {
      return true;
    } else return false;
  }

  Future get initDone => _initDone;
}
