import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:application_medicines/appwrite_config.dart';
import 'package:application_medicines/medication.dart';

class MedicationController extends GetxController {
  final Databases databases = Databases(AppwriteConfig.getClient());
  final RxList<Medication> medications = <Medication>[].obs;
  final RxSet<String> pinnedMedications = <String>{}.obs; 

  static final databaseId = dotenv.env['APPWRITE_DATABASE_ID'] ?? ' ';
  static final collectionId = dotenv.env['APPWRITE_COLLECTION_ID'] ?? ' ';

  @override
  void onInit() {
    super.onInit();
    getMedications();
  }

  Future<void> addMedication(Medication medication) async {
    try {
      await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: medication.toJson(),
      );
      await getMedications();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> getMedications() async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
      );
      medications.value = response.documents
          .map((doc) => Medication.fromJson(doc.data))
          .toList();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> updateMedication(Medication medication) async {
    try {
      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: medication.id,
        data: medication.toJson(),
      );
      await getMedications();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> deleteMedication(String medicationId) async {
    try {
      await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: medicationId,
      );
      await getMedications();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void togglePin(String id) {
    if (pinnedMedications.contains(id)) {
      pinnedMedications.remove(id); // Desanclar
    } else {
      pinnedMedications.add(id); // Anclar
    }
    _sortMedications(); // Reordenar la lista
    medications.refresh(); // Notificar cambios
  }

  void _sortMedications() {
    medications.sort((a, b) {
      final aPinned = pinnedMedications.contains(a.id);
      final bPinned = pinnedMedications.contains(b.id);
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      return 0;
    });
  }
}
