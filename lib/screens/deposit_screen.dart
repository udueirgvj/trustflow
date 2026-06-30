// deposit_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'deposit_gateway_screen.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DepositScreen(),
    );
  }

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _amountController = TextEditingController();
  final _minAmount = 5.0;

  String? _errorText;

  void _proceed() {
    final raw = _amountController.text.trim();
    final amount = double.tryParse(raw);

    if (amount == null || amount < _minAmount) {
      setState(() => _errorText = 'الحد الأدنى للإيداع هو \$$_minAmount');
      return;
    }

    setState(() => _errorText = null);

    // أغلق هذه الشاشة ثم افتح شاشة البوابات
    Navigator.pop(context);
    DepositGatewayScreen.show(context, amount: amount);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Title
              Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.savings_outlined,
                        color: AppColors.blue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('إيداع الرصيد',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text('يرجى تحديد المبلغ المراد إيداعه',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Amount field label
              const Text('المبلغ المراد إيداعه (\$)',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 10),

              // Amount input
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _errorText != null
                        ? AppColors.red.withOpacity(0.6)
                        : Colors.white10,
                  ),
                ),
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                  onChanged: (_) {
                    if (_errorText != null) setState(() => _errorText = null);
                  },
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: const TextStyle(
                        color: AppColors.textMuted, fontSize: 22),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Icon(Icons.attach_money,
                          color: AppColors.walletStart, size: 24),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
              ),

              // Error
              if (_errorText != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.red, size: 14),
                    const SizedBox(width: 5),
                    Text(_errorText!,
                        style: const TextStyle(
                            color: AppColors.red, fontSize: 12)),
                  ],
                ),
              ],

              const SizedBox(height: 14),

              // Quick amounts
              Row(
                children: ['10', '25', '50', '100', '500'].map((a) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _amountController.text = a;
                        _errorText = null;
                      }),
                      child: Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: AppColors.bgCardLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Center(
                          child: Text(
                            '+\$$a',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),

              // Minimum note
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: AppColors.blue, size: 15),
                    SizedBox(width: 8),
                    Text('الحد الأدنى للإيداع 5 دولار.',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Proceed button
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _proceed,
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 18),
                  label: const Text(
                    'المتابعة واختيار البوابة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
