import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

import 'helpers/carregar_eventos_calendario.dart';
import 'helpers/util_cor_evento.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _eventos = {};

  @override
  void initState() {
    super.initState();
    _loadEventos();
  }

  Future<void> _loadEventos() async {
    final eventos = await carregarEventosCalendario(
      firestore: _firestore,
      auth: _auth,
    );
    setState(() => _eventos = eventos);
  }

  List<Map<String, dynamic>> _getEventosDoDia(DateTime dia) {
    return _eventos[DateTime(dia.year, dia.month, dia.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final eventosDoDia = _getEventosDoDia(_selectedDay ?? _focusedDay);

    return Scaffold(
      appBar: AppBar(title: const Text("Calendário Financeiro")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(shape: BoxShape.circle),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventosDoDia,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, eventos) {
                if (eventos.isEmpty) return const SizedBox();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: eventos.take(3).map((evento) {
                    final e = evento as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0),
                      child: Icon(Icons.circle, size: 6, color: corDoEvento(e['tipo'])),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: eventosDoDia.isEmpty
                ? const Center(child: Text("Nenhum evento para este dia."))
                : ListView.builder(
              itemCount: eventosDoDia.length,
              itemBuilder: (context, index) {
                final evento = eventosDoDia[index];
                return ListTile(
                  leading: Icon(Icons.circle, color: corDoEvento(evento['tipo']), size: 12),
                  title: Text(evento['descricao']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
