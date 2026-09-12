import '../models/conversion_job.dart';
import '../storage/history_store.dart';

class HistoryRepository {
  final HistoryStore _store;
  HistoryRepository(this._store);

  Future<void> saveJob(ConversionJob job) => _store.saveJob(job);
  Future<List<ConversionJob>> getJobs() => _store.getAllJobs();
  Future<void> deleteJob(String id) => _store.deleteJob(id);
  Future<void> clearHistory() => _store.clearAll();
}
