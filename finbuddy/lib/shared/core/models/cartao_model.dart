import 'package:cloud_firestore/cloud_firestore.dart';

class CartaoModel {
  final String? id;
  final String idUsuario;
  final String nome;
  final double valorFaturaAtual;
  final double limiteCredito;
  final DateTime dataFechamento;
  final DateTime dataVencimento;
  final bool deletado;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  CartaoModel({
    this.id,
    required this.idUsuario,
    required this.nome,
    required this.valorFaturaAtual,
    required this.limiteCredito,
    required this.dataFechamento,
    required this.dataVencimento,
    this.deletado = false,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  CartaoModel copyWith({
    String? id,
    String? idUsuario,
    String? nome,
    double? valorFaturaAtual,
    double? limiteCredito,
    DateTime? dataFechamento,
    DateTime? dataVencimento,
    bool? deletado,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return CartaoModel(
      id: id ?? this.id,
      idUsuario: idUsuario ?? this.idUsuario,
      nome: nome ?? this.nome,
      valorFaturaAtual: valorFaturaAtual ?? this.valorFaturaAtual,
      limiteCredito: limiteCredito ?? this.limiteCredito,
      dataFechamento: dataFechamento ?? this.dataFechamento,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      deletado: deletado ?? this.deletado,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID_Usuario_Cartoes': idUsuario,
      'Nome': nome,
      'Valor_Fatura_Atual': valorFaturaAtual,
      'Limite_Credito': limiteCredito,
      'Data_Fechamento': Timestamp.fromDate(dataFechamento),
      'Data_Vencimento': Timestamp.fromDate(dataVencimento),
      'Deletado': deletado,
      'Data_Criacao': Timestamp.fromDate(dataCriacao),
      'Data_Atualizacao': Timestamp.fromDate(dataAtualizacao),
    };
  }

  factory CartaoModel.fromMap(String id, Map<String, dynamic> map) {
    return CartaoModel(
      id: id,
      idUsuario: map['ID_Usuario_Cartoes'] ?? '',
      nome: map['Nome'] ?? '',
      valorFaturaAtual: (map['Valor_Fatura_Atual'] ?? 0.0).toDouble(),
      limiteCredito: (map['Limite_Credito'] ?? 0.0).toDouble(),
      dataFechamento: (map['Data_Fechamento'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dataVencimento: (map['Data_Vencimento'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deletado: map['Deletado'] ?? false,
      dataCriacao: (map['Data_Criacao'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dataAtualizacao: (map['Data_Atualizacao'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}