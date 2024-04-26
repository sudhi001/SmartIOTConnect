import 'package:flutter/material.dart';

class BottomSheetUtils {
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                ),
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
