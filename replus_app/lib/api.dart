import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'dart:convert';

class API{
  final String apiV2 = 'https://core.replus.co/api-v2';
  String uid;
  String accessToken;
  HttpClient apiClient;
  HttpClientRequest req;
  HttpClientResponse res;
  API({String this.uid});

  bool certCheck(X509Certificate cert, String host, int port) => host == 'core.replus.co';

  Future init() async {
    apiClient = new HttpClient()
        ..badCertificateCallback = certCheck;

    req = await apiClient.getUrl(Uri.parse('${apiV2}/get-token?uid=${uid}'));
    res = await req.close();
    
    (res.statusCode == 200) ? await res.transform(utf8.decoder).listen((token) => accessToken = token) : null;
  }

  String getToken(){
    return accessToken;
  }
}