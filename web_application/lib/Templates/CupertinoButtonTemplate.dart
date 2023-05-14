import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoButtonTemplate extends StatefulWidget{
  CupertinoButtonTemplate(this.buttonText,this.onPressed,{super.key}){}
  VoidCallback? onPressed;
  String buttonText;
  @override
  State<StatefulWidget> createState() => _CupertinoButtonTemplate(buttonText,onPressed);
}
class _CupertinoButtonTemplate extends State<CupertinoButtonTemplate> {
  _CupertinoButtonTemplate(this.buttonText,this.onPressed){}
  VoidCallback? onPressed;
  String buttonText;
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
        padding: EdgeInsets.fromLTRB(20,0,20,0),
        child: Text(
          buttonText, style: TextStyle(fontSize: 15),textAlign: TextAlign.center,
        ),

        onPressed: onPressed,
        color: Colors.blue,
        borderRadius: BorderRadius.circular(100)
    );
  }
}