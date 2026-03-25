import 'package:flutter/material.dart';

class AppTheme {
  InputDecoration inputDec(String hinText, IconData icon) {
    return InputDecoration(
      border: InputBorder.none,
      hintText: hinText,
      hintStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(
        icon,
        color: Colors.grey,
      ),
    );
  }

  BoxDecoration inputBoxDec() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          blurRadius: 5,
          offset: const Offset(0, 3),
        )
      ],
    );
  }
}
