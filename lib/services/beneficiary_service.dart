import 'dart:io';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/database_helper.dart';
import '../models/beneficiary_trip_model.dart';

class BeneficiaryService {
  final ApiClient _apiClient;
  final DatabaseHelper _dbHelper;

  BeneficiaryService({
    ApiClient? apiClient,
    DatabaseHelper? dbHelper,
  })  : _apiClient = apiClient ?? ApiClient(),
        _dbHelper = dbHelper ?? DatabaseHelper();

  Future<void> saveDraft(BeneficiaryTripModel trip) async {
    final draft = trip.copyWith(status: 'DRAFT', isSynced: false);
    await _dbHelper.saveOrUpdateDraft(draft);
  }

  Future<List<BeneficiaryTripModel>> getDrafts() async {
    return await _dbHelper.getDrafts();
  }

  Future<void> deleteDraft(String localId) async {
    await _dbHelper.deleteDraft(localId);
  }

  Future<BeneficiaryTripModel> submitTrip(BeneficiaryTripModel trip) async {
    final finalizedTrip = trip.copyWith(status: 'SUBMITTED');

    try {
      final response = await _apiClient.post(
        ApiConstants.beneficiaries,
        data: finalizedTrip.toApiJson(),
      );

      int? serverTripId;
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          serverTripId = int.tryParse(response.data['id']?.toString() ?? '');
        }
      }

      // If images were captured, upload them
      if (serverTripId != null) {
        await _uploadTripAttachments(serverTripId, finalizedTrip);
      }

      final syncedTrip = finalizedTrip.copyWith(
        id: serverTripId ?? finalizedTrip.id,
        isSynced: true,
      );

      await _dbHelper.saveOrUpdateDraft(syncedTrip);
      return syncedTrip;
    } catch (_) {
      // Offline fallback: persist submitted trip locally for future sync
      final localSubmitted = finalizedTrip.copyWith(isSynced: false);
      await _dbHelper.saveOrUpdateDraft(localSubmitted);
      return localSubmitted;
    }
  }

  Future<List<BeneficiaryTripModel>> fetchHistory() async {
    final localHistory = await _dbHelper.getHistory();
    return localHistory;
  }

  Future<void> _uploadTripAttachments(
    int serverTripId,
    BeneficiaryTripModel trip,
  ) async {
    if (trip.odoStartImagePath != null && File(trip.odoStartImagePath!).existsSync()) {
      try {
        final formData = FormData.fromMap({
          'module': 'beneficiary_trip',
          'entity_id': serverTripId,
          'type': 'odo_start',
          'file': await MultipartFile.fromFile(trip.odoStartImagePath!),
        });
        await _apiClient.uploadFile(path: ApiConstants.uploadAttachment, formData: formData);
      } catch (_) {}
    }

    if (trip.odoEndImagePath != null && File(trip.odoEndImagePath!).existsSync()) {
      try {
        final formData = FormData.fromMap({
          'module': 'beneficiary_trip',
          'entity_id': serverTripId,
          'type': 'odo_end',
          'file': await MultipartFile.fromFile(trip.odoEndImagePath!),
        });
        await _apiClient.uploadFile(path: ApiConstants.uploadAttachment, formData: formData);
      } catch (_) {}
    }
  }
}
