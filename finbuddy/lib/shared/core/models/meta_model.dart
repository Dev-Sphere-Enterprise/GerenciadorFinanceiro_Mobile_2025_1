import 'package:cloud_firestore/cloud_firestore.dart';

class MetaModel {
  final String? id;
  final String idUsuario;
  final String nome;
  final double valorObjetivo;
  final double valorAtual;
  final DateTime dataLimiteMeta;
  final bool deletado;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  MetaModel({
    this.id,
    required this.idUsuario,
    required this.nome,
    required this.valorObjetivo,
    required this.valorAtual,
    required this.dataLimiteMeta,
    this.deletado = false,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'ID_Usuario': idUsuario,
      'Nome': nome,
      'Valor_Objetivo': valorObjetivo,
      'Valor_Atual': valorAtual,
      'Data_limite_meta': Timestamp.fromDate(dataLimiteMeta),
      'Deletado': deletado,
      'Data_Criacao': Timestamp.fromDate(dataCriacao),
      'Data_Atualizacao': Timestamp.fromDate(dataAtualizacao),
    };
  }

  factory MetaModel.fromMap(String id, Map<String, dynamic> map) {
    return MetaModel(
      id: id,
      idUsuario: map['ID_Usuario'] ?? '',
      nome: map['Nome'] ?? '',
      valorObjetivo: (map['Valor_Objetivo'] ?? 0.0).toDouble(),
      valorAtual: (map['Valor_Atual'] ?? 0.0).toDouble(),
      dataLimiteMeta: (map['Data_limite_meta'] as Timestamp).toDate(),
      deletado: map['Deletado'] ?? false,
      dataCriacao: (map['Data_Criacao'] as Timestamp).toDate(),
      dataAtualizacao: (map['Data_Atualizacao'] as Timestamp).toDate(),
    );
  }
}