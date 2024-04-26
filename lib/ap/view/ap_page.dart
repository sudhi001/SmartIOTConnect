import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartiotconnect/ap/cubit/iot_starter_connection_cubit.dart';
import 'package:smartiotconnect/ap/view/network_config_page.dart';

class APPage extends StatelessWidget {
  const APPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IotStarterConnectionCubit(),
      child: BlocBuilder<IotStarterConnectionCubit, IotStarterConnectionState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Default Wifi Connection'),
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
                  context.read<IotStarterConnectionCubit>().init(context);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('REFRESH DATA'),
              ),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state is IotStarterConnectionLoading)
                  const Center(
                    child: CircularProgressIndicator(),
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
