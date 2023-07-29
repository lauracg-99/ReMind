import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../styles/sizes.dart';
import '../providers/repe_noti_provider.dart';

class RepeNotiComponent extends ConsumerWidget {
  const RepeNotiComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref){
    var repeNoti = ref.watch(timeRepetitionProvider.notifier);
    bool chose = ref.read(timeRepetitionProvider.notifier).getChoosen();

    return Column(children:[
      (chose)
      ? CupertinoTimerPicker(
          mode: CupertinoTimerPickerMode.hm,
          onTimerDurationChanged: (value){
              repeNoti.setHr(value.inHours.toString());
              repeNoti.setMinuteHour(value.inHours, value.inMinutes);
              repeNoti.setMin(value.inMinutes.toString());
              var sum = value.inMinutes;
              repeNoti.setBoth(sum.toString());

              ref.refresh(timeRepetitionProvider.notifier);

              })
        : const SizedBox(),


      SizedBox(height: Sizes.vMarginSmall(context),),

      SizedBox(height: Sizes.vMarginMedium(context),),

    ])


    ;
  }



}