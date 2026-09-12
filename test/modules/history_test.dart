import 'package:flutter_test/flutter_test.dart';
import 'package:converter_nest/data/models/conversion_job.dart';
import 'package:converter_nest/data/repositories/history_repository.dart';
import 'package:converter_nest/data/storage/history_store.dart';
import 'package:converter_nest/modules/history/viewmodels/history_viewmodel.dart';

class FakeHistoryRepository extends HistoryRepository {
  List<ConversionJob> fakeJobs = [];

  FakeHistoryRepository() : super(HistoryStore());

  @override
  Future<List<ConversionJob>> getJobs() async => List.of(fakeJobs);

  @override
  Future<void> deleteJob(String id) async {
    fakeJobs.removeWhere((j) => j.id == id);
  }

  @override
  Future<void> clearHistory() async {
    fakeJobs.clear();
  }
}

void main() {
  group('HistoryViewModel', () {
    late FakeHistoryRepository repo;
    late HistoryViewModel vm;

    setUp(() {
      repo = FakeHistoryRepository();
      repo.fakeJobs = [
        ConversionJob(
          id: '1',
          inputFormat: 'PNG',
          outputFormat: 'JPG',
          category: 'image',
          inputFileName: 'photo.png',
          outputFilePath: '/conversions/photo.jpg',
          status: 'completed',
          inputSizeBytes: 2000,
          outputSizeBytes: 1000,
          durationMs: 120,
          createdAt: DateTime.now(),
        ),
        ConversionJob(
          id: '2',
          inputFormat: 'WAV',
          outputFormat: 'MP3',
          category: 'audio',
          inputFileName: 'song.wav',
          outputFilePath: '/conversions/song.mp3',
          status: 'completed',
          inputSizeBytes: 10000,
          outputSizeBytes: 3000,
          durationMs: 450,
          createdAt: DateTime.now(),
        ),
        ConversionJob(
          id: '3',
          inputFormat: 'MP4',
          outputFormat: 'MKV',
          category: 'video',
          inputFileName: 'clip.mp4',
          outputFilePath: '',
          status: 'failed',
          inputSizeBytes: 50000,
          outputSizeBytes: 0,
          durationMs: 30,
          createdAt: DateTime.now(),
        ),
      ];
      vm = HistoryViewModel(repo);
    });

    test('loadHistory loads and populates all jobs', () async {
      await vm.loadHistory();
      expect(vm.filteredJobs.length, 3);
      expect(vm.totalConversions, 3);
      expect(vm.successCount, 2);
      expect(vm.totalSavedBytes, (2000 - 1000) + (10000 - 3000) + 50000);
    });

    test('filter by category updates filteredJobs', () async {
      await vm.loadHistory();
      vm.setFilter(HistoryFilter.image);
      expect(vm.filteredJobs.length, 1);
      expect(vm.filteredJobs.first.inputFileName, 'photo.png');

      vm.setFilter(HistoryFilter.audio);
      expect(vm.filteredJobs.length, 1);
      expect(vm.filteredJobs.first.inputFileName, 'song.wav');

      vm.setFilter(HistoryFilter.all);
      expect(vm.filteredJobs.length, 3);
    });

    test('search query filters jobs by filename or format', () async {
      await vm.loadHistory();
      vm.setSearch('song');
      expect(vm.filteredJobs.length, 1);
      expect(vm.filteredJobs.first.id, '2');

      vm.setSearch('mkv');
      expect(vm.filteredJobs.length, 1);
      expect(vm.filteredJobs.first.id, '3');

      vm.setSearch('');
      expect(vm.filteredJobs.length, 3);
    });

    test('deleteJob removes single item', () async {
      await vm.loadHistory();
      await vm.deleteJob('1');
      expect(vm.filteredJobs.length, 2);
      expect(vm.totalConversions, 2);
    });

    test('clearAll removes all items', () async {
      await vm.loadHistory();
      await vm.clearAll();
      expect(vm.filteredJobs.isEmpty, true);
      expect(vm.totalConversions, 0);
    });
  });
}
