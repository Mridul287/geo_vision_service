
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/incident.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class AuthState {
  final String? engineerId;
  final String? engineerName;
  final bool isAuthenticated;

  AuthState({this.engineerId, this.engineerName, this.isAuthenticated = false});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void login(String email, String password) {
    // Mock login
    state = AuthState(
      engineerId: 'ENG_001',
      engineerName: 'John Doe',
      isAuthenticated: true,
    );
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final incidentsProvider = FutureProvider.autoDispose<List<Incident>>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) return [];
  return ref.watch(apiServiceProvider).fetchIncidents(auth.engineerId!);
});

final incidentDetailProvider = FutureProvider.family<Incident, String>((ref, id) async {
  return ref.watch(apiServiceProvider).fetchIncidentDetail(id);
});
