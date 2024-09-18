import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert'; // For decoding JSON
import 'package:http/http.dart' as http; // For making HTTP requests
import 'sidebar.dart'; // Import the sidebar

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433);
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();

  // Variables to store the latitude and longitude
  double? latitude;
  double? longitude;

  // Your Google API key (make sure this has access to Geocoding API)
  final String _apiKey = 'Add API Key here';

  // This method is called when the map is created
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Add marker when tapping on the map
  void _onMapTapped(LatLng position) {
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;

      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          infoWindow: InfoWindow(
            title: 'Tapped Location',
            snippet: '${position.latitude}, ${position.longitude}',
          ),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );

      print("Marker placed at Latitude: $latitude, Longitude: $longitude");
    });
  }

  // Method to search for a location and get its lat/lng
  Future<void> _goToLocation(String address) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$_apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          var location = data['results'][0]['geometry']['location'];
          LatLng newPosition = LatLng(location['lat'], location['lng']);

          setState(() {
            latitude = location['lat'];
            longitude = location['lng'];
          });

          print("Marker placed at Latitude: $latitude, Longitude: $longitude");

          mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: newPosition,
                zoom: 14.0,
              ),
            ),
          );

          setState(() {
            _markers.clear();
            _markers.add(
              Marker(
                markerId: MarkerId(newPosition.toString()),
                position: newPosition,
                infoWindow: InfoWindow(
                  title: 'Searched Location',
                  snippet: '$address',
                ),
                icon: BitmapDescriptor.defaultMarker,
              ),
            );
          });
        } else {
          throw Exception('Error: ${data['status']}');
        }
      } else {
        throw Exception('Failed to fetch location');
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png', // Path to your logo
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text('Flat Earthers'),
          ],
        ),
        backgroundColor: Colors.green[700],
      ),
      drawer: Sidebar(), // Add the sidebar here
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter location',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _goToLocation(_searchController.text);
                  },
                ),
              ),
              onSubmitted: (value) {
                _goToLocation(value);
              },
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              markers: _markers,
              onTap: _onMapTapped,
            ),
          ),
        ],
      ),
    );
  }
}
