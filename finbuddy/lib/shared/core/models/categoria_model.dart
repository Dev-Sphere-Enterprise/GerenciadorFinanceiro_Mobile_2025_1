import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriaModel {
  final String? id;
  final String nome;
  final bool deletado;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  CategoriaModel({
    this.id,
    required this.nome,
    this.deletado = false,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'Nome': nome,
      'Deletado': deletado,
      'Data_Criacao': Timestamp.fromDate(dataCriacao),
      'Data_Atualizacao': Timestamp.fromDate(dataAtualizacao),
    };
  }

  factory CategoriaModel.fromMap(String id, Map<String, dynamic> map) {
    return CategoriaModel(
      id: id,
      nome: map['Nome'] ?? '',
      deletado: map['Deletado'] ?? false,
      dataCriacao: (map['Data_Criacao'] as Timestamp).toDate(),
      dataAtualizacao: (map['Data_Atualizacao'] as Timestamp).toDate(),
    );
  }
}