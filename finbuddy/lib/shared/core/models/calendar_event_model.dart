import 'package.flutter/material.dart';

enum EventType { ganho, gasto, cartao }

class CalendarEventModel {
  final String descricao;
  final double valor;
  final EventType tipo;
  final DateTime data;

  CalendarEventModel({
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.data,
  });
}