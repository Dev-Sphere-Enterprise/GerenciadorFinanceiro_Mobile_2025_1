import 'package:flutter/material.dart';

void scrollToMesSelecionado(ScrollController scrollController, int mes) {
  if (scrollController.hasClients) {
    const larguraChip = 72.0;
    const paddingChips = 8.0;
    final posicao = (mes - 1) * (larguraChip + paddingChips);

    scrollController.animateTo(
      posicao,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
