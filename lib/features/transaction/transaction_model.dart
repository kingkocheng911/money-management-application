import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum TransactionCategory {
  food,
  transport,
  shopping,
  health,
  entertainment,
  bills,
  education,
  travel,
  home,
  gift,
  subscription,
  income,
  other,
}

extension CategoryX on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.food:
        return 'Makanan';
      case TransactionCategory.transport:
        return 'Transportasi';
      case TransactionCategory.shopping:
        return 'Belanja';
      case TransactionCategory.health:
        return 'Kesehatan';
      case TransactionCategory.entertainment:
        return 'Hiburan';
      case TransactionCategory.bills:
        return 'Tagihan';
      case TransactionCategory.education:
        return 'Edukasi';
      case TransactionCategory.travel:
        return 'Perjalanan';
      case TransactionCategory.home:
        return 'Rumah';
      case TransactionCategory.gift:
        return 'Hadiah';
      case TransactionCategory.subscription:
        return 'Langganan';
      case TransactionCategory.income:
        return 'Pemasukan';
      case TransactionCategory.other:
        return 'Lainnya';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionCategory.food:
        return Icons.restaurant_rounded;
      case TransactionCategory.transport:
        return Icons.directions_car_rounded;
      case TransactionCategory.shopping:
        return Icons.shopping_bag_rounded;
      case TransactionCategory.health:
        return Icons.favorite_rounded;
      case TransactionCategory.entertainment:
        return Icons.movie_rounded;
      case TransactionCategory.bills:
        return Icons.receipt_rounded;
      case TransactionCategory.education:
        return Icons.school_rounded;
      case TransactionCategory.travel:
        return Icons.flight_takeoff_rounded;
      case TransactionCategory.home:
        return Icons.home_rounded;
      case TransactionCategory.gift:
        return Icons.card_giftcard_rounded;
      case TransactionCategory.subscription:
        return Icons.subscriptions_rounded;
      case TransactionCategory.income:
        return Icons.account_balance_rounded;
      case TransactionCategory.other:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TransactionCategory.food:
        return AppTheme.catFood;
      case TransactionCategory.transport:
        return AppTheme.catTransport;
      case TransactionCategory.shopping:
        return AppTheme.catShopping;
      case TransactionCategory.health:
        return AppTheme.catHealth;
      case TransactionCategory.entertainment:
        return AppTheme.catEntertain;
      case TransactionCategory.bills:
        return AppTheme.catBills;
      case TransactionCategory.education:
        return AppTheme.catEducation;
      case TransactionCategory.travel:
        return AppTheme.catTravel;
      case TransactionCategory.home:
        return AppTheme.catHome;
      case TransactionCategory.gift:
        return AppTheme.catGift;
      case TransactionCategory.subscription:
        return AppTheme.catSubs;
      case TransactionCategory.income:
        return AppTheme.catIncome;
      case TransactionCategory.other:
        return AppTheme.catOther;
    }
  }

  String get key => name;
}

TransactionCategory categoryFromKey(String key) {
  return TransactionCategory.values.firstWhere(
    (c) => c.key == key,
    orElse: () => TransactionCategory.other,
  );
}

class Transaction {
  final String id;
  final String name;
  final int amount;
  final bool isExpense;
  final DateTime date;
  final TransactionCategory category;

  const Transaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.isExpense,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'isExpense': isExpense,
    'date': date.toIso8601String(),
    'category': category.key,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final isExpense =
        json['isExpense'] as bool? ?? (json['tipe'] == 'pengeluaran');
    return Transaction(
      id:
          json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? json['nama'] as String? ?? '',
      amount: json['amount'] as int? ?? json['jumlah'] as int? ?? 0,
      isExpense: isExpense,
      date: DateTime.parse(
        json['date'] as String? ??
            (json['tanggal'] is String ? json['tanggal'] as String : null) ??
            DateTime.now().toIso8601String(),
      ),
      category: categoryFromKey(
        json['category'] as String? ?? (isExpense ? 'other' : 'income'),
      ),
    );
  }

  Transaction copyWith({
    String? id,
    String? name,
    int? amount,
    bool? isExpense,
    DateTime? date,
    TransactionCategory? category,
  }) {
    return Transaction(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      isExpense: isExpense ?? this.isExpense,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }
}
