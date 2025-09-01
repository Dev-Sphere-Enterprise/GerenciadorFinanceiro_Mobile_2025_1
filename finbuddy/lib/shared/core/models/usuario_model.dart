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
      'dob': Timestamp.fromDate(dataNascimento),
      'Email': email,
      'Senha': senha,
      'Deletado': deletado,
      'createdAt': Timestamp.fromDate(dataCriacao),
      'Data_Atualizacao': Timestamp.fromDate(dataAtualizacao),
    };
  }

  factory UsuarioModel.fromMap(String id, Map<String, dynamic> map) {
    return UsuarioModel(
      id: id,
      nome: map['Nome'] ?? '',
      dataNascimento: (map['dob'] as Timestamp).toDate(),
      email: map['Email'] ?? '',
      senha: map['Senha'] ?? '',
      deletado: map['Deletado'] ?? false,
      dataCriacao: (map['createdAt'] as Timestamp).toDate(),
      dataAtualizacao: (map['Data_Atualizacao'] as Timestamp).toDate(),
    );
  }
  UsuarioModel copyWith({
    String? id,
    String? nome,
    DateTime? dataNascimento,
    String? email,
    String? senha,
    bool? deletado,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      deletado: deletado ?? this.deletado,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }
}
