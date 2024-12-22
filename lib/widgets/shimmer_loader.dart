import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: 10, // Number of shimmer items
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12.0),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                ),
                title: Container(
                  height: 16.0,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.only(bottom: 8.0),
                ),
                subtitle: Container(
                  height: 14.0,
                  color: Colors.grey[300],
                  width: double.infinity,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
