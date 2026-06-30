import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;
  final VoidCallback onTransfer;
  final VoidCallback onReceive;

  const QuickActions({
    super.key,
    required this.onDeposit,
    required this.onWithdraw,
    required this.onTransfer,
    required this.onReceive,
  });

  @override
  Widget build(BuildContext context) {
    // الترتيب من الصورة: إيداع ← سحب ← تحويل ← استلام
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _ActionButton(
          icon: Icons.savings_outlined,
          label: 'إيداع',
          color: AppColors.blue,
          bgColor: const Color(0xFF0D2A4A),
          onTap: onDeposit,
        ),
        _ActionButton(
          icon: Icons.account_balance_wallet_outlined,
          label: 'سحب',
          color: AppColors.orange,
          bgColor: const Color(0xFF3D2B00),
          onTap: onWithdraw,
        ),
        _ActionButton(
          icon: Icons.swap_horiz,
          label: 'تحويل',
          color: AppColors.red,
          bgColor: const Color(0xFF4A0E1A),
          onTap: onTransfer,
        ),
        _ActionButton(
          icon: Icons.qr_code_scanner,
          label: 'استلام',
          color: AppColors.green,
          bgColor: const Color(0xFF1B4332),
          onTap: onReceive,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
