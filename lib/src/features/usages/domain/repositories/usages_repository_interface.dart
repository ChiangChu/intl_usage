import '../entities/usage_entry.dart';

abstract interface class IUsagesRepository {
  Future<Map<String, Set<UsageEntry>>> findUsages(List<String> translationKeys);
}
