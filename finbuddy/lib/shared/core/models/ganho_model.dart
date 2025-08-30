import 'package:cloud_firestore/cloud_firestore.dart';

class GanhoModel {
  final String? id;
  final String idUsuario;
  final String nome;
  final double valor;
  final DateTime dataRecebimento;
  final bool recorrencia;
  final bool deletado;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  GanhoModel({
    this.id,
    required this.idUsuario,
    required this.nome,
    required this.valor,
    required this.dataRecebimento,
    this.recorrencia = false,
    this.deletado = false,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'ID_Usuario_Ganhos': idUsuario,
      'Nome': nome,
      'Valor': valor,
      'Data_Recebimento': Timestamp.fromDate(dataRecebimento),
      'Recorrencia': recorrencia,
      'Deletado': deletado,
      'Data_Criacao': Timestamp.fromDate(dataCriacao),
      'Data_Atualizacao': Timestamp.fromDate(dataAtualizacao),
    };
  }

  factory GanhoModel.fromMap(String id, Map<String, dynamic> map) {
    return GanhoModel(
      id: id,
      idUsuario: map['ID_Usuario_Ganhos'] ?? '',
      nome: map['Nome'] ?? '',
      valor: (map['Valor'] ?? 0.0).toDouble(),
      dataRecebimento: (map['Data_Recebimento'] as Timestamp).toDate(),
      recorrencia: map['Recorrencia'] ?? false,
      deletado: map['Deletado'] ?? false,
      dataCriacao: (map['Data_Criacao'] as Timestamp).toDate(),
      dataAtualizacao: (map['Data_Atualizacao'] as Timestamp).toDate(),
    );
  }
}