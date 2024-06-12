// import 'package:flutter/material.dart';
//
// class RoundedButton extends StatelessWidget {
//   final String btnText;
//   final Function onBtnPressed;
//
//   const RoundedButton(
//     {super.key, required this.btnText, required this.onBtnPressed});
//
//   @override
//   Widget build(BuildContext context) {
//     return Material (
//       elevation: 5,
//       color: Colors.black,
//       borderRadius: BorderRadius.circular(30),
//
//       child: MaterialButton(
//         onPressed: () {
//           onBtnPressed();
//         },
//         minWidth: 30,
//         height: 60,
//         child: Text (
//           btnText,
//           style: const TextStyle(color: Colors.white, fontSize: 20),
//
//         )
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String btnText;
  final VoidCallback onBtnPressed;

  const RoundedButton({
    super.key,
    required this.btnText,
    required this.onBtnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onBtnPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      ),
      child: Text(btnText),
    );
  }
}

