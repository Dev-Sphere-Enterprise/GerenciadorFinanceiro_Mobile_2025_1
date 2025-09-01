import 'package:cloud_firestore/cloud_firestore.dart';

class TipoPagamentoModel {
  final String? id;
  final String nome;
  final bool usaCartao;
  final bool parcelavel;
  final bool deletado;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  TipoPagamentoModel({
    this.id,
    required this.nome,
    this.usaCartao = false,
    this.parcelavel = false,
    this.deletado = false,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'Nome': nome,
      'Usa_Cartao': usaCartao,
      'Parcelavel': parcelavel,
      'Deletado': deletado,
      'Data_Criacao': Timestamp.fromDate(dataCriacao),
      'Data_Atualizacao': Timestamp.fromDate(dataAtualizacao),
    };
  }

  factory TipoPagamentoModel.fromMap(String id, Map<String, dynamic> map) {
    return TipoPagamentoModel(
      id: id,
      nome: map['Nome'] as String? ?? '',
      usaCartao: map['Usa_Cartao'] as bool? ?? false,
      parcelavel: map['Parcelavel'] as bool? ?? false,
      deletado: map['Deletado'] as bool? ?? false,
      dataCriacao: (map['Data_Criacao'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dataAtualizacao: (map['Data_Atualizacao'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  TipoPagamentoModel copyWith({
    String? id,
    String? nome,
    bool? usaCartao,
    bool? parcelavel,
    bool? deletado,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return TipoPagamentoModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      usaCartao: usaCartao ?? this.usaCartao,
      parcelavel: parcelavel ?? this.parcelavel,
      deletado: deletado ?? this.deletado,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }
}