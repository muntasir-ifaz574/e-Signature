import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Utilities {
  static void customSnackBar({
    required BuildContext context,
    required String snackText,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(
        snackText,
        style: TextStyle(color: Colors.white, fontSize: 14.0),
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Future customDialog({
    required BuildContext context,
    required String snackText,
    SnackBarBehavior? snackBehavior,
    SnackBarAction? snackBarAction,
    double? snackTextSize,
    Color? snackTextColor,
    int? snackDuration,
    Color? snackBackgroundColor,
  }) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          message: snackText,
          textSize: snackTextSize,
          textColor: snackTextColor,
          backgroundColor: snackBackgroundColor,
        );
      },
    );
  }

  static void hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}

class CustomDialog extends StatelessWidget {
  final String message;
  final double? textSize;
  final Color? textColor;
  final Color? backgroundColor;

  const CustomDialog({
    super.key,
    required this.message,
    this.textSize,
    this.textColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: backgroundColor ?? Colors.white,
      child: SizedBox(
        height: 236,
        width: 340,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              height: 68,
              width: 68,
              child: Image.asset(
                "assets/images/home/error.png",
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: textSize ?? 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Column(
              children: [
                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "Ok",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
