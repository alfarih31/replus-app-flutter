library api;
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/io_client.dart';
class API{
  final String apiV2 = 'https://core.replus.co/api-v2';
  Future _initDone;
  final String uid;
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
    response = await ioClient.get('$apiV2/get-token?uid=$uid');
    if (response.statusCode == 200) accessToken = response.body;
    else throw Exception('FAILED_TO_LOAD_TOKEN');
  }

  Future <Map> getDevices() async {
    List<dynamic> _devices;
    String devices;
    response = await ioClient.get('$apiV2/get-devices?uid=$uid', headers: {'accesstoken': accessToken});
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
          deviceInRoom[roomName].add(device);
        }
      });
      return deviceInRoom;
    } else if (response.statusCode == 500) throw Exception('GET_DEVICES_FAILED: ${response.body}');
  }

  Future <List> getUserData() async {
    List<dynamic> _rooms;
    List<dynamic> userData = new List();
    String rooms;
    response = await ioClient.get('$apiV2/get-rooms?uid=$uid', headers: {'accesstoken':accessToken});
    if (response.statusCode == 200) {
      rooms = response.body;
      _rooms = json.decode(rooms);
      userData.add(_rooms);
      try {
        userData.add([await getDevices()]);
      } catch (e) {
        throw Exception(e);
      }
      return userData;
    } else if (response.statusCode == 500) throw Exception('GET_ROOMS_FAILED');
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
                headers: {'accesstoken':accessToken});
    if (response.statusCode == 200) return true;
    else throw Exception('Editing Room Failed: ${response.body}');
  }

  Future<bool> roomDelete(String roomID) async {
    response = await ioClient.delete('$apiV2/room-delete?uid=$uid&roomID=$roomID',
                headers: {'accesstoken':accessToken});
    if (response.statusCode == 200) return true;
    else throw Exception('Deleting Room Failed: ${response.body}');
  }

  Future<String> roomAdd(String name) async {
    final Map body = {
      'name': name,
      'uid': uid,
    };
    response = await ioClient.post('$apiV2/room-add',
                body: body,
                headers: {'accesstoken':accessToken});
    if (response.statusCode == 200) return response.body.toString();
    else throw Exception('Adding Room Failed: ${response.body}');
  }

  Future get initDone => _initDone;
}