import 'package:asgard_task/ProductModule/Data_Layer/models/product_model.dart';
import 'package:asgard_task/ProductModule/Data_Layer/product_blocs/product_bloc.dart';
import 'package:asgard_task/ProductModule/Data_Layer/product_blocs/product_event.dart';
import 'package:asgard_task/ProductModule/Data_Layer/product_blocs/product_state.dart';
import 'package:asgard_task/ProductModule/Data_Layer/repositories/product_repo.dart';
import 'package:asgard_task/widgets/error_UI.dart';
import 'package:asgard_task/widgets/shimmer_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math';

import 'product_map.dart';

class ProductListScreen extends StatefulWidget {
  final ProductRepo repository;

  const ProductListScreen({Key? key, required this.repository})
      : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  Position? _userPosition;
  final Set<Marker> _markers = {}; // Set to hold markers
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

//***************** Location Permissions *******************/

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _userPosition = position;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

//***************** Map Related Work  *******************/

  void _addMarkers(ProductLoaded state) {
    _markers.clear(); // Clear existing markers

    for (var product in state.products) {
      final marker = Marker(
        markerId: MarkerId(product.id.toString()), // Unique ID for the marker
        position: LatLng(
          product.coordinates!.first,
          product.coordinates!.last,
        ),
        infoWindow: InfoWindow(
          title: capitalizeFirstLetter(
              product.title ?? 'No Title'), // Title shown in the info window
        ),
        onTap: () {
          // Show product details in a popup when the marker is tapped
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(capitalizeFirstLetter(product.title ?? 'No Title')),
                content: Text(
                    capitalizeFirstLetter(product.body ?? 'No Description')),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      );
      _markers.add(marker); // Add the marker to the map
    }

    if (_mapController != null && _markers.isNotEmpty) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          _getBounds(state.products),
          50.0, // Padding for the camera
        ),
      );
    }
  }

  LatLngBounds _getBounds(List<ProductModel> products) {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (var product in products) {
      if (product.coordinates != null && product.coordinates!.isNotEmpty) {
        final lat = product.coordinates!.first;
        final lng = product.coordinates!.last;

        minLat = min(minLat, lat);
        maxLat = max(maxLat, lat);
        minLng = min(minLng, lng);
        maxLng = max(maxLng, lng);
      }
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

//***************** UpperCase Latters  *******************/

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

//***************** OnBack Press Handling  *******************/

  Future<bool> _onBackPressed() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

//***************** Distance Calculation   *******************/

  String calculateDistance(double productLat, double productLng) {
    if (_userPosition == null) return 'Distance unavailable';

    double userLat = _userPosition!.latitude;
    double userLng = _userPosition!.longitude;

    double distanceInMeters =
        Geolocator.distanceBetween(userLat, userLng, productLat, productLng);
    double distanceInKm = distanceInMeters / 1000;

    return '${distanceInKm.toStringAsFixed(2)} km away';
  }

//***************** Swip Refresh  *******************/

  Future<void> _onRefresh() async {
    context
        .read<ProductBloc>()
        .add(FetchProducts()); // Fetch products on pull to refresh
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: BlocProvider(
        create: (context) =>
            ProductBloc(widget.repository)..add(FetchProducts()),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Product List'),
          ),
          body: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return const ShimmerLoader();
              } else if (state is ProductLoaded) {
                _addMarkers(state); // Add markers when the data is loaded
                return RefreshIndicator(
                  onRefresh: _onRefresh, // Trigger refresh on swipe down
                  child: Column(
                    children: [
                      // Product list takes the available space first
                      Expanded(
                        child: _buildProductList(state),
                      ),
                      // Map container with a fixed height below the list
                      SizedBox(
                        height: 250.0, // Set a fixed height for the map
                        child: _buildMap(),
                      ),
                    ],
                  ),
                );
              } else if (state is ProductError) {
                return ErrorUI(
                  message: state.message,
                  icon: Icons.error_outline,
                  color: Colors.red,
                  onRetry: () {
                    context
                        .read<ProductBloc>()
                        .add(FetchProducts()); // Retry logic
                  },
                );
              }

              return const Center(
                child: Text(
                  'Press the button to fetch products',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

//***************** Product List Widget *******************/

  Widget _buildProductList(ProductLoaded state) {
    if (state.products.isEmpty) {
      return const Center(
        child: Text(
          'No products available.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8.0),
      itemCount: state.products.length,
      itemBuilder: (context, index) {
        final product = state.products[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          child: ListTile(
            contentPadding: const EdgeInsets.all(12.0),
            leading: _buildProductImage(product.imageUrl),
            title: Text(
              (product.title != null && product.title!.isNotEmpty)
                  ? '${product.title![0].toUpperCase()}${product.title!.substring(1)}'
                  : 'No Title',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.body ?? 'No Description',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  calculateDistance(
                      product.coordinates!.first, product.coordinates!.last),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: _userPosition == null
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductMapScreen(
                            userLat: _userPosition!.latitude,
                            userLng: _userPosition!.longitude,
                            productLat: product.coordinates!.first,
                            productLng: product.coordinates!.last,
                            productTitle: product.title,
                            productBody: product.body,
                            productImageUrl: product.imageUrl,
                          ),
                        ),
                      ),
              child: const Text('View Direction'),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8.0),
    );
  }

//***************** Image Widget *******************/
  Widget _buildProductImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        imageUrl ?? '',
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.image,
              color: Colors.grey,
              size: 40,
            ),
          );
        },
      ),
    );
  }

//***************** Map Widget *******************/
// Map widget with shimmer effect while loading
  Widget _buildMap() {
    if (_userPosition == null || _markers.isEmpty) {
      // Show shimmer effect while loading
      return Center(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: double.infinity,
            height: 300.0, // Height of the map container
            color: Colors.white,
          ),
        ),
      );
    }

    // Once data is loaded, show the map
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(_userPosition!.latitude, _userPosition!.longitude),
          zoom: 10.0, // Adjust zoom level as needed
        ),
        markers: _markers,
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
