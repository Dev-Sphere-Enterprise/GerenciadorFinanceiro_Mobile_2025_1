import 'package:flutter/foundation.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../shared/core/models/calendar_event_model.dart';
import '../../../shared/core/repositories/calendar_repository.dart';

class CalendarViewModel extends ChangeNotifier {
  final CalendarRepository _repository = CalendarRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  DateTime _focusedDay = DateTime.now();
  DateTime get focusedDay => _focusedDay;

  DateTime? _selectedDay;
  DateTime? get selectedDay => _selectedDay;

  Map<DateTime, List<CalendarEventModel>> _eventos = {};
  Map<DateTime, List<CalendarEventModel>> get eventos => _eventos;

  CalendarViewModel() {
    _selectedDay = _focusedDay;
    carregarEventos();
  }

  Future<void> carregarEventos() async {
    _isLoading = true;
    notifyListeners();

    final listaDeEventos = await _repository.carregarEventos();
    _eventos = _agruparEventosPorDia(listaDeEventos);
    
    _isLoading = false;
    notifyListeners();
  }

  Map<DateTime, List<CalendarEventModel>> _agruparEventosPorDia(List<CalendarEventModel> eventos) {
    Map<DateTime, List<CalendarEventModel>> mapaDeEventos = {};
    for (var evento in eventos) {
      final dia = DateTime(evento.data.year, evento.data.month, evento.data.day);
      mapaDeEventos.putIfAbsent(dia, () => []).add(evento);
    }
    return mapaDeEventos;
  }

  List<CalendarEventModel> getEventosDoDia(DateTime dia) {
    final diaNormalizado = DateTime(dia.year, dia.month, dia.day);
    return _eventos[diaNormalizado] ?? [];
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      notifyListeners();
    }
  }
}
