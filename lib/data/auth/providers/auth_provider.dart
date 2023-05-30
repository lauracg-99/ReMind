import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../repo/auth_repo.dart';

final authRepoProvider = Provider<AuthRepo>((ref) => AuthRepo(ref));
