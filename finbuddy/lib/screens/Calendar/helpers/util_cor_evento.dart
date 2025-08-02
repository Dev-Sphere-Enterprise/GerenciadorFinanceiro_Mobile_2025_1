import 'package:flutter/material.dart';

Color corDoEvento(String tipo) {
  switch (tipo) {
    case 'cartao':
      return Colors.amber;
    case 'gasto':
      return Colors.red;
    case 'ganho':
      return Colors.green;
    default:
      return Colors.grey;
  }
}
