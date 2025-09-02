import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel {
  final String? id;
  final String nome;
  final DateTime? dob;
  final String email;
  final String senha;
  final bool deletado;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  UsuarioModel({
    this.id,
    required this.nome,
    this.dob,
    required this.email,
    required this.senha,
    this.deletado = false,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null, // Correctly saves the Timestamp
      'email': email,
      'senha': senha, // Standardized to camelCase
      'deletado': deletado, // Standardized to camelCase
      'createdAt': Timestamp.fromDate(dataCriacao), // Standardized to camelCase
      'dataAtualizacao': Timestamp.fromDate(dataAtualizacao), // Standardized to camelCase
    };
  }

  factory UsuarioModel.fromMap(String id, Map<String, dynamic> map) {
    final Timestamp? dobTimestamp = map['dob'] as Timestamp?;
    return UsuarioModel(
      id: id,
      nome: map['nome'] ?? '',
      dob: dobTimestamp?.toDate(),
      email: map['email'] ?? '',
      senha: map['senha'] ?? '', // Standardized to camelCase
      deletado: map['deletado'] ?? false, // Standardized to camelCase
      dataCriacao: (map['createdAt'] as Timestamp).toDate(),
      dataAtualizacao: (map['dataAtualizacao'] as Timestamp).toDate(), // Standardized to camelCase
    );
  }

  UsuarioModel copyWith({
    String? id,
    String? nome,
    DateTime? dob,
    String? email,
    String? senha,
    bool? deletado,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      dob: dob ?? this.dob,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      deletado: deletado ?? this.deletado,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }
}