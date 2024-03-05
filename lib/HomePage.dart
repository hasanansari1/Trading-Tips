
// ignore_for_file: file_names

import 'package:equitystaruser/Guidelines/FreeGuidelinesScreen.dart';
import 'package:equitystaruser/IPO/IPOScreen.dart';
import 'package:equitystaruser/IntraDay/IntraDayScreen.dart';
import 'package:equitystaruser/LongTerm/LongTermScreen.dart';
import 'package:equitystaruser/ShortTerm/ShortTermScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'AuthView/LoginPage.dart';
import 'Provider.dart';
import 'ShareScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to exit the app?'),
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
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.deepPurpleAccent,
          elevation: 10,
          title: const Text(
            "Home",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
          centerTitle: true,
        ),
          drawer: SizedBox(
            width: 250,
            child: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.deepPurpleAccent),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 40,
                          backgroundImage: AssetImage('assets/images/HomePageLogo.png'),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Home', style: TextStyle(fontSize: 20)),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text("Intraday", style: TextStyle(fontSize: 20)),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> const IntraDayScreen()));
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text("Short Term", style: TextStyle(fontSize: 20)),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> const ShortTermScreen()));
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text("Long Term", style: TextStyle(fontSize: 20)),
                      onTap: ()
                      {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> const LongTermScreen()));
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text("IPO", style: TextStyle(fontSize: 20)),
                      onTap: ()
                      {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> const IPOScreen()));
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text("Theme", style: TextStyle(fontSize: 20)),
                      onTap: ()
                      {
                        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();

                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text("Logout", style: TextStyle(fontSize: 20)),
                      onTap: ()
                      {
                        FirebaseAuth.instance.signOut();
                        {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                                  (route) => false);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Center(
                child: Image.asset("assets/images/HomePageLogo.png", height: 100, width: 100,),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 20.0,
                  crossAxisSpacing: 20.0,
                  children: List.generate(6, (index) {

                    List<Map<String, dynamic>> cardData = [
                      {
                        "image": "assets/images/Intraday.png",
                        "text": "IntraDay",
                        "onTap": _openIntraDayScreen,
                      },
                      {
                        "image": "assets/images/ShortTerm.png",
                        "text": "Short Term",
                        "onTap": _openShortTermScreen,
                      },
                      {
                        "image": "assets/images/LongTerm.png",
                        "text": "Long Term",
                        "onTap": _openLongTermScreen,
                      },
                      {
                        "image": "assets/images/IPO.png",
                        "text": "IPO",
                        "onTap": _openIPOScreen,
                      },
                      {
                        "image": "assets/images/Guidelines.png",
                        "text": "Free Guidelines",
                        "onTap": _openGuidelinesScreen,
                      },
                      {
                        "image": "assets/images/share.png",
                        "text": "Share",
                        "onTap": _openShareScreen,
                      },
                    ];
                    return GestureDetector(
                      onTap: cardData[index]["onTap"],
                      child: Card(
                        color: CupertinoColors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              cardData[index]["image"],
                              width: 48.0,
                              height: 48.0,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              cardData[index]["text"],
                              style: const TextStyle(
                                fontSize: 17.0,
                                color: Colors.black,
                              ),
                            ),

                          ],
                        ),
                      ),
                    );
                  }
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openIntraDayScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const IntraDayScreen(),
    ));
  }

  void _openShortTermScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ShortTermScreen(),
    ));
  }

  void _openLongTermScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const LongTermScreen(),
    ));
  }

  void _openIPOScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const IPOScreen(),
    ));
  }

  void _openGuidelinesScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ViewGuidelinesScreen(),
    ));
  }

  void _openShareScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ShareScreen(),
    ));
  }
}
