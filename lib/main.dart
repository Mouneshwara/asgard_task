import 'package:asgard_task/ProductModule/Data_Layer/product_blocs/product_bloc.dart';
import 'package:asgard_task/ProductModule/Data_Layer/repositories/product_repo.dart';
import 'package:asgard_task/ProductModule/Presentation_Layer/product_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final productRepo = ProductRepo();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProductBloc(productRepo),
        ),
      ],
      child: MaterialApp(
        home: ProductListScreen(repository: productRepo),
      ),
    );
  }
}
