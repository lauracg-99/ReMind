
import '../styles/app_images.dart';
import 'dialog_message_state.dart';

Map<DialogWidgetState, dynamic> dialogMessageData = {
  DialogWidgetState.error: {"icon": AppImages.warning},
  DialogWidgetState.noHeader: {"icon": AppImages.noHeader},
  DialogWidgetState.info: {"icon": AppImages.info},
  DialogWidgetState.infoDark: {"icon": AppImages.infoDark},
  DialogWidgetState.infoReversed: {"icon": AppImages.infoReverse},
  DialogWidgetState.question: {"icon": AppImages.ask},
  DialogWidgetState.success: {"icon": AppImages.success},
  DialogWidgetState.warning: {"icon": AppImages.warning},
  DialogWidgetState.confirmation: {"icon": AppImages.confirmation},
  DialogWidgetState.location: {"icon": AppImages.location},

  DialogWidgetState.correct: {"icon": AppImages.correct},
};
