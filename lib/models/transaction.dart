import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final String userId;
  final String accountId;
  final double amount;
  final String category;
  final DateTime date;
  final String name;
  final String? merchantName;
  final bool pending;

  const Transaction({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.amount,
    required this.category,
    required this.date,
    required this.name,
    this.merchantName,
    this.pending = false,
  });

  @override
  List<Object?> get props => [id, userId, accountId, amount, category, date, name, merchantName, pending];
}
