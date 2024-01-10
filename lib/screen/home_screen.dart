import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gardenio/components/content_box.dart';
import 'package:gardenio/models/weather_model.dart';
import 'package:gardenio/screen/disease_history_screen.dart';
import 'package:gardenio/screen/recipesbook_screen.dart';
import 'package:gardenio/screen/diseasecheck_screen.dart';
import 'package:gardenio/screen/gardenpreplan_screen.dart';
import 'package:gardenio/screen/profile_screen.dart';
import 'package:gardenio/screen/recipe_history_screen.dart';
import 'package:gardenio/services/weather_services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // weather api key
  // apiKey = c5637386d600144341ebeee38e35c864, replace this with the apiKey below
  final _weatherService = WeatherService('apiKey');

  Weather? _weather;

  // Refer to the current user
  final user = FirebaseAuth.instance.currentUser!;

  // Recipe history data
  List<Map<String, dynamic>> recipeHistory = [];
  List<Map<String, dynamic>> diseaseHistory = [];

  // Fetch recipe history data
  _fetchRecipeHistory() async {
    try {
      // Retrieve the document snapshot using the user's UID
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Check if the document exists
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data();

        // Retrieve the 'recipeHistory' field from the document
        var rawRecipeHistory = data?['recipeHistory'];

        // Check if 'recipeHistory' is a List and not null
        if (rawRecipeHistory is List) {
          // Convert each item to Map<String, dynamic>
          recipeHistory = rawRecipeHistory
              .cast<Map<String, dynamic>>()
              .toList(); // Assuming each item is a Map<String, dynamic>
        }
      }
    } catch (e) {
      // print("Error fetching recipe history: $e");
    }
  }

  _fetchDiseaseHistory() async {
    try {
      // Retrieve the document snapshot using the user's UID
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Check if the document exists
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data();

        // Retrieve the 'recipeHistory' field from the document
        var rawDiseaseHistory = data?['diseaseHistory'];

        // Check if 'recipeHistory' is a List and not null
        if (rawDiseaseHistory is List) {
          // Convert each item to Map<String, dynamic>
          diseaseHistory = rawDiseaseHistory
              .cast<Map<String, dynamic>>()
              .toList(); // Assuming each item is a Map<String, dynamic>
        }
      }
    } catch (e) {
      // print("Error fetching recipe history: $e");
    }
  }

  // fetch weather
  _fetchWeather() async {
    // get the current city name
    String cityName = await _weatherService.getCurrentCity();

    // get weather for city
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      // print(e);
    }
  }

  // init state
  @override
  void initState() {
    super.initState();

    // fetch weather on startup
    _fetchWeather();

    // fetch recipe history on startup
    _fetchRecipeHistory();

    // fetch disease history on startup
    _fetchDiseaseHistory();
  }

  // Wrap the asynchronous calls in a method
  Future<void> _initializeData() async {
    await _fetchRecipeHistory();
    await _fetchDiseaseHistory();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Garden.io',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.lightGreen[400],
        ),
        drawer: const NavigationDrawer(),
        body: FutureBuilder<void>(
          future: _initializeData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return HomeBodyContent(
                weather: _weather,
                recipeHistory: recipeHistory,
                diseaseHistory: diseaseHistory,
                rebuildCallback: _fetchData,
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );

  void _fetchData() {
    _fetchWeather();
    _fetchRecipeHistory();
    _fetchDiseaseHistory();
    setState(() {}); // Trigger a rebuild
  }
}

// weather animation
String getWeatherAnimation(String? mainCondition) {
  if (mainCondition == null) return 'assets/sunny.json'; // default to sunny

  switch (mainCondition.toLowerCase()) {
    case 'mist':
      return 'assets/mist.json';
    case 'fog':
      return 'assets/cloudy.json';
    case 'clouds':
      return 'assets/cloudy.json';
    case 'clear':
      return 'assets/sunny.json';
    case 'shower rain':
      return 'assets/rainy.json';
    case 'thunderstorm':
      return 'assets/thunder.json';
    default:
      return 'assets/sunny.json';
  }
}

