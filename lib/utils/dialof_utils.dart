import 'package:flutter/material.dart';

class BottomSheetUtils {
  static Future<dynamic> showMessage(
    BuildContext context, {
    required String message,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 32),
              Text(
                message,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.green),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Okay'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  static Future<dynamic> showBottomSheet(
    BuildContext context, {
    required String title,
    required String message,
    required String positiveText,
    required VoidCallback onPositivePressed,
    required String negativeText,
    required VoidCallback onNegativePressed,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.green),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.green),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: onNegativePressed,
                    child: Text(negativeText),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: onPositivePressed,
                    child: Text(positiveText),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
