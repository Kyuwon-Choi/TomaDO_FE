class ClubModel {
  final int clubId;
  final String title;
  final int goal;
  final int currentAmount;
  final String memo;
  final String startDate;
  final String endDate;
  final bool completed;
  final List<MemberModel> memberList;

  ClubModel({
    required this.clubId,
    required this.title,
    required this.goal,
    required this.currentAmount,
    required this.memo,
    required this.startDate,
    required this.endDate,
    required this.completed,
    required this.memberList,
  });

  factory ClubModel.fromJson(Map<String, dynamic> json) {
    return ClubModel(
      clubId: json['club_id'] as int,
      title: json['title'] as String,
      goal: json['goal'] as int,
      currentAmount: json['current_amount'] as int,
      memo: json['memo'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      completed: json['completed'] as bool,
      memberList: (json['memberList'] as List)
          .map((e) => MemberModel.fromJson(e))
          .toList(),
    );
  }
}

class MemberModel {
  final int userId;
  final String nickname;
  final String url;
  final int tomato;

  MemberModel({
    required this.userId,
    required this.nickname,
    required this.url,
    required this.tomato,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      userId: json['user_id'] as int,
      nickname: json['nickname'],
      url: json['url'],
      tomato: json['tomato'] as int,
    );
  }
}
