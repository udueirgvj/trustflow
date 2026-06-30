import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class SupportMessage {
  final String id;
  final String senderType; // user / system / admin
  final String content;
  final DateTime createdAt;

  SupportMessage({
    required this.id,
    required this.senderType,
    required this.content,
    required this.createdAt,
  });

  bool get isUser => senderType == 'user';

  factory SupportMessage.fromMap(Map<String, dynamic> map) {
    return SupportMessage(
      id: map['id'] as String,
      senderType: map['sender_type'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class SupportService {
  static const _autoReply =
      'تم استلام رسالتك، سيتم الرد عليك من فريق الإدارة في أقرب وقت ممكن.';

  /// يجلب أحدث تذكرة مفتوحة للمستخدم، أو ينشئ تذكرة جديدة لو ما فيه
  static Future<String> getOrCreateActiveTicket() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    final existing = await SupabaseService.client
        .from('support_tickets')
        .select('id')
        .eq('user_id', user.id)
        .neq('status', 'closed')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    final created = await SupabaseService.client
        .from('support_tickets')
        .insert({'user_id': user.id})
        .select('id')
        .single();

    return created['id'] as String;
  }

  /// يرسل رسالة المستخدم، ثم يضيف رد تلقائي فوري من النظام
  static Future<void> sendUserMessage(String ticketId, String content) async {
    await SupabaseService.client.from('support_messages').insert({
      'ticket_id': ticketId,
      'sender_type': 'user',
      'content': content,
    });

    // ملاحظة: إضافة الرد التلقائي من جهة العميل تتطلب أن تسمح
    // سياسة RLS بإدخال sender_type = 'system'. إن كانت السياسة
    // محصورة بـ 'user' فقط (كما بملف support_setup.sql)، يفضل
    // أن يتم إدراج الرد التلقائي عبر Database Trigger بالخادم
    // (انظر التعليق بالأسفل) بدلاً من العميل، لمنع التلاعب.
    try {
      await SupabaseService.client.from('support_messages').insert({
        'ticket_id': ticketId,
        'sender_type': 'system',
        'content': _autoReply,
      });
    } catch (_) {
      // لو سياسة RLS منعت الإدراج من العميل، يفضل تفعيل الـ Trigger
      // الموضح بالأسفل ليقوم الخادم بإدراج الرد التلقائي تلقائياً.
    }
  }

  /// يجلب كل رسائل تذكرة معينة، الأقدم أولاً
  static Future<List<SupportMessage>> fetchMessages(String ticketId) async {
    final response = await SupabaseService.client
        .from('support_messages')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((e) => SupportMessage.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// الاستماع الفوري (Realtime) لأي رسالة جديدة بالتذكرة — مفيد لظهور رد الأدمن مباشرة
  static Stream<List<SupportMessage>> watchMessages(String ticketId) {
    return SupabaseService.client
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .eq('ticket_id', ticketId)
        .order('created_at')
        .map((rows) => rows.map((e) => SupportMessage.fromMap(e)).toList());
  }
}
