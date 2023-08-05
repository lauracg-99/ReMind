import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/common/storage_keys.dart';

import '../../../../data/auth/providers/user_list_notifier.dart';
import '../../../../domain/services/localization_service.dart';
import '../../../data/tasks/providers/task_provider.dart';
import '../../../domain/auth/repo/user_repo.dart';
import '../../routes/navigation_service.dart';
import '../../routes/route_paths.dart';
import '../../screens/popup_page_nested.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_images.dart';
import '../../styles/sizes.dart';
import '../../tasks/providers/task_to_do.dart';
import '../../utils/dialog_message_state.dart';
import '../../utils/dialogs.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../widgets/buttons/custom_text_button.dart';
import '../../widgets/cached_network_image_circular.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/dialog_widget.dart';
import '../../widgets/loading_indicators.dart';
import '../components/name_supervised_component.dart';

class SelectSupervised extends HookConsumerWidget {
  const SelectSupervised({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  log('supervisado lengs ${supervisado.supervisados!.length} ${supervisado.supervisados}');
                  return (supervisado.supervisados!.isEmpty)
                      ? CustomText.h3(
                          context,
                          tr(context).no_supervised,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            vertical: Sizes.screenVPaddingDefault(context),
                            horizontal: Sizes.screenHPaddingDefault(context),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(
                              vertical: Sizes.vPaddingTiny(context)),
                          separatorBuilder: (context, index) => SizedBox(
                            height: Sizes.vMarginHigh(context),
                          ),
                          itemCount: supervisado.supervisados?.length ?? 0,
                          itemBuilder: (context, index) {
                            List<Widget> list = [];
                            if (GetStorage().read(StorageKeys.lastUIDSup) ==
                                '') {
                              ref
                                  .watch(userRepoProvider)
                                  .selectedSupervisedByUID(
                                      supervisado.supervisados![index], 'true');
                            }
                            list.add(
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // Código para cambiar de usuario
                                    },
                                    child: Card(
                                      // Propiedades del Card
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: Sizes.cardVPadding(context),
                                          horizontal:
                                              Sizes.cardHRadius(context),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height:
                                                        Sizes.vMarginSmallest(
                                                            context),
                                                  ),
                                                  Column(
                                                    children: [
                                                      Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            (supervisado
                                                                        .supervisados![
                                                                            index]
                                                                        .image ==
                                                                    '')
                                                                ? CircleAvatar(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    radius: Sizes
                                                                        .userImageSmallRadius(
                                                                            context),
                                                                    child: Image
                                                                        .asset(
                                                                      AppImages
                                                                          .profileCat,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  )
                                                                : CachedNetworkImageCircular(
                                                                    imageUrl: supervisado
                                                                        .supervisados![
                                                                            index]
                                                                        .image,
                                                                    radius: Sizes
                                                                        .userImageMediumRadius(
                                                                            context),
                                                                  ),
                                                            SizedBox(
                                                              width: Sizes
                                                                  .hMarginSmallest(
                                                                      context),
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  CustomText.h4(
                                                                    context,
                                                                    '${tr(context).name}: ${supervisado.supervisados![index].name}',
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headline4
                                                                        ?.color,
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  CustomText.h4(
                                                                    context,
                                                                    '${tr(context).email}: ${supervisado.supervisados![index].email}',
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headline4
                                                                        ?.color,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Transform.scale(
                                                                scale: 1.3,
                                                                child: Checkbox(
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30.0),
                                                                    // CHANGE BORDER RADIUS HERE
                                                                    side: const BorderSide(
                                                                        width:
                                                                            30,
                                                                        color: AppColors
                                                                            .red),
                                                                  ),
                                                                  activeColor: Theme.of(
                                                                          context)
                                                                      .iconTheme
                                                                      .color,
                                                                  // Rounded Checkbox
                                                                  value: (supervisado
                                                                          .supervisados![
                                                                              index]
                                                                          .selected ==
                                                                      StorageKeys
                                                                          .verdadero),
                                                                  onChanged:
                                                                      (value) {
                                                                    ref
                                                                        .watch(
                                                                            userRepoProvider)
                                                                        .selectedSupervisedByUID(
                                                                            supervisado.supervisados![
                                                                                index],
                                                                            'true')
                                                                        .then((value) =>
                                                                            value.fold((failure) {
                                                                              AppDialogs.showWarningPersonalice(context, message: tr(context).fail_change_user);
                                                                            }, (success) {
                                                                              ref.refresh(getTasksSup);
                                                                              AppDialogs.showInfo(context, message: '${tr(context).see_tasks_of} ${supervisado.supervisados![index].name}');
                                                                            }));
                                                                  },
                                                                ))
                                                          ])
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color:
                                                    AppColors.accentColorDark,
                                              ),
                                              onPressed: () async {
                                                if (GetStorage().read(
                                                        StorageKeys
                                                            .lastUIDSup) ==
                                                    supervisado
                                                        .supervisados![index]
                                                        .uId) {
                                                  ref
                                                      .watch(userRepoProvider)
                                                      .updateSelectUserUIDLast();
                                                  ref
                                                      .watch(
                                                          nameSupervisedProvider
                                                              .notifier)
                                                      .changeState(change: '');
                                                }
                                                ref
                                                    .watch(userRepoProvider)
                                                    .deleteSupervisedByUID(
                                                        supervisado
                                                            .supervisados![
                                                                index]
                                                            .uId);
                                                /*ref
                                                    .watch(
                                                        taskProvider.notifier)
                                                    .deleteSupTasks(
                                                        context,
                                                        supervisado
                                                            .supervisados![
                                                                index]
                                                            .uId);*/
                                                GetStorage().write(
                                                    StorageKeys.lastUIDSup, '');
                                                GetStorage().write(
                                                    StorageKeys.lastEmailSup,
                                                    '');
                                                GetStorage().write(
                                                    StorageKeys.lastNameSup,
                                                    '');

                                                //AppDialogs.showInfo(context,message: 'Ya no supervisa a este usuario');

                                                await DialogWidget
                                                    .showCustomDialog(
                                                  context: context,
                                                  dialogWidgetState: Theme.of(
                                                                  context)
                                                              .iconTheme
                                                              .color ==
                                                          AppColors
                                                              .lightThemeIconColor
                                                      ? DialogWidgetState.info
                                                      : DialogWidgetState
                                                          .infoDark,
                                                  title: tr(context).info,
                                                  description:
                                                      tr(context).done_supervision,
                                                  backgroundColor: AppColors
                                                      .lightThemePrimaryColor,
                                                  textButton: tr(context).oK,
                                                  onPressed: () {
                                                    NavigationService
                                                        .pushReplacementAll(
                                                      NavigationService.context,
                                                      isNamed: true,
                                                      page: RoutePaths.home,
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            return Column(children: list);
                          },
                        );
                },
                error: (err, stack) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText.h4(
                            context,
                            '${tr(context).somethingWentWrong}\n${tr(context).pleaseTryAgainLater}',
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
    ));
  }

  showAlertDialogDelete(BuildContext context, WidgetRef ref, String uidSup) {
    // set up the buttons
    Widget okButton = CustomTextButton(
      child: CustomText.h4(context, tr(context).delete, color: AppColors.blue),
      onPressed: () {
        //NavigationService.goBack(context,rootNavigator: true);
        ref
            .watch(userRepoProvider)
            .deleteSupervisedByUID(uidSup)
            .then((value) => value.fold((failure) {
                  AppDialogs.showWarningPersonalice(context,
                      message: tr(context).fail_change_user);
                }, (success) {
                  AppDialogs.showInfo(context,
                      message: tr(context).delete_supervised);
                }));
        NavigationService.goBack(context, rootNavigator: true);
      },
    );

    Widget cancelButton = CustomTextButton(
      child: CustomText.h4(context, tr(context).cancel, color: AppColors.red),
      onPressed: () {
        NavigationService.goBack(context, rootNavigator: true);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: CustomText.h2(context, tr(context).adv),
      content: CustomText.h3(context, tr(context).adv_del_sup),
      actions: [
        cancelButton,
        okButton,
      ],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
