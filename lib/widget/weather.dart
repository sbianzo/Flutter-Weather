import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/theme_bloc.dart';
import '../widget/widgets.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_state.dart';
import '../bloc/weather_event.dart';

class Weather extends StatefulWidget {
  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  Completer<void> _refreshCompleter;
  final TextEditingController _textController = TextEditingController();
  String city;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();

    _getInitialLocation().then((value) => {
          setState(() {
            city = value;
          })
        });
  }

  Future<String> _getInitialLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final location = prefs.getString('Location');
    if (location == null) return '';
    return location;
  }

  Future<void> _setLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('Location', location);
    print(prefs.getString('Location'));
  }

  Future<void> _resetLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('Location', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      appBar: AppBar(
        title: Text('Meteo'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[800],
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Settings(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: BlocConsumer<WeatherBloc, WeatherState>(
          listener: (context, state) {
            if (state is WeatherLoaded) {
              BlocProvider.of<ThemeBloc>(context).add(
                WeatherChanged(condition: state.weather.condition),
              );
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
          },
          builder: (context, state) {
            if (state is WeatherEmpty) {
              if (city != null) {
                BlocProvider.of<WeatherBloc>(context)
                    .add(FetchWeather(city: city));
              }

              return searchBar();
            }
            if (state is WeatherLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is WeatherLoaded) {
              final weather = state.weather;

              return BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  return GradientContainer(
                    color: themeState.color,
                    child: RefreshIndicator(
                      onRefresh: () {
                        BlocProvider.of<WeatherBloc>(context).add(
                          RefreshWeather(city: weather.location),
                        );
                        return _refreshCompleter.future;
                      },
                      child: ListView(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 100.0),
                            child: Center(
                              child: Location(location: weather.location),
                            ),
                          ),
                          Center(
                            child: LastUpdated(dateTime: weather.lastUpdated),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 50.0),
                            child: Center(
                              child: CombinedWeatherTemperature(
                                weather: weather,
                              ),
                            ),
                          ),
                          SizedBox(height: 80),
                          searchBar()
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            if (state is WeatherError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    'Qualcosa è andato storto!',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  searchBar()
                ],
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget searchBar() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: TextField(
            controller: _textController,
            decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    _resetLocation();
                  },
                  icon: Icon(Icons.clear),
                ),
                hintText: 'Seleziona una località',
                border: InputBorder.none,
                icon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    String c = _textController.text;
                    _setLocation(c);

                    BlocProvider.of<WeatherBloc>(context)
                        .add(FetchWeather(city: c));
                  },
                )),
          ),
        ),
      ],
    ));
  }
}
