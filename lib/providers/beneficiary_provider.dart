import 'package:flutter/material.dart';
import '../models/beneficiary_trip_model.dart';
import '../services/beneficiary_service.dart';

class BeneficiaryProvider extends ChangeNotifier {
  final BeneficiaryService _service;

  List<BeneficiaryTripModel> _drafts = [];
  List<BeneficiaryTripModel> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  BeneficiaryProvider({BeneficiaryService? service})
      : _service = service ?? BeneficiaryService();

  List<BeneficiaryTripModel> get drafts => _drafts;
  List<BeneficiaryTripModel> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDraftsAndHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _drafts = await _service.getDrafts();
      _history = await _service.fetchHistory();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveDraft(BeneficiaryTripModel trip) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.saveDraft(trip);
      _drafts = await _service.getDrafts();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitTrip(BeneficiaryTripModel trip) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.submitTrip(trip);
      _drafts = await _service.getDrafts();
      _history = await _service.fetchHistory();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteDraft(String localId) async {
    await _service.deleteDraft(localId);
    _drafts = await _service.getDrafts();
    notifyListeners();
  }
}
