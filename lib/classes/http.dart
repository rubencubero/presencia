import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';

class RequestResult {
  bool ok;
  dynamic data;
  RequestResult(this.ok, this.data);
}

String protocolo = "http";
// CON LOCALHOST 127.0.0.1 no ha funcionado, he tenido que poner la IP asignada del dispitivo */
//const DOMAIN = "192.168.123.78:8000";
//const DOMAIN = "10.175.207.180:8000";
String dominio = "192.168.123.203:8001";

Future<RequestResult> httpGet(String route, [dynamic data]) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  dominio = prefs.getString('APIServer');
  var dataStr = jsonEncode(data);
  var url = "$protocolo://$dominio/$route?data=$dataStr";
  var result = await http.get(url);
  return RequestResult(true, jsonDecode(result.body));
}

Future<RequestResult> httpPost(String route, [dynamic data]) async {
  var dataStr = jsonEncode(data);
  var url = "$protocolo://$dominio/$route";
  var result = await http.post(url,
      body: dataStr,
      headers: {"Content-Type": "application/json; charset=UTF-8"});
  return RequestResult(true, jsonDecode(result.body));
}
