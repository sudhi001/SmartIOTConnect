import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_tools/network_tools.dart';
import 'package:smartiotconnect/ap/cubit/iot_starter_connection_cubit.dart';
import 'package:smartiotconnect/ap/cubit/network_cubit.dart';
import 'package:smartiotconnect/ap/view/network_config_page.dart';

class APPage extends StatelessWidget {
  const APPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NetworkCubit(),
      child: BlocBuilder<IotStarterConnectionCubit, IotStarterConnectionState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('SMART IOT Connect'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<NetworkConfigForm>(
                          builder: (context) => NetworkConfigForm(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: SafeArea(
              child: TextButton.icon(
                onPressed: () {
                  if (state.activeHost != null) {
                    context
                        .read<IotStarterConnectionCubit>()
                        .init(context, state.activeHost!);
                  } else {}
                },
                icon: const Icon(Icons.refresh),
                label: const Text('REFRESH DATA'),
              ),
            ),
            body: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text('Selected Device : '),
                    SizedBox(
                      height: 75,
                      child: BlocBuilder<NetworkCubit, NetworkState>(
                        builder: (networkcontext, networkState) {
                          if (networkState is NetworkStateLoading) {
                            return const Center(child: Text('Loading Devices'));
                          } else {
                            return Center(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ), // Border styling
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ), // Optional: rounded corners
                                ),
                                child: DropdownButton<ActiveHost>(
                                  underline: Container(),
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                  value: context
                                      .read<IotStarterConnectionCubit>()
                                      .state
                                      .activeHost,
                                  items: networkState.ipAddresses.map((ip) {
                                    return DropdownMenuItem<ActiveHost>(
                                      value: ip,
                                      child: Text(ip.address),
                                    );
                                  }).toList(),
                                  onChanged: (ActiveHost? newValue) {
                                    networkcontext
                                        .read<NetworkConfigFormCubit>()
                                        .submitForm(
                                          deviceIP: newValue?.address ?? '',
                                          password: networkcontext
                                              .read<NetworkConfigFormCubit>()
                                              .state
                                              .password,
                                          ssid: networkcontext
                                              .read<NetworkConfigFormCubit>()
                                              .state
                                              .ssid,
                                        );
                                    context
                                        .read<IotStarterConnectionCubit>()
                                        .init(context, newValue!);
                                  },
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (state.activeHost != null) {
                          context.read<NetworkCubit>().scanNetwork();
                        } else {}
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                if (state is IotStarterConnectionLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (state is IotStarterConnectionInitial)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Refresh to load sensor data'),
                    ),
                  ),
                if (state.data.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.data.length,
                      itemBuilder: (context, index) {
                        final key = state.data.keys.toList()[index];
                        final dynamic value = state.data.values.toList()[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: Text(key)),
                            Expanded(child: Text(value.toString())),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
