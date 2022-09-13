library intl_phone_field;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';

class PhoneField extends StatefulWidget {
  final bool obscureText;
  final TextAlign textAlign;
  final Function onPressed;
  final bool readOnly;
  final Function validator;
  final FormFieldSetter<PhoneNumber> onSaved;
  final ValueChanged<PhoneNumber> onChanged;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function onSubmitted;

  /// 2 Letter ISO Code
  final String initialCountryCode;
  final InputDecoration decoration;
  final TextStyle style;

  PhoneField({
    this.initialCountryCode,
    this.obscureText = false,
    this.textAlign = TextAlign.left,
    this.onPressed,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.focusNode,
    this.decoration,
    this.style,
    this.onSubmitted,
    this.validator,
    this.onChanged,
    this.onSaved,
  });

  @override
  _PhoneFieldState createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  Map<String, dynamic> _selectedCountry =
      countries.where((item) => item['code'] == 'AF').toList()[0];

  List<dynamic> filteredCountries = countries;

  @override
  void initState() {
    super.initState();
    if (widget.initialCountryCode != null) {
      _selectedCountry = countries
          .where((item) => item['code'] == widget.initialCountryCode)
          .toList()[0];
    }
  }

  Future<void> _changeCountry() async {
    filteredCountries = countries;
    await showDialog(
      builder: (context) => StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    isDense: true,
                    suffixIcon: Icon(
                      Feather.search,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                    alignLabelWithHint: true,
                    labelText: 'Search by Country Name',
                  ),
                  onChanged: (value) {
                    setState(() {
                      filteredCountries = countries.where((country) {
                        return country['name'].toLowerCase().contains(value);
                      }).toList();
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                  child: Container(),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (ctx, index) => Column(
                      children: <Widget>[
                        ListTile(
                          leading: Text(
                            filteredCountries[index]['flag'],
                            style: TextStyle(fontSize: 30),
                          ),
                          title: Text(
                            filteredCountries[index]['name'],
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color:
                                    Theme.of(context).textTheme.headline6.color,
                                fontSize: 14),
                          ),
                          trailing: Text(
                            filteredCountries[index]['dial_code'],
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color:
                                    Theme.of(context).textTheme.headline6.color,
                                fontSize: 14),
                          ),
                          onTap: () {
                            _selectedCountry = countries
                                .where(
                                  (country) =>
                                      country['code'] ==
                                      filteredCountries[index]['code'],
                                )
                                .toList()[0];
                            Navigator.of(context).pop();
                          },
                        ),
                        Divider(
                          thickness: 1,
                        ),
                      ],
                    ),
                    itemCount: filteredCountries.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      context: context,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            readOnly: widget.readOnly,
            obscureText: widget.obscureText,
            textAlign: widget.textAlign,
            onTap: widget.onPressed,
            controller: widget.controller,
            focusNode: widget.focusNode,
            onFieldSubmitted: widget.onSubmitted,
            decoration: InputDecoration(
              hintText: 'Phone Number',
              isDense: true,
              prefixIcon: Icon(
                Feather.phone,
                color: Theme.of(context).primaryIconTheme.color,
              ),
              suffixIcon: Container(
                child: InkWell(
                  child: Container(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _selectedCountry['flag'],
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        FittedBox(
                          child: Text(
                            _selectedCountry['dial_code'],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .color),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: _changeCountry,
                ),
              ),
            ),
            style: widget.style,
            onSaved: (value) {
              widget.onSaved(
                PhoneNumber(
                    countryCode: _selectedCountry['dial_code'],
                    number: value,
                    countryISOCode: ''),
              );
            },
            onChanged: (value) {
              widget.onChanged(
                PhoneNumber(
                    countryCode: _selectedCountry['dial_code'],
                    number: value,
                    countryISOCode: ''),
              );
            },
            validator: widget.validator,
            keyboardType: widget.keyboardType,
          ),
        ),
      ],
    );
  }
}
