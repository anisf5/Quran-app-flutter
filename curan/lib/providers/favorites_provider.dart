import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../models/track_model.dart';
import '../services/biometric_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final BiometricService _biometricService = BiometricService();

  List<TrackModel> _favorites = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TrackModel> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadFavorites(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await _firestoreService.getFavorites(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load favorites';
      notifyListeners();
    }
  }

  Future<bool> addFavorite(String userId, TrackModel track) async {
    try {
      await _firestoreService.addFavorite(userId, track);
      _favorites.insert(0, track);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add favorite';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFavorite(String userId, String trackId) async {
    final isAuthenticated =
        await _biometricService.authenticateForSensitiveAction(
      reason: 'Authenticate to remove from favorites',
    );

    if (!isAuthenticated) {
      _errorMessage = 'Authentication required to remove favorites';
      notifyListeners();
      return false;
    }

    try {
      await _firestoreService.removeFavorite(userId, trackId);
      _favorites.removeWhere((track) => track.id == trackId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove favorite';
      notifyListeners();
      return false;
    }
  }

  Future<bool> isFavorite(String userId, String trackId) async {
    return await _firestoreService.isFavorite(userId, trackId);
  }
}
