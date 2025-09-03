import 'package:cloud_firestore/cloud_firestore.dart';

class AporteMetaModel {
  final String? id;
  final String idMeta;
  final double valor;
  final DateTime dataAporte;
  final bool deletado;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  AporteMetaModel({
    this.id,
    required this.idMeta,
    required this.valor,
    required this.dataAporte,
    this.deletado = false,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'ID_Meta': idMeta,
      'Valor': valor,
      'Data_Aporte': Timestamp.fromDate(dataAporte),
      'Deletado': deletado,
      'Data_Criacao': Timestamp.fromDate(dataCriacao),
      'Data_Atualizacao': Timestamp.fromDate(dataAtualizacao),
    };
  }

  factory AporteMetaModel.fromMap(String id, Map<String, dynamic> map) {
    return AporteMetaModel(
      id: id,
      idMeta: map['ID_Meta'] ?? '',
      valor: (map['Valor'] ?? 0.0).toDouble(),
      dataAporte: (map['Data_Aporte'] as Timestamp).toDate(),
      deletado: map['Deletado'] ?? false,
      dataCriacao: (map['Data_Criacao'] as Timestamp).toDate(),
      dataAtualizacao: (map['Data_Atualizacao'] as Timestamp).toDate(),
    );
  }
}