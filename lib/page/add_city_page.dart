import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weather_app/models/src/app_settings.dart';
import 'package:weather_app/styles.dart';
import 'package:weather_app/widget/country_dropdown_field.dart';

class AddNewCityPage extends StatefulWidget {
  final AppSettings settings;

  const AddNewCityPage({Key key, this.settings}) : super(key: key);

  @override
  _AddNewCityPageState createState() => _AddNewCityPageState();
}

class _AddNewCityPageState extends State<AddNewCityPage> {
  City _newCity = City.fromUserInput();//value to be submitted to the repository/database
  bool _formChanged = false;//manages state of the form
  bool _isDefaultFlag = false;//boolean variable to manage checkbox state
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();//manages the form current
  // state
  FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();// manages the lifecycle of the long lived Focus node
  }

  @override
  void dispose() {
    // clean up the focus node when this page is destroyed.
    focusNode.dispose();
    super.dispose();
  }

  bool validateTextFields() {
    return _formKey.currentState.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add City",
          style: TextStyle(color: AppColor.textColorLight),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Form(// the root of the form.its stateful
          key: _formKey,// key used to access the state of this form object
          onChanged: _onFormChange,
          onWillPop: _onWillPop,// called when the user is leaving the page
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Padding(// the city form field
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  onSaved: (String val) => _newCity.name = val,// field will be saved as
                  // soon as it gains focus. It sets the name of the new city
                  decoration: InputDecoration(//property of text form field; not other
                    // form elements
                    border: OutlineInputBorder(),
                    helperText: "Required",
                    labelText: "City name",
                  ),
                  autofocus: true,
                  autovalidate: _formChanged,// validates only when the form has changed
                  validator: (String val) {// a callback to validate user input
                    if (val.isEmpty) return "Field cannot be left blank";
                    return null;//no error thrown in this case
                  },
                ),
              ),
              Padding(// the state or territory field
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  focusNode: focusNode,
                  onSaved: (String val) => print(val),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    helperText: "Optional",//always displayed unless there is a validation
                    // error
                    labelText: "State or Territory name",// always displayed
                  ),
                  validator: (String val) {
                    if (val.isEmpty) {
                      return "Field cannot be left blank";
                    }
                    return null;
                  },
                ),
              ),
              CountryDropdownField(
                country: _newCity.country,
                onChanged: (newSelection) {
                  setState(() => _newCity.country = newSelection);
                },
              ),
              FormField(// check box for the default city
                onSaved: (val) => _newCity.active = _isDefaultFlag,// sets the proper value
                // when form is submitted
                builder: (context) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Default city?"),
                      Checkbox(
                        value: _isDefaultFlag,
                        onChanged: (val) {// val has no type because form field doesn't know the
                          // the type of data it will  receive
                          setState(() => _isDefaultFlag = val);
                        },
                      ),
                    ],
                  );
                },
              ),
              Divider(
                height: 32.0,
              ),
              Row(// bottom section of the form where user submits or cancel their input
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                        textColor: Colors.red[400],
                        child: Text("Cancel"),
                        onPressed: () async {
                          if (await _onWillPop()) {
                            Navigator.of(context).pop(false);
                          }
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      color: Colors.blue[400],
                      child: Text("Submit"),
                      onPressed: _formChanged//disables the submit button if no input has been made
                          ? () {
                              if (_formKey.currentState.validate()) {// false if callback is
                                // a fail
                                _formKey.currentState.save();// reference to FormsState.save
                                _handleAddNewCity();// constructs a new city  and adds it to the db
                                Navigator.pop(context);// navigates back after the submit
                              } else {
                                FocusScope.of(context).requestFocus(focusNode);// manages
                                // passing  focus to appropriate nodes
                              }
                            }
                          : null,// button disabled
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onFormChange() {
    if (_formChanged) return;// stops re-rendering if the _formChanged is already true
    setState(() {
      _formChanged = true;
    });
  }

  void _handleAddNewCity() {
    final city = City(
      name: _newCity.name,
      country: _newCity.country,
      active: true,
    );

    allAddedCities.add(city);
  }

  Future<bool> _onWillPop() {
    if (!_formChanged) return Future<bool>.value(true);//if there is no user changes
    // no need to concern ourselves about routing away
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(// this is a route
              content: Text("Are you sure you want to abandon the form? Any changes will be lost."),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(false),//stays on the page
                  textColor: Colors.black,
                ),
                FlatButton(
                  child: Text("Abandon"),
                  textColor: Colors.red,
                  onPressed: () => Navigator.pop(context, true),// navigates back
                ),
              ],
            ) ??
            false;
      },
    );
  }
}
