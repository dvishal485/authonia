import 'package:authonia/APIs/get_auth_data.dart';
import 'package:authonia/Components/add_manully.dart';
import 'package:authonia/Components/auth_card.dart';
import 'package:authonia/Components/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:authonia/Models/auth_data.dart';

class AuthScreen extends StatefulWidget {
  final List<AuthData> authData;

  const AuthScreen({super.key, required this.authData});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  refresh() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username')!;
    final password = prefs.getString('password')!;
    getAuthData(username, password).then((value) {
      if (value['error'] == 'false') {
        final authData = parseAuthData(value['content']!);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AuthScreen(authData: authData),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data refreshed!'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value['content']!),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
          ),
          // logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget.authData.isNotEmpty
              ? ListView.builder(
                  itemCount: widget.authData.length,
                  itemBuilder: (context, index) {
                    final data = widget.authData[index];
                    return AuthCard(authData: data);
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        'No data found!\nStart by tapping the + button below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: SizedBox(
                          width: 250,
                          child: Text(
                              'If you have added data, try refreshing the data by tapping the refresh button on the top right corner.'),
                        ),
                      )
                    ],
                  ),
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return SizedBox(
                height: 200,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: const Text('Scan/Import'),
                      trailing: const Icon(Icons.add_a_photo),
                      onTap: () {},
                    ),
                    ListTile(
                      title: const Text('Add Manually'),
                      trailing: const Icon(Icons.edit),
                      onTap: () async {
                        await addManually(context);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
