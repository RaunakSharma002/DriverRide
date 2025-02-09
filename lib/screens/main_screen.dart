import 'package:driver_ride/global/global.dart';
import 'package:driver_ride/splashScreen/splash_screen.dart';
import 'package:driver_ride/tabPages/home_tab.dart';
import 'package:driver_ride/tabPages/profile_tab.dart';
import 'package:driver_ride/tabPages/ratings_tab.dart';
import 'package:flutter/material.dart';

import '../tabPages/earning_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin{
  TabController? tabController;
  int selectedIndex = 0;

  onItemClicked(int index){
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          HomeTabPage(),
          EarningTabPage(),
          RatingsTabPage(),
          ProfileTabPage()
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: "Earning"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Rating"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
        unselectedItemColor: darkTheme ? Colors.black54 : Colors.white54,
        selectedItemColor: darkTheme ? Colors.black : Colors.white,
        backgroundColor: darkTheme ? Colors.amber[400] : Colors.blue,
        type:  BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 14),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
