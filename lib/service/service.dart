import 'package:http/http.dart' as http;
import 'dart:convert';

class Service{
Future<http.Response>  saveMemo(String memo) async{
  var uri = Uri.parse("/memos");
  Map<String, String> headers = {"content-type": "application/json"};
  Map data = {
    'memo': "$memo",
  };
  var body = json.encode(data);
  var response = await http.post(uri, headers: headers, body: body);

  return response;
}

getMemo() async{
  var res = await http.get(Uri.parse("http://localhost:8080/memos"));
  var body = jsonDecode((res.body));
  print(body);

}
}