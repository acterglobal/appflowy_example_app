import 'dart:math';

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
