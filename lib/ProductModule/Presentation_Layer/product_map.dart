import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProductMapScreen extends StatefulWidget {
  final double userLat;
  final double userLng;
  final double productLat;
  final double productLng;
  final String? productTitle;
  final String? productBody;
  final String? productImageUrl; // Image URL or path

  const ProductMapScreen({
    Key? key,
    required this.userLat,
    required this.userLng,
    required this.productLat,
    required this.productLng,
    required this.productTitle,
    required this.productBody,
    this.productImageUrl, // Optional image URL
  }) : super(key: key);

  @override
  _ProductMapScreenState createState() => _ProductMapScreenState();
}

class _ProductMapScreenState extends State<ProductMapScreen> {
  late GoogleMapController mapController;
  late LatLng userLatLng;
  late LatLng productLatLng;
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  late int polylineIndex;
  final List<Color> polylineColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
  ];
  late Color currentPolylineColor;

  @override
  void initState() {
    super.initState();
    userLatLng = LatLng(widget.userLat, widget.userLng);
    productLatLng = LatLng(widget.productLat, widget.productLng);

    // Create a series of points for the polyline to simulate animation
    polylineCoordinates = [userLatLng, productLatLng];
    polylineIndex = 0;
    currentPolylineColor =
        polylineColors[polylineIndex % polylineColors.length];

    _animatePolyline();
  }

  // Method to animate the polyline
  Future<void> _animatePolyline() async {
    // Add polyline animation by gradually adding more points
    for (int i = 0; i < polylineCoordinates.length; i++) {
      setState(() {
        // Add the next point to the polyline list
        _polylines.add(Polyline(
          polylineId: PolylineId('route_$i'),
          points: polylineCoordinates.sublist(0, i + 1),
          color: currentPolylineColor,
          width: 5,
        ));
      });
      await Future.delayed(
          Duration(milliseconds: 300)); // Delay for the animation effect
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (widget.productTitle != null && widget.productTitle!.isNotEmpty)
              ? '${widget.productTitle![0].toUpperCase()}${widget.productTitle!.substring(1)}'
              : 'Product Location',
        ),
      ),
      body: Column(
        children: [
          // Google Map Widget
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: productLatLng,
                zoom: 14.0,
              ),
              onMapCreated: (controller) {
                mapController = controller;
              },
              markers: {
                Marker(
                  markerId: const MarkerId('userLocation'),
                  position: userLatLng,
                  infoWindow: const InfoWindow(title: 'Your Location'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                ),
                Marker(
                  markerId: const MarkerId('productLocation'),
                  position: productLatLng,
                  infoWindow: InfoWindow(
                    title: (widget.productTitle != null &&
                            widget.productTitle!.isNotEmpty)
                        ? '${widget.productTitle![0].toUpperCase()}${widget.productTitle!.substring(1)}'
                        : 'Product Location',
                    snippet: (widget.productBody != null &&
                            widget.productBody!.isNotEmpty)
                        ? '${widget.productBody![0].toUpperCase()}${widget.productBody!.substring(1)}'
                        : 'No description available',
                  ),
                ),
              },
              polylines: _polylines,
            ),
          ),
          // Divider to separate map and product information
          const Divider(
            height: 2,
            color: Colors.grey,
            thickness: 1,
          ),
          // Product Information Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                if (widget.productImageUrl != null &&
                    widget.productImageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(8.0), // Rounded corners for image
                    child: Image.network(
                      widget.productImageUrl!,
                      width: 100, // Adjust the width of the image
                      height: 100, // Adjust the height of the image
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(width: 16), // Spacing between image and text
                // Product Details (Title and Description)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Title
                      Text(
                        (widget.productTitle != null &&
                                widget.productTitle!.isNotEmpty)
                            ? '${widget.productTitle![0].toUpperCase()}${widget.productTitle!.substring(1)}'
                            : 'Product Title',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Product Body (Description)
                      Text(
                        (widget.productBody != null &&
                                widget.productBody!.isNotEmpty)
                            ? '${widget.productBody![0].toUpperCase()}${widget.productBody!.substring(1)}'
                            : 'Product Description',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4, // Improve line spacing
                        ),
                        maxLines: 3,
                        overflow:
                            TextOverflow.ellipsis, // Truncate text if too long
                      ),
                    ],
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
