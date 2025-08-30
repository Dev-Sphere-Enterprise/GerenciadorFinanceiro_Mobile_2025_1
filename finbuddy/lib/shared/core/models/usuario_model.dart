import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel {
  final String? id;
  final String nome;
  final DateTime dataNascimento;
  final String email;
  final String senha; 
  final bool deletado;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  UsuarioModel({
    this.id,
    required this.nome,
    required this.dataNascimento,
    required this.email,
    required this.senha,
    this.deletado = false,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'Nome': nome,
      'Data_Nascimento': Timestamp.fromDate(dataNascimento),
      'Email': email,
      'Senha': senha,
      'Deletado': deletado,
      'Data_Criacao': Timestamp.fromDate(dataCriacao),
      'Data_Atualizacao': Timestamp.fromDate(dataAtualizacao),
    };
  }

  factory UsuarioModel.fromMap(String id, Map<String, dynamic> map) {
    return UsuarioModel(
      id: id,
      nome: map['Nome'] ?? '',
      dataNascimento: (map['Data_Nascimento'] as Timestamp).toDate(),
      email: map['Email'] ?? '',
      senha: map['Senha'] ?? '',
      deletado: map['Deletado'] ?? false,
      dataCriacao: (map['Data_Criacao'] as Timestamp).toDate(),
      dataAtualizacao: (map['Data_Atualizacao'] as Timestamp).toDate(),
    );
  }
}