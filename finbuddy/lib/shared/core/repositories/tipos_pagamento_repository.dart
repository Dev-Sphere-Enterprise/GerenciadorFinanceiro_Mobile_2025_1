import 'package:cloud_firestore/cloud_firestore.dart';

class TipoPagamentoModel {
  final String? id;
  final String nome;
  final bool usaCartao;
  final bool parcelavel;
  final bool isGeneral; 
  final bool deletado;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  TipoPagamentoModel({
    this.id,
    required this.nome,
    this.usaCartao = false,
    this.parcelavel = false,
    this.isGeneral = false, 
    this.deletado = false,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'Nome': nome,
      'UsaCartao': usaCartao,     
      'Parcelavel': parcelavel, 
      'Deletado': deletado,
      'Data_Criacao': Timestamp.fromDate(dataCriacao),
      'Data_Atualizacao': Timestamp.fromDate(dataAtualizacao),
    };
  }

  factory TipoPagamentoModel.fromMap(String id, Map<String, dynamic> map) {
    return TipoPagamentoModel(
      id: id,
      nome: map['Nome'] ?? map['nome'] ?? '',
      usaCartao: map['UsaCartao'] ?? false,
      parcelavel: map['Parcelavel'] ?? false,
      deletado: map['Deletado'] ?? false,
      dataCriacao: (map['Data_Criacao'] as Timestamp? ?? Timestamp.now()).toDate(),
      dataAtualizacao: (map['Data_Atualizacao'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }

  TipoPagamentoModel copyWith({
    bool? isGeneral,
  }) {
    return TipoPagamentoModel(
      id: id,
      nome: nome,
      usaCartao: usaCartao,
      parcelavel: parcelavel,
      isGeneral: isGeneral ?? this.isGeneral, 
      deletado: deletado,
      dataCriacao: dataCriacao,
      dataAtualizacao: dataAtualizacao,
    );
  }
}