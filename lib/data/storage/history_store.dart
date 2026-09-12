import 'package:hive_flutter/hive_flutter.dart';
import '../models/conversion_job.dart';

class HistoryStore {
  static const String _boxName = 'conversion_history';

  Future<Box<ConversionJob>> _box() async => Hive.isBoxOpen(_boxName)
      ? Hive.box(_boxName)
      : await Hive.openBox<ConversionJob>(_boxName);

  Future<void> saveJob(ConversionJob job) async {
    final box = await _box();
    await box.put(job.id, job);
  }

  Future<List<ConversionJob>> getAllJobs() async {
    final box = await _box();
    return box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> deleteJob(String id) async => (await _box()).delete(id);

  Future<void> clearAll() async => (await _box()).clear();
}
