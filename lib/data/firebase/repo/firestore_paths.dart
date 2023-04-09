class FirestorePaths {
  /// User
  static String userCollection() => 'users';

  //specific user
  static String userUId(String uid) => 'users/$uid';

  static String userDocument(String docId) => 'users/$docId';

  /// TASKs
  //static String userTask(String uid,String taskName) => 'users/$uid/tasks/$taskName';
  static String getTaskCollection(String uid) => 'users/$uid/tasks';

  static String taskPath(String uid) => 'users/$uid/tasks';

  static String taskPathDone(String uid) => 'users/$uid/tasksDone';

  ///users/OYNBqdlgp3OCzkowjPycrRlAZcj1/tasksBoss/
  static String taskPathBoss(String uid) => 'users/$uid/tasksBoss';

  static String taskPathBossDone(String uid) => 'users/$uid/tasksDoneBoss';

  static String taskById(String uid,{required String taskId}) => 'users/$uid/tasks/$taskId';

  static String taskDoneById(String uid,{required String taskId}) => 'users/$uid/tasksDone/$taskId';

  static String taskBossById(String uid,{required String taskId}) => 'users/$uid/tasksBoss/$taskId';

  static String taskBossDoneById(String uid,{required String taskId}) => 'users/$uid/tasksBossDone/$taskId';

  static String notificationPass(String uid) => 'users/$uid/notiControl';
  static String notificationPassById(String uid,{required String notiId}) => 'users/$uid/notiControl/$notiId';
  static String notificationPassByTaskId(String uid,{required String notiId}) => 'users/$uid/notiControl/$notiId';

  /// FirebaseStorage
  static String profilesImagesPath(String userId) => 'users/$userId/$userId';
}
