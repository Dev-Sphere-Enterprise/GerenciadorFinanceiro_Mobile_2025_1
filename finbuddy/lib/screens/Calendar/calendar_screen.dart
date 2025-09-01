import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../shared/constants/style_constants.dart';
import '../../shared/core/models/calendar_event_model.dart';
import 'viewmodel/calendar_viewmodel.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarViewModel(),
      child: Scaffold(
        backgroundColor: corFundoScaffold,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: finBuddyLime,
          title: Text('Fin_Buddy', style: estiloFonteMonospace.copyWith(color: finBuddyBlue, fontSize: 22)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: finBuddyBlue),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<CalendarViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SafeArea(
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
                      _buildTableCalendar(viewModel),
                      const SizedBox(height: 10),
                      const Divider(thickness: 1),
                      Expanded(
                        child: _buildEventList(viewModel),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTableCalendar(CalendarViewModel viewModel) {
    return TableCalendar<CalendarEventModel>(
      locale: 'pt_BR',
      firstDay: DateTime.utc(2020),
      lastDay: DateTime.utc(2100),
      focusedDay: viewModel.focusedDay,
      selectedDayPredicate: (day) => isSameDay(viewModel.selectedDay, day),
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
          color: finBuddyBlueSelectedday,
          shape: BoxShape.circle,
        ),
        todayTextStyle: estiloFonteMonospace.copyWith(color: finBuddyDark),
        selectedTextStyle: estiloFonteMonospace.copyWith(color: Colors.white),
      ),
      onDaySelected: viewModel.onDaySelected,
      eventLoader: viewModel.getEventosDoDia,
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, eventos) {
          if (eventos.isEmpty) return const SizedBox();
          return Positioned(
            bottom: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: eventos.take(4).map((evento) {
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 1.0),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: evento.cor),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventList(CalendarViewModel viewModel) {
    final eventosDoDia = viewModel.getEventosDoDia(viewModel.selectedDay!);
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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Icon(Icons.circle, color: evento.cor, size: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  evento.descricao,
                  style: estiloFonteMonospace.copyWith(fontWeight: FontWeight.normal),
                ),
              ),
              if (evento.valor != 0.0)
                Text(
                  formatadorMoeda.format(evento.valor),
                  style: estiloFonteMonospace.copyWith(color: evento.cor),
                ),
            ],
          ),
        );
      },
    );
  }
}