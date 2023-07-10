import 'dart:convert';

import 'constants/api_constrants.dart';
import 'resuable_functions.dart';
import 'constants/string_constant.dart';
import 'package:http/http.dart' as http;

Future<String> generateTextResponse(String prompt) async {
  var url = Uri.https(baseApi, gptTurbo);

  // Load text from file
  // String fileText = await getTextFromFile();

  final http.Response response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: json.encode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "system",
          "content":
              "You are the AI assistant for ARML Technologies a Technological Company."
        },
        {"role": "system", "content": "If someone greets you greet them back"},
        {"role": "user", "content": "Now give structured response on $prompt"},
      ]
    }),
  );

  //print('Response body: ${response.body}');

  Map<String, dynamic> jsonResponse = jsonDecode(response.body);

  if (jsonResponse.containsKey('choices')) {
    var choices = jsonResponse['choices'] as List<dynamic>;

    if (choices.isNotEmpty && choices[0].containsKey('message')) {
      var message = choices[0]['message'];

      if (message.containsKey('content')) {
        var content = message['content'] as String;
        var processedContent = postProcessText(content); // Apply post-processing to the bot's response
        //print("Response content: $processedContent");
        return processedContent;
      }
    }
  }
  return 'OPPS!! The recipe must be wrong somewhere. Please try again!';
}

Future<String> generateImageResponse(String input) async {
  if (input.isNotEmpty) {

    var data = {
      "prompt": input,
      "n": 1,
      "size": "256x256",
    };

    http.Response response = await http.post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    var jsonResponse = jsonDecode(response.body);

    var augmentedData = jsonResponse['data'][0]['url'];
    return augmentedData;
  } else {
    print("Enter something");
    return '';
  }
}
