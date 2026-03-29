import 'package:equatable/equatable.dart';

class ConfessionState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  
  /// The month number (1-12) the user is currently assigned to confess for. 
  /// Null if no confessions are currently due (or all 12 submitted).
  final int? requiredMonthNumber;
  
  /// Whether the user just successfully locked a confession.
  final bool isLocked;

  const ConfessionState({
    this.isLoading = true,
    this.errorMessage,
    this.requiredMonthNumber,
    this.isLocked = false,
  });

  ConfessionState copyWith({
    bool? isLoading,
    String? errorMessage,
    int? requiredMonthNumber,
    bool? isLocked,
    bool clearError = false,
  }) {
    return ConfessionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      requiredMonthNumber: requiredMonthNumber ?? this.requiredMonthNumber,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        requiredMonthNumber,
        isLocked,
      ];
}
