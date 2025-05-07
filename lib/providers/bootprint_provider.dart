import 'package:flutter/foundation.dart';
import '../models/bootprint_models.dart';
import '../services/bootprint_api_service.dart';

class BootprintProvider with ChangeNotifier {
  final BootprintApiService _apiService;

  // State variables
  CelestialObject _selectedObject = CelestialObject.mars;
  SpaceImageFact? _currentImageFact;
  SpaceImage? _currentImage;
  SpaceFact? _currentFact;
  bool _isLoading = false;
  String? _error;

  // Constructor
  BootprintProvider({required BootprintApiService apiService})
    : _apiService = apiService;

  // Getters
  CelestialObject get selectedObject => _selectedObject;
  SpaceImageFact? get currentImageFact => _currentImageFact;
  SpaceImage? get currentImage => _currentImage;
  SpaceFact? get currentFact => _currentFact;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set the selected celestial object
  void setSelectedObject(CelestialObject object) {
    _selectedObject = object;
    notifyListeners();
  }

  // Fetch both image and fact
  Future<void> fetchImageAndFact() async {
    _setLoading(true);
    _clearError();

    try {
      final data = await _apiService.getImageAndFact(_selectedObject);
      _currentImageFact = data;
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch only image
  Future<void> fetchImage() async {
    _setLoading(true);
    _clearError();

    try {
      final data = await _apiService.getImage(_selectedObject);
      _currentImage = data;
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch image: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch only fact
  Future<void> fetchFact() async {
    _setLoading(true);
    _clearError();

    try {
      final data = await _apiService.getFact(_selectedObject);
      _currentFact = data;
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch fact: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh current data
  Future<void> refreshData() async {
    if (_currentImageFact != null) {
      await fetchImageAndFact();
    } else if (_currentImage != null) {
      await fetchImage();
    } else if (_currentFact != null) {
      await fetchFact();
    } else {
      // Default to fetching both if nothing is currently loaded
      await fetchImageAndFact();
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Helper method to set error
  void _setError(String error) {
    _error = error;
    if (kDebugMode) {
      print(error);
    }
    notifyListeners();
  }

  // Helper method to clear error
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
