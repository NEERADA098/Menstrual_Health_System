import 'package:equatable/equatable.dart';

abstract class SupplyEvent extends Equatable {
  const SupplyEvent();
  @override
  List<Object?> get props => [];
}

class SupplyLoadRequested extends SupplyEvent {
  const SupplyLoadRequested();
}
