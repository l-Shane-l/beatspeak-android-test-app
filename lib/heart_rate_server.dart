import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class HeartRateServer {
  final int port;
  final List<int> heartRates = [];

  HeartRateServer({required this.port});

  Future<void> start() async {
    final server = await HttpServer.bind('0.0.0.0', port);

    print('Heart rate server started on port $port');

    await for (var request in server) {
      if (request.method == 'GET' && request.uri.path == '/heartrate') {
        final heartRateJson = jsonEncode(heartRates);
        request.response.write(heartRateJson);
      } 
      
      
    // Handle GET requests to the /clear endpoint
    else if (request.method == 'GET' && request.uri.path == '/clear') {
      // Clear the heart rate data
      heartRates.clear();

      // Create a plain text response to indicate that the data has been cleared
      final response = request.response;
      response.headers.contentType = ContentType.text;
      response.write('Heart rate data cleared');
      response.close();
    }
      
      else {
        request.response.statusCode = 404;
      }
      await request.response.close();
    }
  }

  void addHeartRate(int heartRate) {
    heartRates.add(heartRate);
  }
}
