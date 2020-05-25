import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/settings_bloc.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TemperatureUnits _unita;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[500],
      appBar: AppBar(
          backgroundColor: Colors.lightBlue[800], title: Text('Impostazioni')),
      body: ListView(
        children: <Widget>[
          BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
            _unita = state.temperatureUnits;
            return Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Scegli tra gradi Celcius o Fahrenheit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  title: Text(
                    'Celsius',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  leading: Radio(
                      value: TemperatureUnits.celsius,
                      groupValue: _unita,
                      onChanged: (TemperatureUnits value) {
                        setState(() {
                          _unita = value;
                        });
                        BlocProvider.of<SettingsBloc>(context)
                            .add(TemperatureUnitsToggled());
                      }),
                ),
                ListTile(
                  title: Text(
                    'Farhenheit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  leading: Radio(
                      value: TemperatureUnits.fahrenheit,
                      groupValue: _unita,
                      onChanged: (TemperatureUnits value) {
                        setState(() {
                          _unita = value;
                        });
                        BlocProvider.of<SettingsBloc>(context)
                            .add(TemperatureUnitsToggled());
                      }),
                )
              ],
            );
          }),
        ],
      ),
    );
  }
}
