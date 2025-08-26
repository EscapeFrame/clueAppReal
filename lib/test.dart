import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  Future<String> fetchData() async {
    try {
      final dio = Dio();
      final response = await dio.get("http://127.0.0.1:8000/");
      return response.data.toString(); 
    } catch (e) {
      return "Error: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dio GET Test")),
      body: FutureBuilder<String>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            print(snapshot.data);
            return Center(
              child: Text(snapshot.data ?? "No data"),
            );
          }
        },
      ),
    );
  }
}