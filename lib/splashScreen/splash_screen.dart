import 'dart:async';

import 'package:drivers_app/authentication/login_screen.dart';
import 'package:drivers_app/authentication/signup_screen.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/mainScreens/main_screen.dart';
import 'package:flutter/material.dart';


class MySplashScreen extends StatefulWidget 
{
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}



class _MySplashScreenState extends State<MySplashScreen> 
{
  
  startTimer()//how much time to display
  {
    Timer(const Duration(seconds: 3), () async
    {
      if(await fAuth.currentUser != null) //identify user register or not
        {
          currentFirebaseUser = fAuth.currentUser;
          Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
        }
      else
        {
          Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
        }

    });
  }
  
  
  @override
  void initState() { //called when go to any page
    super.initState(); //execute first/automatically
    
    startTimer();
  }

  @override
  Widget build(BuildContext context)
  {
    return Material(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Image.asset("images/logo2.png"),

              const SizedBox(height: 10,),

              const Text(
                "Welcome to",
                //"Ride Sharing Application",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              ),
              const Text(
                "UTM Ridex",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}
