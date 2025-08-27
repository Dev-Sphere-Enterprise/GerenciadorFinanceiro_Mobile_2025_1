import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'helpers/carregar_eventos_calendario.dart';
import 'helpers/util_cor_evento.dart';

const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);
const Color corFundoScaffold = Color(0xFFF0F4F8);
const Color corCardPrincipal = Color(0xFFFAF3DD);

const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);

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
  late Future<void> _loadEventosFuture;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEventosFuture = _loadEventos();
  }

  Future<void> _loadEventos() async {
    final eventos = await carregarEventosCalendario(
      firestore: _firestore,
      auth: _auth,
    );
    if (mounted) {
      setState(() => _eventos = eventos);
    }
  }

  List<Map<String, dynamic>> _getEventosDoDia(DateTime dia) {
    final date = DateTime(dia.year, dia.month, dia.day); // sem UTC
    return _eventos[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundoScaffold,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: finBuddyLime,
        title: Text(
          'Fin_Buddy',
          style: estiloFonteMonospace.copyWith(color: finBuddyBlue, fontSize: 22),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: finBuddyBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: corCardPrincipal,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                FutureBuilder(
                  future: _loadEventosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _buildTableCalendar();
                  },
                ),
                const SizedBox(height: 10),
                const Divider(thickness: 1),
                Expanded(
                  child: _buildEventList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      locale: 'pt_BR',
      firstDay: DateTime.utc(2020),
      lastDay: DateTime.utc(2100),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: estiloFonteMonospace.copyWith(fontSize: 18),
        leftChevronIcon: const Icon(Icons.chevron_left, color: finBuddyBlue),
        rightChevronIcon: const Icon(Icons.chevron_right, color: finBuddyBlue),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal),
        weekendTextStyle: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal, color: finBuddyBlue),
        outsideTextStyle: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal, color: Colors.grey.shade400),
        todayDecoration: BoxDecoration(
          color: finBuddyLime.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: finBuddyBlue,
          shape: BoxShape.circle,
        ),
        todayTextStyle: estiloFonteMonospace.copyWith(color: finBuddyDark),
        selectedTextStyle: estiloFonteMonospace.copyWith(color: Colors.white),
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
          return Positioned(
            bottom: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: eventos.take(4).map((evento) {
                final e = evento as Map<String, dynamic>;
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 1.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: corDoEvento(e['tipo']),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventList() {
    final eventosDoDia = _getEventosDoDia(_selectedDay ?? _focusedDay);
    final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    if (eventosDoDia.isEmpty) {
      return const Center(
        child: Text("Nenhum evento para este dia.", style: estiloFonteMonospace),
      );
    }

    return ListView.builder(
      itemCount: eventosDoDia.length,
      itemBuilder: (context, index) {
        final evento = eventosDoDia[index];
        final valor = (evento['valor'] ?? 0.0).toDouble();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Icon(Icons.circle, color: corDoEvento(evento['tipo']), size: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  evento['descricao'],
                  style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal),
                ),
              ),
              if (valor != 0.0)
                Text(
                  formatadorMoeda.format(valor),
                  style: estiloFonteMonospace.copyWith(
                    color: evento['tipo'] == 'ganho' ? Colors.green.shade700 : Colors.red.shade700
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}