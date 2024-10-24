import 'package:appflowy_example_app/vo/mention_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mention_state.freezed.dart';

@freezed
class MentionState with _$MentionState {
  const factory MentionState({
    required bool isLoading,
    required String mentionId,
    String? displayName,
    required String mentionType, // 'user' or 'room'
    required bool isDeleted,
    @Default(false) bool isInTrash,
  }) = _MentionState;

  factory MentionState.initial({
    required String mentionId,
    required String mentionType,
  }) =>
      MentionState(
        isLoading: true,
        mentionId: mentionId,
        mentionType: mentionType,
        isDeleted: false,
      );
}

enum MentionType {
  user,
  room;

  static MentionType fromString(String value) => switch (value) {
        'user' => user,
        'room' => room,
        _ => throw UnimplementedError(),
      };
}

class MentionNotifier extends StateNotifier<MentionState> {
  MentionNotifier({required String mentionId, required String mentionType})
      : super(MentionState.initial(
            mentionId: mentionId, mentionType: mentionType)) {
    _loadMentionData();
  }

  // Simulate async operation to fetch mention data
  Future<void> _loadMentionData() async {
    Map<String, dynamic>? data;
    try {
      // Set display name based on mention type (user or room)
      if (state.mentionType == 'user') {
        data = await MentionDataService.fetchUser(state.mentionId);
        if (data != null) {
          state = state.copyWith(
              isLoading: false,
              displayName: 'User ${data['displayName']}',
              mentionId: state.mentionId);
        }
      } else if (state.mentionType == 'room') {
        data = await MentionDataService.fetchRoom(state.mentionId);
        if (data != null) {
          state = state.copyWith(
              isLoading: false,
              displayName: 'Room ${data['displayName']}}',
              mentionId: state.mentionId);
        }
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final userMentionProvider =
    StateNotifierProvider.family<MentionNotifier, MentionState, String>(
  (ref, userId) => MentionNotifier(
    mentionId: userId,
    mentionType: MentionType.user.name,
  ),
);

final roomMentionProvider =
    StateNotifierProvider.family<MentionNotifier, MentionState, String>(
  (ref, roomId) => MentionNotifier(
    mentionId: roomId,
    mentionType: MentionType.room.name,
  ),
);
