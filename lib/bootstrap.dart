import 'dart:async';
import 'dart:developer';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_tools/network_tools.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartiotconnect/ap/cubit/iot_starter_connection_cubit.dart';
import 'package:smartiotconnect/ap/cubit/network_cubit.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Register DartPingIOS
  DartPingIOS.register();
  final appDocDirectory = await getApplicationDocumentsDirectory();
  await configureNetworkTools(appDocDirectory.path, enableDebugging: true);
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Add cross-flavor configuration here

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<NetworkConfigFormCubit>(
          create: (_) => NetworkConfigFormCubit(),
        ),
        BlocProvider<IotStarterConnectionCubit>(
          create: (_) => IotStarterConnectionCubit(),
        ),
      ],
      child: await builder(),
    ),
  );
}
