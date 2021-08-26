import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class ProgramListWidget extends StatefulWidget{
  @override
  _ProgramListWidgetState createState() => _ProgramListWidgetState();
}

class _ProgramListWidgetState extends State<ProgramListWidget>{
  DateTime _selectedDate = DateTime.now();
  String _buttonText = "請選擇日期";
  bool _isDefault = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xE5F4F5F6))
              ),
              onPressed: (){
                _isDefault = false;
                DatePicker.showDatePicker(context,
                  minTime: DateTime.now(),
                  maxTime: DateTime.now().add(const Duration(days: 7)),
                  currentTime: DateTime.now(),
                  locale: LocaleType.zh,
                  onChanged: (date){
                    setState(() {
                      _selectedDate = date;
                      _buttonText = '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日';
                    });
                  },
                  onConfirm: (date){
                    setState(() {
                      _selectedDate = date;
                      _buttonText = '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日';
                    });
                  }
                );
              },
              child: Container(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_buttonText,
                      style: TextStyle(
                        color: _isDefault ? Color(0x3f000000):Colors.black,
                        fontSize: 17,
                      ),
                    ),
                    FittedBox(
                      child: Icon(Icons.keyboard_arrow_down,
                        color: Color(0xE5757575),
                      ),
                    ),
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }
}