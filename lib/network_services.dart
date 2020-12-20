import 'package:http/http.dart' as http;
import 'dart:convert';

const String infoApi = 'https://reqres.in/api/users/2';
Future<dynamic> fetchData() async {
  http.Response response = await http.get(infoApi);
  if (response.statusCode == 200) {
    var data = json.decode(response.body)['data'];
    print(data);
    return data;
  } else {
    throw Exception('fail to load');
  }
}
