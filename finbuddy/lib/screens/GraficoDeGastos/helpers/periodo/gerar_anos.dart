List<int> gerarAnos() {
  final anoAtual = DateTime.now().year;
  return List.generate(anoAtual - 2000 + 1, (index) => 2000 + index);
}