// weather api
class WeatherContent extends StatelessWidget {
  final Weather? weather;

  const WeatherContent({Key? key, this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.lightGreen[100],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Weather in: ${weather?.cityName ?? "loading city..."}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.lightBlue, // Set your desired background color
                  borderRadius:
                      BorderRadius.circular(10), // Optional: Add borderRadius
                ),
                child: Lottie.asset(
                  getWeatherAnimation(weather?.mainCondition),
                  height: 100,
                  width: 100,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temperature: ${weather?.temperature.round()}°C',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Condition: ${weather?.mainCondition ?? ""}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// sign user out method
void signUserOut() {
  FirebaseAuth.instance.signOut();
}

String formatDate(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  String formattedDate = DateFormat('MMMM d, y - h:mm:ss a', 'en_US').format(dateTime.toUtc().add(const Duration(hours: 8)));
  return formattedDate;
}



// home screen content
class HomeBodyContent extends StatelessWidget {
  final Weather? weather;
  final List<Map<String, dynamic>> recipeHistory;
  final List<Map<String, dynamic>> diseaseHistory;
  final VoidCallback rebuildCallback;

  const HomeBodyContent({
    Key? key,
    this.weather,
    required this.recipeHistory,
    required this.diseaseHistory,
    required this.rebuildCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // weather api content
            WeatherContent(weather: weather),

            const SizedBox(height: 12),

            const Text(
              'Recent Recipes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.left,
            ),

            // First Content Box
            ContentBox(
              title: recipeHistory.isEmpty
                  ? "You have yet to create your crops!"
                  : 'Last Recipe: ${recipeHistory.last["title"]}',
              descriptionFirst: 'Go to Recipes Book',
              descriptionSecond: 'History',
              secondBtn: true,
              onPressedFirst: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RecipesBookScreen(),
                  ),
                );
                rebuildCallback();
              },
              onPressedSecond: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RecipeHistoryScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            const Text(
              'Recent Garden Plans',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.left,
            ),

            // Second Content Box
            ContentBox(
              title: 'You have yet to plan your garden!',
              descriptionFirst: 'Go to Garden Preplanning',
              descriptionSecond: '',
              secondBtn: false,
              onPressedFirst: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GardenPreplanScreen(),
                  ),
                );
              },
              onPressedSecond: () {},
            ),

            const SizedBox(height: 12),

            const Text(
              'Recent Diseases',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.left,
            ),

            // Third Content Box
            ContentBox(
              title: diseaseHistory.isEmpty
                  ? "You have yet to check your plants!"
                  : '${formatDate(diseaseHistory.last["time"])}: \n ${diseaseHistory.last["output"]}',
              descriptionFirst: 'Go to Disease Check',
              descriptionSecond: 'History',
              secondBtn: true,
              onPressedFirst: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DiseaseCheckScreen(),
                  ),
                );
                rebuildCallback();
              },
              onPressedSecond: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DiseaseHistoryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Drawer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildHeader(context),
              const Divider(),
              buildMenuItems(context),
            ],
          ),
        ),
      );

  Widget buildHeader(BuildContext context) => Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
      );

  Widget buildMenuItems(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          runSpacing: 16,
          children: [
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () =>
                  // Pop the current route off the stack, essentially navigating back to the current screen
                  Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.book_outlined),
              title: const Text('Recipes Book'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const RecipesBookScreen(),
              )),
            ),
            ListTile(
              leading: const Icon(Icons.table_bar),
              title: const Text('Garden Preplanning'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const GardenPreplanScreen(),
              )),
            ),
            ListTile(
              leading: const Icon(Icons.camera_outlined),
              title: const Text('Disease Check'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const DiseaseCheckScreen(),
              )),
            ),
            ListTile(
              leading: const Icon(Icons.people_outlined),
              title: const Text('Profile'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              )),
            ),
            const Divider(), // Divider before the sign-out tile
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                // Add your sign-out logic here
                signUserOut(); // Close the drawer
              },
            ),
          ],
        ),
      );
}
