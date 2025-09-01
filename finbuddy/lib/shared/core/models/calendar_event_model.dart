import 'package:flutter/material.dart';

enum EventType { ganho, gasto, cartao }

class CalendarEventModel {
  final String descricao;
  final double valor;
  final EventType tipo;
  final DateTime data;
  final Color cor;

  CalendarEventModel({
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.data,
    required this.cor,
  });
  factory CalendarEventModel.withDefaultColor({
    required String descricao,
    required double valor,
    required EventType tipo,
    required DateTime data,
  }) {
    Color cor;
    switch (tipo) {
      case EventType.gasto:
        cor = Colors.redAccent;
        break;
      case EventType.ganho:
        cor = Colors.green;
        break;
      case EventType.cartao:
        cor = Colors.blueAccent;
        break;
    }

    return CalendarEventModel(
      descricao: descricao,
      valor: valor,
      tipo: tipo,
      data: data,
      cor: cor,
    );
  }
}