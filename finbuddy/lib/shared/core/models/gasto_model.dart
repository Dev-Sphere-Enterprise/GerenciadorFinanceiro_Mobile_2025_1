import 'package:cloud_firestore/cloud_firestore.dart';

class GastoModel {
  final String? id;
  final String idUsuario;
  final String? idCartao;
  final String nome;
  final double valor;
  final int parcelas;
  final String idTipoPagamento;
  final String idCategoria;
  final DateTime dataCompra;
  final bool recorrencia;
  final bool deletado;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  GastoModel({
    this.id,
    required this.idUsuario,
    this.idCartao,
    required this.nome,
    required this.valor,
    required this.parcelas,
    required this.idTipoPagamento,
    required this.idCategoria,
    required this.dataCompra,
    this.recorrencia = false,
    this.deletado = false,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'ID_Usuario': idUsuario,
      'ID_Cartao': idCartao,
      'Nome': nome,
      'Valor': valor,
      'Parcelas': parcelas,
      'ID_Tipo_Pagamento': idTipoPagamento,
      'ID_Categoria': idCategoria,
      'Data_Compra': Timestamp.fromDate(dataCompra),
      'Recorrencia': recorrencia,
      'Deletado': deletado,
      'Data_Criacao': Timestamp.fromDate(dataCriacao),
      'Data_Atualizacao': Timestamp.fromDate(dataAtualizacao),
    };
  }

  factory GastoModel.fromMap(String id, Map<String, dynamic> map) {
    return GastoModel(
      id: id,
      idUsuario: map['ID_Usuario'] ?? '',
      idCartao: map['ID_Cartao'], // Pode ser nulo
      nome: map['Nome'] ?? '',
      valor: (map['Valor'] ?? 0.0).toDouble(),
      parcelas: map['Parcelas'] ?? 1,
      idTipoPagamento: map['ID_Tipo_Pagamento'] ?? '',
      idCategoria: map['ID_Categoria'] ?? '',
      dataCompra: (map['Data_Compra'] as Timestamp).toDate(),
      recorrencia: map['Recorrencia'] ?? false,
      deletado: map['Deletado'] ?? false,
      dataCriacao: (map['Data_Criacao'] as Timestamp).toDate(),
      dataAtualizacao: (map['Data_Atualizacao'] as Timestamp).toDate(),
    );
  }
  GastoModel copyWith({
    String? id,
    String? idUsuario,
    String? idCartao,
    String? nome,
    double? valor,
    int? parcelas,
    String? idTipoPagamento,
    String? idCategoria,
    DateTime? dataCompra,
    bool? recorrencia,
    bool? deletado,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return GastoModel(
      id: id ?? this.id,
      idUsuario: idUsuario ?? this.idUsuario,
      idCartao: idCartao ?? this.idCartao,
      nome: nome ?? this.nome,
      valor: valor ?? this.valor,
      parcelas: parcelas ?? this.parcelas,
      idTipoPagamento: idTipoPagamento ?? this.idTipoPagamento,
      idCategoria: idCategoria ?? this.idCategoria,
      dataCompra: dataCompra ?? this.dataCompra,
      recorrencia: recorrencia ?? this.recorrencia,
      deletado: deletado ?? this.deletado,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }
}