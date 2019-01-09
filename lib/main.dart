import 'package:flutter/material.dart';
import 'package:wallpapers/screens/main.dart';

class Application extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return new MaterialApp(
            title: 'Wallpapers',
            theme: new ThemeData(
                primarySwatch: Colors.deepOrange
            ),
            home: new HomeScreen(title: 'Wallpapers'),
        );
    }
}

void main() => runApp(new Application());