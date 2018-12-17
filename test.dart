import 'dart:async';
import 'dart:io';
import 'dart:convert';

bool certCheck(X509Certificate cert, String host, int port) => host == 'core.replus.co';

void main() async {

  final String apiV2 = 'https://core.replus.co/api-v2';
  String uid = 'TESTUID';
  String a;
    HttpClient apiClient = new HttpClient()
        ..badCertificateCallback = certCheck;

    HttpClientRequest req = await apiClient.getUrl(Uri.parse('${apiV2}/get-token?uid=${uid}'));
    HttpClientResponse res = await req.close();
    
    await res.transform(utf8.decoder).forEach((elemetn) {
      a = elemetn;
    });
    print(a);
  }