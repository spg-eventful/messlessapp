import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../ws/backend_client.dart';

class WebSocketTestingScreen extends StatelessWidget {
  const WebSocketTestingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton(
          onPressed: () => {BackendClient.init()},
          child: Text("Connect"),
        ),
        FilledButton(
          onPressed: () => {BackendClient.sendRaw("0;READ;ECHO;TEST;;;")},
          child: Text("Send echo"),
        ),
        FilledButton(
          onPressed: () async => {
            Logger.root.info(
              await BackendClient.service(
                "echo",
              ).create('{"message": "a;b;c;;", "checkAuthentication": false}'),
            ),
          },
          child: Text("Send echo via service"),
        ),
      ],
    );
  }
}
