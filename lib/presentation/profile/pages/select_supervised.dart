import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/common/storage_keys.dart';
import 'package:remind/presentation/widgets/custom_app_bar_widget.dart';

import '../../../../data/auth/providers/user_list_notifier.dart';
import '../../../../domain/services/localization_service.dart';
import '../../../data/auth/models/supervised.dart';
import '../../../data/auth/models/user_model.dart';
import '../../../data/firebase/repo/firebase_caller.dart';
import '../../../data/firebase/repo/firestore_paths.dart';
import '../../../domain/auth/repo/user_repo.dart';
import '../../screens/popup_page_nested.dart';
import '../../solicitudes/utils/app_bar_solicitudes.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_images.dart';
import '../../styles/sizes.dart';
import '../../tasks/providers/task_to_do.dart';
import '../../utils/dialogs.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../widgets/cached_network_image_circular.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/loading_indicators.dart';
import '../card_supervised_details_components.dart';
import '../components/supervised_card_item_component.dart';

class SelectSupervised extends HookConsumerWidget {
  const SelectSupervised({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var usuario = ref.watch(userRepoProvider).getDatosUsuario(GetStorage().read(StorageKeys.uidUsuario));
    var supervisadosList = ref.watch(supervisoresProvider);

    return PopUpPageNested(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
          vertical: Sizes.screenVPaddingDefault(context),
          horizontal: Sizes.screenHPaddingDefault(context),
          ),
          child: Column(
            children: <Widget>[
            supervisadosList.when(
              data: (supervisado) {
              log('supervisado ${supervisado.supervisados![0].email}');
              log('supervisado lengs ${supervisado.supervisados!.length}');
              return (supervisado.supervisados == [])
              ? CustomText.h4(
                  context,
                  'Sin supervisados pendientes',
                  color: AppColors.grey,
                  alignment: Alignment.center,
                  )
              : ListView.separated(
                  shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: Sizes.vPaddingTiny(context)),
                separatorBuilder: (context, index) =>
                    SizedBox(height: Sizes.vMarginHigh(context),),
                    itemCount: supervisado.supervisados?.length ?? 0,
                      itemBuilder: (context, index) {
                      List<Widget> list = [];
                      list.add(
                        Column(
                            children: [
                            GestureDetector(
                                onTap: () {

                                  ref.watch(userRepoProvider).
                                  selectedSupervisedByUID(supervisado.supervisados![index], 'true').then((value) =>

                                      value.fold((failure) {
                                        AppDialogs.showWarningPersonalice(
                                            context,
                                            message:
                                            'Error al cambiar de usuario');
                                      },
                                              (success) {
                                            ref.refresh(getTasksSup);
                                            AppDialogs.showInfo(context,
                                                message: 'Usuario cambiado '
                                                    'ahora verá las tareas de '
                                                    '${supervisado.supervisados![index].name}');

                                          }
                                      )
                                  );
                          },
                          child: Card(
                                elevation: 6,
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1.7,
                                    color: (supervisado.supervisados![index].selected == StorageKeys.verdadero)
                                        ? Theme.of(context).iconTheme.color!
                                        : Color.fromRGBO(255, 255, 255, 0)
                                  ),
                                  borderRadius: BorderRadius.circular(Sizes.cardRadius(context)),
                                ),
                                child: Padding(
                                padding: EdgeInsets.symmetric(
                                vertical: Sizes.cardVPadding(context),
                                horizontal: Sizes.cardHRadius(context),
                                ),
                                child: Column(
                                children: [
                                SizedBox(
                                height: Sizes.vMarginSmallest(context),
                                ),
                                //CardSupervisedDetailsComponent(supervisado.supervisados![index]),
                                    Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            (supervisado.supervisados![index].image == '')
                                                ? CircleAvatar(
                                              backgroundColor: Colors.transparent,
                                              radius: Sizes.userImageSmallRadius(context),
                                              child:  Image.asset(
                                                AppImages.profileCat,
                                                fit: BoxFit.cover, ),
                                            )
                                                : CachedNetworkImageCircular(
                                              imageUrl: supervisado.supervisados![index].image,
                                              radius: Sizes.userImageMediumRadius(context),
                                            ),
                                            SizedBox(
                                              width: Sizes.hMarginSmallest(context),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CustomText.h4(
                                                    context,
                                                    'Nombre: ${supervisado.supervisados![index].name}',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    color: Theme.of(context).textTheme.headline4?.color,
                                                  ),
                                                  SizedBox(height: 2,),
                                                  CustomText.h4(
                                                    context,
                                                    'email: ${supervisado.supervisados![index].email}',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    color: Theme.of(context).textTheme.headline4?.color,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Transform.scale(
                                                scale: 1.3, child:Checkbox(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30.0),
                                                // CHANGE BORDER RADIUS HERE
                                                side: BorderSide(width: 30, color: AppColors.red),
                                              ),
                                              activeColor: Theme.of(context).iconTheme.color,// Rounded Checkbox
                                              value: (supervisado.supervisados![index].selected == StorageKeys.verdadero),
                                              onChanged: (value) {
                                                ref.watch(userRepoProvider).
                                                selectedSupervisedByUID(supervisado.supervisados![index], 'true').then((value) =>

                                                    value.fold((failure) {
                                                      AppDialogs.showWarningPersonalice(
                                                          context,
                                                          message:
                                                          'Error al cambiar de usuario');
                                                    },
                                                            (success) {
                                                              ref.refresh(getTasksSup);
                                                      AppDialogs.showInfo(context,
                                                          message: 'Usuario cambiado '
                                                              'ahora verá las tareas de '
                                                              '${supervisado.supervisados![index].name}');

                                                    }
                                                    )
                                                );
                                              },
                                            ))
                                          ])
                                      ],),

                                ],
                                ),
                                ),
                              ))
                        ])
                      );
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
            ],
          ),
      ),
      )
    );
  }

}
