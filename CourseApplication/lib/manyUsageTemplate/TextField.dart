import 'package:flutter/cupertino.dart';

class TextFieldTemplate extends StatefulWidget{
  TextFieldTemplate(this.controller,this.placeholderText,{super.key}){}
  TextEditingController controller;
  String placeholderText;
  @override
  State<StatefulWidget> createState() => _TextFieldTemplate(controller,placeholderText);
}
class _TextFieldTemplate extends State<TextFieldTemplate> {
  _TextFieldTemplate(this.controller,this.placeholderText){}
  TextEditingController controller;
  String placeholderText;
  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      placeholder: placeholderText,
      controller: controller,
      clearButtonMode: OverlayVisibilityMode.always,
    );
  }
}