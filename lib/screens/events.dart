import 'package:flutter/material.dart';
import 'package:messless/widgets/msls_appbar.dart';

class EventsScreens extends StatefulWidget {
  const EventsScreens({super.key});

  @override
  State<EventsScreens> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MslsAppbar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[],
        ),
      ),
    );
  }
}