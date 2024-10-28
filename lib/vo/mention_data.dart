import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class MentionDataService {
  static final Map<String, Map<String, dynamic>> _userData = {
    '@john.doe:acter.global.org': {
      'displayName': 'John Doe',
    },
    '@jane.smith:acter.global.org': {
      'displayName': 'Jane Smith',
    },
    '@bob.johnson:acter.global.org': {
      'displayName': 'Bob Johnson',
    },
  };

  static final Map<String, Map<String, dynamic>> _roomData = {
    '!UcYsUzyxTGDxLBEvLy:general_discussion': {
      'displayName': 'General Discussion',
    },
    '!XkIsuzyxTGDxLBEvMz:project_alpha': {
      'displayName': 'Project Alpha',
    },
    '!PmNsuzyxTGDxLBEvNw:archived_room': {
      'displayName': 'Archived Room',
    },
  };

  // Simulate network delay
  static Duration get _randomDelay =>
      Duration(milliseconds: Random().nextInt(800) + 200);

  static Future<Map<String, Map<String, dynamic>>> fetchRooms() async {
    await Future.delayed(_randomDelay);

    // Simulate occasional network errors
    if (Random().nextInt(10) == 0) {
      throw Exception('Network error');
    }

    return _roomData;
  }

  static Future<Map<String, Map<String, dynamic>>> fetchUsers() async {
    await Future.delayed(_randomDelay);

    // Simulate occasional network errors
    if (Random().nextInt(10) == 0) {
      throw Exception('Network error');
    }

    return _userData;
  }
}

class MentionItem {
  final String id;
  final String displayName;

  MentionItem({
    required this.id,
    required this.displayName,
  });
}

final mentionUsersProvider = FutureProvider<List<MentionItem>>((ref) async {
  final users = <MentionItem>[];
  final userData = await MentionDataService.fetchUsers();
  for (final userId in userData.keys) {
    users.add(MentionItem(
      id: userId,
      displayName: userData[userId]?['displayName'] as String,
    ));
  }
  return users;
});

final mentionRoomsProvider = FutureProvider<List<MentionItem>>((ref) async {
  final rooms = <MentionItem>[];
  final roomData = await MentionDataService.fetchRooms();
  for (final roomId in roomData.keys) {
    rooms.add(MentionItem(
      id: roomId,
      displayName: roomData[roomId]?['displayName'] as String,
    ));
  }
  return rooms;
});
