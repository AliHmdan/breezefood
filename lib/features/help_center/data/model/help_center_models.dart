class HelpThreadResponse {
  final bool ok;
  final TicketModel ticket;

  HelpThreadResponse({required this.ok, required this.ticket});

  factory HelpThreadResponse.fromJson(Map<String, dynamic> json) {
    return HelpThreadResponse(
      ok: (json['ok'] ?? false) as bool,
      ticket: TicketModel.fromJson((json['ticket'] ?? {}) as Map<String, dynamic>),
    );
  }
}

class TicketModel {
  final int id;
  final int userId;
  final String status;
  final String? subject;
  final String lastMessageFrom;
  final DateTime? lastMessageAt;
  final List<TicketMessageModel> messages;

  TicketModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.subject,
    required this.lastMessageFrom,
    required this.lastMessageAt,
    required this.messages,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final msgs = (json['messages'] as List? ?? [])
        .map((e) => TicketMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return TicketModel(
      id: (json['id'] ?? 0) as int,
      userId: (json['user_id'] ?? 0) as int,
      status: (json['status'] ?? '') as String,
      subject: json['subject'] as String?,
      lastMessageFrom: (json['last_message_from'] ?? '') as String,
      lastMessageAt: _tryParseDate(json['last_message_at']),
      messages: msgs,
    );
  }

  static DateTime? _tryParseDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }
}

class TicketMessageModel {
  final int id;
  final int helpTicketId;
  final int senderId;
  final String senderType; // "customer" | "admin"
  final String message;
  final bool isReadByCustomer;
  final bool isReadByAdmin;
  final DateTime? createdAt;

  TicketMessageModel({
    required this.id,
    required this.helpTicketId,
    required this.senderId,
    required this.senderType,
    required this.message,
    required this.isReadByCustomer,
    required this.isReadByAdmin,
    required this.createdAt,
  });

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) {
    return TicketMessageModel(
      id: (json['id'] ?? 0) as int,
      helpTicketId: (json['help_ticket_id'] ?? 0) as int,
      senderId: (json['sender_id'] ?? 0) as int,
      senderType: (json['sender_type'] ?? '') as String,
      message: (json['message'] ?? '') as String,
      isReadByCustomer: (json['is_read_by_customer'] ?? 0) == 1,
      isReadByAdmin: (json['is_read_by_admin'] ?? 0) == 1,
      createdAt: TicketModel._tryParseDate(json['created_at']),
    );
  }
}
