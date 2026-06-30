import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';

class _CryptoAddresses {
  static const eth  = '0x092e12b9455b984c1148ce00849b876050d141db';
  static const trx  = 'TWSWL9hyJ5UsVLkeEx2rx2WJyeVDdLbb9o';
  static const sol  = 'F42e5eUEAJKB6MD9PHmHwuY98RenP1PjB2fPDM4oGwyD';
  static const ton  = 'UQDi0Bkp6EQVlgpvk2ih5kuKj6G-aE4yLi0P8XEkyQ5qj5L9';
  static const xkr  = 'XKO092E12B9455B984c1148Ce00849b876050D141dB';
  static const pol  = '0x9569e617ad4fbe6af80210912d11db223149b0302eb827d33c5a929d2f38664a';
}

class PaymentCryptoScreen extends StatefulWidget {
  final String robotName;
  final double robotPrice;

  const PaymentCryptoScreen({
    super.key,
    required this.robotName,
    required this.robotPrice,
  });

  @override
  State<PaymentCryptoScreen> createState() => _PaymentCryptoScreenState();
}

class _PaymentCryptoScreenState extends State<PaymentCryptoScreen> {
  int _selected = 0;

  final List<Map<String, String>> _coins = [
    {'name': 'USDT (Tron TRC20)', 'network': 'TRC20', 'address': _CryptoAddresses.trx},
    {'name': 'USDT (TON)',         'network': 'TON',   'address': _CryptoAddresses.ton},
    {'name': 'USDT (Polygon)',     'network': 'POL',   'address': _CryptoAddresses.pol},
    {'name': 'ETH',                'network': 'ERC20', 'address': _CryptoAddresses.eth},
    {'name': 'SOL',                'network': 'Solana','address': _CryptoAddresses.sol},
    {'name': 'XKR',                'network': 'XKR',   'address': _CryptoAddresses.xkr},
  ];

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ العنوان'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    final coin = _coins[_selected];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_forward_ios, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
          centerTitle: true,
          title: const Text('الدفع الرقمي', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          actions: [const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.receipt_outlined, color: AppColors.textSecondary))],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // فاتورة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('فاتورة الدفع لـ ${widget.robotName}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    const Text('اشتراك روبوت مخصص', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ])),
                  Container(width: 42, height: 42,
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.receipt_outlined, color: Colors.blue, size: 22)),
                ]),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('سعر الروبوت', style: TextStyle(color: AppColors.textSecondary)),
                  Text('\$${widget.robotPrice.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                ]),
              ),
              const SizedBox(height: 20),
              const Text('اختر عملة الدفع', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              ..._coins.asMap().entries.map((e) => GestureDetector(
                onTap: () => setState(() => _selected = e.key),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _selected == e.key ? Colors.green.withOpacity(0.1) : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _selected == e.key ? Colors.green : Colors.transparent),
                  ),
                  child: Row(children: [
                    Radio<int>(value: e.key, groupValue: _selected, onChanged: (v) => setState(() => _selected = v!), activeColor: Colors.green),
                    const Spacer(),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(e.value['name']!, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      Text('الشبكة: ${e.value['network']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ]),
                    const SizedBox(width: 10),
                    const Icon(Icons.currency_bitcoin, color: Colors.green, size: 28),
                  ]),
                ),
              )),
              const SizedBox(height: 16),
              // عنوان المحفظة
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('عنوان المحفظة', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(child: Text(coin['address']!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11), overflow: TextOverflow.ellipsis)),
                    IconButton(icon: const Icon(Icons.copy, color: Colors.green, size: 20), onPressed: () => _copy(coin['address']!)),
                  ]),
                ]),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final userId = SupabaseService.client.auth.currentUser?.id;
                    if (userId != null) {
                      try {
                        await SupabaseService.client.from('purchases').insert({
                          'user_id': userId,
                          'robot_name': widget.robotName,
                          'amount': widget.robotPrice,
                          'method': 'crypto_${coin['network']}',
                          'status': 'pending',
                        });
                      } catch (_) {}
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('أرسل المبلغ إلى العنوان أعلاه ثم تواصل مع الدعم'), backgroundColor: Colors.green),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text('إنشاء معرف الدفع', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
