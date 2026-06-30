import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class UsagePolicyScreen extends StatelessWidget {
  const UsagePolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سياسة الاستخدام')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _PolicySection(
            title: '1. مقدمة',
            body:
                'باستخدامك لتطبيق TrustFlow فإنك توافق على شروط الخدمة وسياسة '
                'الاستخدام الموضحة بالأسفل. يرجى قراءتها بعناية قبل استخدام '
                'أي من خدمات التداول الآلي المتوفرة بالتطبيق.',
          ),
          _PolicySection(
            title: '2. طبيعة الخدمة',
            body:
                'يقدم التطبيق أدوات لإدارة ومتابعة روبوتات تداول آلية. '
                'التداول بالأسواق المالية ينطوي على مخاطر، وقد تنتج عنه خسائر '
                'بالإضافة إلى الأرباح. المستخدم مسؤول وحده عن قرارات التداول '
                'وتفعيل الروبوتات بحسابه.',
          ),
          _PolicySection(
            title: '3. أمان الحساب',
            body:
                'يلتزم المستخدم بحماية بيانات حسابه (البريد الإلكتروني وكلمة '
                'المرور) وعدم مشاركتها مع أي طرف آخر. ننصح بشدة بتفعيل التحقق '
                'بخطوتين لرفع مستوى الحماية. التطبيق غير مسؤول عن أي ضرر ناتج '
                'عن إهمال المستخدم بحماية بيانات الدخول.',
          ),
          _PolicySection(
            title: '4. الخصوصية والبيانات',
            body:
                'نجمع المعلومات الضرورية فقط لتشغيل الخدمة (البريد الإلكتروني، '
                'الاسم، وسجل نشاطات الدخول لأغراض أمنية). لا نشارك بياناتك مع '
                'أي طرف ثالث دون موافقتك إلا في الحدود التي يتطلبها القانون.',
          ),
          _PolicySection(
            title: '5. المسؤولية المالية',
            body:
                'جميع عمليات الإيداع والسحب والتحويل داخل المحفظة تتم بمسؤولية '
                'المستخدم. يرجى التحقق من صحة البيانات قبل تأكيد أي عملية '
                'مالية، حيث لا يمكن التراجع عن العمليات المكتملة.',
          ),
          _PolicySection(
            title: '6. التعديلات على السياسة',
            body:
                'قد نقوم بتحديث سياسة الاستخدام من وقت لآخر. سيتم إشعارك بأي '
                'تغييرات جوهرية عبر التطبيق. استمرارك باستخدام التطبيق بعد '
                'التحديث يُعد موافقة على الشروط الجديدة.',
          ),
          _PolicySection(
            title: '7. التواصل معنا',
            body:
                'لأي استفسار يخص هذه السياسة، يمكنك التواصل مع فريق الدعم '
                'الفني من داخل التطبيق عبر قسم "الدعم الفني" بالإعدادات.',
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;
  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 8),
          Text(body,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                  height: 1.7)),
        ],
      ),
    );
  }
}
