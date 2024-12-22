Flutter Product Map App
This Flutter application uses the BLoC pattern for state management and displays a map with product markers. Each marker corresponds to a product, and clicking a marker shows a popup with the product's title and description.


Project Setup

Prerequisites
Before running the project, ensure you have the following installed:

    Flutter (https://flutter.dev/docs/get-started/install)
    Dart (comes bundled with Flutter)
    Android Studio or Visual Studio Code for development
    Xcode (if developing for iOS)

Dependencies
This project uses several key dependencies for state management, map functionality, and UI rendering:

    flutter_bloc for BLoC state management
    google_maps_flutter for displaying the map
    shimmer for loading animations
    http for API requests (if your data comes from a remote server)

Installation
Clone the repository:

         * git clone https://github.com/Mouneshwara/Asgard/tree/main
         *flutter pub get
    # Set up the Google Maps API:
    # Follow the official documentation to get your API key for Google Maps: Google Maps API Setup
    # Add the API key to your android/app/src/main/AndroidManifest.xml (for Android) 
    <uses-permission android:name="android.permission.INTERNET" />

             * flutter run
Main Components

    # BLoC (Business Logic Component):
    
    The ProductBloc class is the heart of the app's state management, handling events such as loading products and adding markers.
    The app reacts to events like loading product data and displaying the map markers.
    Model:
    
    The Product model represents the data for each product, including the title, description, and location (latitude and longitude).
    UI:
    
    The UI is split into multiple components:
    HomePage: Displays a list of products and the map below it.
    ProductList: Displays the products in a list view.
    GoogleMap: Displays the map and the markers for each product.
    Widgets:
    
    The _buildMap method displays the map, showing markers for each product.
    A custom Shimmer widget is used for the loading state, showing a placeholder while the map and product data are being fetched.
