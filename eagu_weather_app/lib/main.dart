import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MaterialApp(
    title: 'EAGU Weather App',
    home: CityPage(),
  ));
}

class CityPage extends StatelessWidget {
  const CityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController cityController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('EAGU Weather App'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '도시 이름',
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeatherPage(city: cityController.text),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                foregroundColor: Colors.white,
              ),
              child: const Text('날씨 정보 얻기'),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherPage extends StatefulWidget {
  final String city;

  const WeatherPage({super.key, required this.city});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late String _temperature = '';
  late String _description = '';
  late String _dustLevel = '';
  late String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _fetchDustInfo();
  }

  Future<void> _fetchWeather() async {
    const apiKey = 'd94efd92f6aabb4cbc01b958df71208a'; // OpenWeatherMap API 키
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=${widget.city}&appid=$apiKey&units=metric');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _temperature = data['main']['temp'].toString();
          _description = data['weather'][0]['description'];
          _errorMessage = '';
        });
      } else {
        setState(() {
          _errorMessage = '도시를 찾을 수 없습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '날씨 정보를 가져오는데 실패했습니다.';
      });
    }
  }

  Future<void> _fetchDustInfo() async {
    const apiKey = 'DvRGLsyiofsY5G3PjxuvmtPVEOgjJ1qN3GwZat%2B8WUhUF9KSzHlkouNoZH74IBs0MT9KX6C7fVvPWVhopYv7yQ%3D%3D'; // 한국 공공 데이터 포털 API 키
    final url = Uri.parse(
        'http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?serviceKey=$apiKey&returnType=json&numOfRows=1&pageNo=1&stationName=${widget.city}&dataTerm=DAILY&ver=1.0');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _dustLevel = '미세먼지: ${data['response']['body']['items'][0]['pm10Value']} ㎍/㎥';
        });
      } else {
        setState(() {
          _errorMessage = '미세먼지 정보를 가져올 수 없습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '미세먼지 정보를 가져오는데 실패했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Info'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Center(
        child: _errorMessage.isEmpty
            ? Card(
                margin: const EdgeInsets.all(20),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Temperature: $_temperature °C',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Description: $_description',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _dustLevel,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[400],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Back'),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Back'),
                  ),
                ],
              ),
      ),
    );
  }
}
