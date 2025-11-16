import 'package:equatable/equatable.dart';
import 'package:opn_test_template/app/features/specialty/model/specialty_model.dart';

enum SpecialtyStatus {
  initial,
  loading,
  loaded,
  error,
}

class SpecialtyState extends Equatable {
  final SpecialtyStatus status;
  final List<Specialty> specialties;
  final Specialty? currentSpecialty;
  final String? errorMessage;

  const SpecialtyState({
    this.status = SpecialtyStatus.initial,
    this.specialties = const [],
    this.currentSpecialty,
    this.errorMessage,
  });

  SpecialtyState copyWith({
    SpecialtyStatus? status,
    List<Specialty>? specialties,
    Specialty? currentSpecialty,
    String? errorMessage,
  }) {
    return SpecialtyState(
      status: status ?? this.status,
      specialties: specialties ?? this.specialties,
      currentSpecialty: currentSpecialty ?? this.currentSpecialty,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get hasSpecialty => currentSpecialty != null;
  bool get isLoading => status == SpecialtyStatus.loading;
  bool get hasError => status == SpecialtyStatus.error;

  @override
  List<Object?> get props => [status, specialties, currentSpecialty, errorMessage];
}