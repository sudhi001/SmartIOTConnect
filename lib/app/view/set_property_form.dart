import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartiotconnect/di.dart';

class SetPropertyWidget extends StatefulWidget {
  const SetPropertyWidget( {super.key});

  @override
  State<SetPropertyWidget> createState() => _SetPropertyWidgetState();
}

class _SetPropertyWidgetState extends State<SetPropertyWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sprayModuleActivate= TextEditingController(text:'27');
  final TextEditingController _waterModuleActivate= TextEditingController(text:'26');
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            keyboardType: TextInputType.number,
            controller: _sprayModuleActivate,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly, // Allow only digits
            ],
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Spray Module Activation Value',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter valid value';
              }
              return null;
            },

          ),
          TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly, // Allow only digits
              ],
              controller: _waterModuleActivate,

              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Water Module Activation Value',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid value';
                }
                return null;
              },
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async{
                        try {
                          if (_formKey.currentState?.validate() ??
                              false) {
                            setState(() {
                              isLoading = true;
                            });
                            _formKey.currentState?.save();
                            final sprayModuleActivateValue = _sprayModuleActivate
                                .value.text;
                            final waterModuleActivateValue = _waterModuleActivate
                                .value.text;
                            await bleCtr.send(
                              '{"action":"SET_PROPERTY","sprayModuleActivateValue":${double.tryParse(sprayModuleActivateValue)},"waterModuleActivateValue":${double.tryParse(waterModuleActivateValue)}}',
                            );
                          }
                        }catch(e){
                          setState(() {
                            isLoading=false;
                          });
                        }
                        setState(() {
                          isLoading=false;
                        });
                      },
                      child: const Text('CHANGE WIFI SETTINGS'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
