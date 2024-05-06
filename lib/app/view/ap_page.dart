import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartiotconnect/app/cubit/device_storage_cubit.dart';
import 'package:smartiotconnect/app/view/console_page.dart';
import 'package:smartiotconnect/app/view/data_list_page.dart';
import 'package:smartiotconnect/app/view/settings_page.dart';
import 'package:smartiotconnect/soundpool.dart';
import 'package:smartiotconnect/utils/dialof_utils.dart';



class APPage extends StatefulWidget {
  const APPage({super.key});

  @override
  State<StatefulWidget> createState()  => _MyHomePageState();

  }

  class _MyHomePageState extends State<APPage> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  BlocBuilder<DeviceConnectionCubit, bool>(
            builder: (bcontext, bstate) {
              return Scaffold(
                body: IndexedStack(
                  index: tabIndex,
                  children: [
                    const ConsolePage(), //
                    const DataListPage(),// List of tab contents
                    SettingsConfigForm(),
                    fui.ProfileScreen(
                      providers: [fui.EmailAuthProvider()],
                      actions: [
                        fui.SignedOutAction((context) {
                          Navigator.pushReplacementNamed(context, '/sign-in');
                        }),
                      ],
                    ),
                  ],
                ),
                bottomNavigationBar: BottomNavigationBar(
                  backgroundColor: Colors.black,
                    selectedItemColor: Colors.greenAccent,
                    unselectedItemColor: Colors.white,
                    currentIndex: tabIndex,
                    elevation: 0,
                    enableFeedback: true,
                    onTap: (value) {
                      if(value ==2) {
                        if (!bstate) {
                          BottomSheetUtils.showMessage(
                            context,
                            message: 'Please connect the device first.',
                          );
                          return;
                        }
                      }
                      // ignore: use_build_context_synchronously
                       SoundProvider.of(context).click!.play();
                      setState(() {
                        tabIndex = value; // Update the selected tab index
                      });
                    },
                    items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',

                ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.data_array),
                        label: 'Logs',

                      ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Setting',
                  ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.verified_user),
                        label: 'Profile',
                      ),// // Dynamically create tabs
                ],
              ),);
            },
          ),
    );
  }
}
