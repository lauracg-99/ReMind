import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/presentation/widgets/custom_app_bar_widget.dart';

import '../../../data/auth/providers/user_list_notifier.dart';
import '../../../domain/services/localization_service.dart';
import '../../providers/home_base_nav_providers.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../../utils/home_base_nav_appbar.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/loading_indicators.dart';
import '../components/petition_card_item_component.dart';
import '../utils/app_bar_solicitudes.dart';

class PendingPetitions extends HookConsumerWidget {
  const PendingPetitions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final petitionsStream = ref.watch(petitionstProviderAll);
    final _scaffoldKey = useMemoized(() => GlobalKey<ScaffoldState>());
    final String rol = GetStorage().read('rol') ?? '';
    return Scaffold(
      appBar: AppBarSolicitudes(
        title: 'Peticiones pendientes',
        toolbarHeight: Sizes.appBarDefaultHeight(context),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        scaffoldKey: _scaffoldKey,
      ),
      body:petitionsStream.when(
        data: (petitionsToDo) {
          log('petitionsToDo ${petitionsToDo.length}');
          return (petitionsToDo.isEmpty)
              ? CustomText.h4(
                  context,
                  'Sin notificaciones pendientes',
                  color: AppColors.grey,
                  alignment: Alignment.center,
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(
                    vertical: Sizes.screenVPaddingDefault(context),
                    horizontal: Sizes.screenHPaddingMedium(context),
                  ),
                  separatorBuilder: (context, index) => SizedBox(
                    height: Sizes.vMarginHigh(context),
                  ),
                  itemCount: petitionsToDo.length,
                  itemBuilder: (context, index) {
                    List<Widget> list = [];
                    if(petitionsToDo[index].estado == 'pendiente' || petitionsToDo[index].estado == 'rechazada'){
                      list.add(
                          PetitionCardItemComponent(
                            solicitud: petitionsToDo[index],
                          )
                      );
                    }

                    if(list.isEmpty){
                      list.add(CustomText.h4(
                        context,
                        'Sin notificaciones pendientes',
                        color: AppColors.grey,
                        alignment: Alignment.center,
                      ));
                    }
                    return Column(children: list);
                  },
                );
        },
        error: (err, stack) =>
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CustomText.h4(
                context,
                tr(context).somethingWentWrong +
                    '\n' +
                    tr(context).pleaseTryAgainLater,
                color: AppColors.grey,
                alignment: Alignment.center,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: Sizes.vMarginMedium(context),
              ),
              CustomButton(
                  text: tr(context).recharge,
                  onPressed: () {
                    ref.refresh(petitionstProvider);
                  })
            ]),
        loading: () =>
            LoadingIndicators.instance.smallLoadingAnimation(context))
    );
  }
}
