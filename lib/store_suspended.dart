import 'package:bakul_payu/homepage.dart';
import 'package:flutter/material.dart';

class StoreSuspendedPage extends StatefulWidget {
  const StoreSuspendedPage({super.key});

  @override
  State<StoreSuspendedPage> createState() => _StoreSuspendedPageState();
}

class _StoreSuspendedPageState extends State<StoreSuspendedPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bakul Payu Admin"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning,
                size: 200,
              ),
              const Text(
                  "Toko anda telah di-suspend mohon segera menhubungi admin kami melalui email: bakulpayuadmin@gmail.com"),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  child: const Text("Ok"))
            ],
          ),
        ),
      ),
    );
  }
}
