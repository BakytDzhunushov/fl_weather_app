import 'package:fl_weather_app1/components/custom_icon_button.dart';
import 'package:geolocator/geolocator.dart';
import 'models/weather.dart';
import 'package:fl_weather_app1/constants/api_const.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:developer';

List cities = <String>[
  'Bishkek',
  'Osh',
  'Jalal-Abad',
  'Karakol',
  'Batken',
  'Naryn',
  'Talas',
  'Tokmok',
  'Moscow',
  'Paris',
  'Rome',
  'London',
  'Beijing',
  'Tokyo',
  'Washington',
  'Sydney'
];
class City {
  final String name;
  final String backgroundImage;

  City(this.name, this.backgroundImage);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  City selectedCity = City('Bishkek', '/Bishkek.jpg');
  Weather? weather;
  Future<void> weatherLocatio() async {
    setState(() {
      weather = null;
    });
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always &&
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition();
        final dio = Dio();
        final resp = await dio.get(
            ApiConst.latLongaddres(position.latitude, position.longitude));
        if (resp.statusCode == 200) {
          weather = Weather(
            id: resp.data['current']['weather'][0]['id'],
            main: resp.data['current']['weather'][0]['main'],
            description: resp.data['current']['weather'][0]['description'],
            icon: resp.data['current']['weather'][0]['icon'],
            city: resp.data['timezone'],
            // country: resp.data['sys']['country'],
            temp: resp.data['current']['temp'],
          );
        }
        setState(() {});
          }
      } else {
        Position position = await Geolocator.getCurrentPosition();
        final dio = Dio();
        final resp = await dio.get(
            ApiConst.latLongaddres(position.latitude, position.longitude));
        if (resp.statusCode == 200) {
          weather = Weather(
            id: resp.data['current']['weather'][0]['id'],
            main: resp.data['current']['weather'][0]['main'],
            description: resp.data['current']['weather'][0]['description'],
            icon: resp.data['current']['weather'][0]['icon'],
            city: resp.data['timezone'],
            temp: resp.data['current']['country']['temp'],
          );
        }
        setState(() {});
      }
    } 

  Future<void> weatherName([String? name]) async {
    final dio = Dio();
    var response2 = await dio.get(ApiConst.address(name ?? 'Бишкек'));
    final response = response2;
    if (response.statusCode == 200) {
      weather = Weather(
        id: response.data['weather'][0]['id'],
        main: response.data['weather'][0]['main'],
        description: response.data['weather'][0]['description'],
        icon: response.data['weather'][0]['icon'],
        city: response.data['name'],
        country: response.data['sys']['country'],
        temp: response.data['main']['temp'],
      );
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    weatherName();
  }

  @override
  Widget build(BuildContext context) {
    log('max W ==> ${MediaQuery.of(context).size.width}');
    log('max H ==> ${MediaQuery.of(context).size.height}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: weather == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(selectedCity.backgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomIconButton(
                        icon: Icons.near_me_outlined,
                        onPressed: () async {
                            await weatherLocatio();
                          },
                      ),
                      CustomIconButton(
                        icon: Icons.location_city_rounded,
                        onPressed: () {
                          showBottom();
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      Text('${(weather!.temp - 274.15).floorToDouble()}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 90,
                              fontWeight: FontWeight.bold)),
                      Image.network(
                        ApiConst.getIcon(weather!.icon, 4),
                        height: 160,
                        fit: BoxFit.fitHeight,
                      ),
                    ],
                  ),
                  Expanded(
                    child: FittedBox(
                      child: Text(
                        weather!.city,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void showBottom() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.black12,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 7),
          decoration: BoxDecoration(
            color: Colors.red,
            border: Border.all(color: Colors.blue),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
          ),
          child: ListView.builder(
            itemCount: cities.length,
            itemBuilder: (BuildContext context, int index) {
              final city = cities[index];
             // final cit = weatherName(city);
              return Card(
                child: ListTile(
                  onTap: () async {
                    setState(() {
                      selectedCity = City('$city', '/$city.jpg');
                      weather = null;
                    });
                    weatherName(city);
                    Navigator.pop(context);
                  },
                  title: Text(city),
                ),
              );
            },
          ),
        );
      },
    );
  }
}