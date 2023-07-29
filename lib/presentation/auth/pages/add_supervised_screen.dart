import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/common/storage_keys.dart';
import 'package:remind/data/auth/manage_supervised/solicitud.dart';

import '../../../data/auth/models/supervised.dart';
import '../../../data/auth/models/user_model.dart';
import '../../../data/auth/providers/user_list_notifier.dart';
import '../../../domain/auth/repo/user_repo.dart';
import '../../../domain/services/localization_service.dart';
import '../../routes/navigation_service.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../../utils/dialogs.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_tile_component.dart';
import '../../widgets/loading_indicators.dart';
import '../providers/auth_provider.dart';

class AddSupervisedScreen extends HookConsumerWidget {
  const AddSupervisedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    var bs = tr(context).search_users;
    var emailController = useTextEditingController(text: '');
    final userList = ref.watch(userListProvider);
    var selectUser = GetStorage().read('selectUser');
    selectUser ??= false;
    if (GetStorage().read('userSelected') == null) {
      GetStorage().write('userSelected', false);
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: CustomText(
          context,
          tr(context).addSupervised,
          color:
              Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                  ? AppColors.lightThemePrimary
                  : AppColors.darkThemePrimary,
        ),
        centerTitle: true,
        leading: (GetStorage().read('uidSup') == '')
            ? const SizedBox()
            : BackButton(
                color: Theme.of(context).iconTheme.color ==
                        AppColors.lightThemeIconColor
                    ? AppColors.lightThemePrimary
                    : AppColors.darkThemePrimary,
              ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        toolbarHeight: Sizes.appBarDefaultHeight(context),
        actions: [
          Container(
            padding: EdgeInsets.only(right: Sizes.vMarginMedium(context)),
            child: IconButton(
              alignment: Alignment.center,
              onPressed: () {
                AppDialogs.showInfo(context, message: tr(context).info_verify);
              },
              icon: Icon(
                Icons.info_outline,
                color: Theme.of(context).iconTheme.color ==
                        AppColors.lightThemeIconColor
                    ? AppColors.lightThemePrimary
                    : AppColors.darkThemePrimary,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          padding: EdgeInsets.symmetric(
            vertical: Sizes.screenVPaddingDefault(context),
            horizontal: Sizes.screenHPaddingDefault(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: Sizes.vMarginHigh(context),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      suffixIcon: (selectUser) ? Icon(Icons.check) : SizedBox(),
                      suffixIconColor: Theme.of(context).iconTheme.color ==
                              AppColors.lightThemeIconColor
                          ? AppColors.lightThemePrimary
                          : AppColors.darkThemePrimary,
                      hintText: tr(context).put_text,
                      labelText: bs,
                    ),
                    controller: emailController,
                    onChanged: (value) {
                      emailController.text = value;
                      GetStorage().write('userSelected', false);
                      emailController.selection = TextSelection.fromPosition(TextPosition(offset: emailController.text.length));
                      ref.refresh(userListProvider);
                    },
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: Sizes.vMarginMedium(context),
                    ),
                    decoration: BoxDecoration(
                      color: (emailController.text.isEmpty)
                          ? Colors.transparent
                          : Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(
                          Sizes.dialogSmallRadius(context)),
                      boxShadow: [
                        BoxShadow(
                          color: (emailController.text.isEmpty)
                              ? Colors.transparent
                              : Theme.of(context).hintColor.withOpacity(0.15),
                          offset: const Offset(0, 3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: userList.when(
                      data: (user) {
                        String textoSinEspacios = emailController.text.replaceAll(RegExp(r'\s+'), '');
                        var search = textoSinEspacios;
                        List<UserModel> filteredUsers = user.where((usuario) => usuario.email.startsWith(search) && search != '').toList();

                        // Verificar si no hay usuarios filtrados y si el campo de búsqueda no está vacío
                        if (filteredUsers.isEmpty && emailController.text.isNotEmpty) {
                          return CustomTileComponent(
                            title: tr(context).no_users_found,
                            leadingIcon: Icons.info,
                            onTap: () {},
                          );
                        }
                        return (!GetStorage().read('userSelected'))
                            ? ListView.separated(
                          shrinkWrap: true,
                          separatorBuilder: (context, index) => const SizedBox(),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final usuario = filteredUsers[index];
                            // Verificar si el usuario tiene un rol de supervisor y omitirlo en la lista
                            if (usuario.rol != 'supervisor' && !isUserSupervised(usuario, ref.watch(userRepoProvider).usersSupervised)) {
                              return CustomTileComponent(
                                title: usuario.email,
                                leadingIcon: Icons.account_circle,
                                onTap: () async {
                                  FocusScope.of(context).unfocus();
                                  GetStorage().write('userSelected', true);
                                  emailController.text = usuario.email;
                                  emailController.selection = TextSelection.fromPosition(
                                      TextPosition(offset: emailController.text.length));
                                  GetStorage().write('emailSelected', usuario.email);
                                  GetStorage().write('uidSelected', usuario.uId);
                                  GetStorage().write('uidSelectedFoto', usuario.image);
                                  ref.refresh(userListProvider);
                                },
                              );
                            } else {
                              // Si el usuario tiene un rol de supervisor o ya está en la lista de supervisados, devolver un SizedBox para omitirlo
                              return const SizedBox();
                            }
                          },
                        )
                            : const SizedBox();


                      },
                      error: (err, stack) => const Column(),
                      loading: () => LoadingIndicators.instance
                          .smallLoadingAnimation(context),
                    ),
                  ),
                  SizedBox(
                    height: Sizes.vMarginSmall(context),
                  ),
                  Consumer(builder: (context, ref, child) {
                    final authLoading = ref.watch(
                      authProvider.select(
                        (state) => state.maybeWhen(
                          loading: () => true,
                          orElse: () => false,
                        ),
                      ),
                    );
                    return authLoading
                        ? LoadingIndicators.instance.smallLoadingAnimation(
                            context,
                            width: Sizes.loadingAnimationButton(context),
                            height: Sizes.loadingAnimationButton(context),
                          )
                        : CustomButton(
                            text: tr(context).addSupervised,
                            onPressed: () {
                              var emailSup = GetStorage().read('emailSelected');
                              var uidSup = GetStorage().read('uidSelected');
                              var fotoSub =
                                  GetStorage().read('uidSelectedFoto');
                              if (emailSup != null && uidSup != null) {
                                var solicitud = Solicitud(
                                  id: '',
                                  uidBoss:
                                      GetStorage().read(StorageKeys.uidUsuario),
                                  emailBoss:
                                      GetStorage().read(StorageKeys.email),
                                  emailSup: emailSup,
                                  estado: 'pendiente',
                                  uidSup: uidSup,
                                  fotoSup: fotoSub,
                                );

                                ref
                                    .watch(userRepoProvider)
                                    .setPetition(solicitud)
                                    .then(
                                      (value) => value.fold(
                                        (failure) {
                                          AppDialogs.showWarningPersonalice(
                                              context,
                                              message:
                                                  tr(context).already_sent);
                                          GetStorage()
                                              .write('userSelected', false);
                                        },
                                        (success) {
                                          AppDialogs.showInfo(context,
                                                  message: tr(context).peti_send_to)
                                              .then(
                                            (value) => NavigationService.goBack(
                                                context),
                                          );
                                        },
                                      ),
                                    );
                              }
                            },
                          );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isUserSupervised(UserModel user, List<Supervised> list) {
    final supervisedList = list;

    log('*** is ${user.email} $list');
    // Verificar si el email del usuario está presente en la lista de supervisados
    return supervisedList.any((supervised) => supervised.email == user.email);

    return false;
  }

}
