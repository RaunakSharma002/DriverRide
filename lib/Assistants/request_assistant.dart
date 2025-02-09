import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant {

  static Future<dynamic> recieveRequest(String url) async {
    // http.Response httpResponse = await http.get(Uri.parse(url));

    final httpResponse = await http.get(Uri.parse(url));

    try{
      if(httpResponse.statusCode == 200){ //successfull
        String responseData  = httpResponse.body; //json
        var decodeResponseData = jsonDecode(responseData);

        return decodeResponseData;
      }
      else{
        return "failedResponse";
      }
    }catch(exp){
      return "failedResponse";
    }
  }
}