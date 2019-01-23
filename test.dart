import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/io_client.dart';

final String apiV2 = 'https://core.replus.co/activity/';
bool certCheck(X509Certificate cert, String host, int port) => host == 'core.replus.co';

void main() async {
  HttpClientRequest req;
  HttpClientResponse res;
  HttpClient apiClient;
  Map body = {
    "name": "LAB2",
    'uid': 'No8jTFk95jc21BsNfNsN42HxTe83',
    'roomID': '-LIHhAaYVRNO2ij6Di7y',
  };
  var body3 = json.encoder.convert(body);
  var body2 = json.encode({
    "name": "LAB2",
    "uid": "No8jTFk95jc21BsNfNsN42HxTe83",
    "roomID": "-LIHhAaYVRNO2ij6Di7y",
  });
  var test = [['1'],['2'],['3'],['4']];

  /*var response = await client.put('${apiV2}room-edit', body: body,
                  headers: {
                    'accesstoken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJObzhqVEZrOTVqYzIxQnNOZk5zTjQySHhUZTgzIiwiaWF0IjoxNTQ2NDQxNjMxLCJleHAiOjE1NDcwNDY0MzF9.QJ14Gb2kBERAPqhnK79wGCuq7LB_ZU2TPQ2rHWBQ1NU',
                  });*/
  apiClient = new HttpClient()
        ..badCertificateCallback = certCheck;
  /*req = await apiClient.putUrl(Uri.parse('${apiV2}room-edit'));
  req.headers.set('accesstoken', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJObzhqVEZrOTVqYzIxQnNOZk5zTjQySHhUZTgzIiwiaWF0IjoxNTQ2NDQxNjMxLCJleHAiOjE1NDcwNDY0MzF9.QJ14Gb2kBERAPqhnK79wGCuq7LB_ZU2TPQ2rHWBQ1NU');
  req.headers.set('Content-Type', 'application/x-www-form-urlencoded');
  //req.headers.set(HttpHeaders.contentLengthHeader, body.length);*/
  IOClient ioClient = new IOClient(apiClient);
  var response = await ioClient.get('https://35.231.100.23:2030/activity/fetch?uid=HAHAHA&by=owner&before=1547809022000&after=1547607422000',
                                    headers: {
                    'accesstoken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJIQUhBSEEiLCJpYXQiOjE1NDc3MDQ1MTcsImV4cCI6MTU0ODMwOTMxN30.45nLORKtUCSGcYAIK5DKpah2n7bwCyMA5PmRYmuVeNc',
                  });
  print(response.body);
}