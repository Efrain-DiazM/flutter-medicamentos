import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteConfig {

  static final endpoint = dotenv.env['APPWRITE_ENDPOINT'] ?? ' ';
  static final projectId = dotenv.env['APPWRITE_PROJECT_ID'] ?? ' ';

  static Client getClient() {
    Client client = Client();
    client
        .setEndpoint(endpoint)
        .setProject(projectId)
        .setSelfSigned(status: true);
    return client;
  }
}
