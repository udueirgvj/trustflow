class WalletModel {
  final double totalBalance;
  final double robotProfit;
  final double robotCapital;
  final bool isInsured;

  WalletModel({
    required this.totalBalance,
    required this.robotProfit,
    required this.robotCapital,
    required this.isInsured,
  });

  factory WalletModel.zero() => WalletModel(
        totalBalance: 0,
        robotProfit: 0,
        robotCapital: 0,
        isInsured: true,
      );

  WalletModel copyWith({
    double? totalBalance,
    double? robotProfit,
    double? robotCapital,
    bool? isInsured,
  }) {
    return WalletModel(
      totalBalance: totalBalance ?? this.totalBalance,
      robotProfit: robotProfit ?? this.robotProfit,
      robotCapital: robotCapital ?? this.robotCapital,
      isInsured: isInsured ?? this.isInsured,
    );
  }
}
