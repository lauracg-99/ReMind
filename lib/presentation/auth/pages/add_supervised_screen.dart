import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/common/storage_keys.dart';
import 'package:remind/data/auth/manage_supervised/solicitud.dart';

import '../../../data/auth/manage_supervised/send_notification.dart';
import '../../../data/auth/models/user_model.dart';
import '../../../data/auth/providers/auth_provider.dart';
import '../../../data/auth/providers/user_list_notifier.dart';
import '../../../domain/auth/repo/user_repo.dart';
import '../../../domain/services/localization_service.dart';
import '../../routes/navigation_service.dart';
import '../../routes/route_paths.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../../utils/dialogs.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_tile_component.dart';
import '../../widgets/loading_indicators.dart';
import '../providers/auth_provider.dart';
import '../widgets/register_supervised_component.dart';

class AddSupervisedScreen extends HookConsumerWidget {
  const AddSupervisedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    var bs = 'Buscar usuarios';
    var emailController = useTextEditingController(text: '');
    final userList = ref.watch(userListProvider);

    var selectUser = GetStorage().read('selectUser');
    if (selectUser == null) {
      selectUser = false;
    }
    if(GetStorage().read('userSelected') == null){
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
            ? SizedBox()
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
                  AppDialogs.showInfo(context,
                      message: tr(context).info_verify);
                },
                icon: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).iconTheme.color ==
                          AppColors.lightThemeIconColor
                      ? AppColors.lightThemePrimary
                      : AppColors.darkThemePrimary,
                )),
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
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            //const RegisterSupervisedFormComponent(),
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
                    // Icono que deseas agregar
                    hintText: 'Ingrese su texto',
                    labelText: bs,
                  ),
                  controller: emailController,
                  onChanged: (value) {
                    emailController.text = value;
                    log('text fiel ${value}');
                    GetStorage().write('userSelected', false);
                    emailController.selection =
                        TextSelection.fromPosition(TextPosition(
                            offset: emailController.text.length)
                        );
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
                      Sizes.dialogSmallRadius(context),
                    ),
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
                    // Obtén los usuarios que coinciden con el texto introducido
                    List<UserModel> filteredUsers = user.where((usuario) =>
                    usuario.email.startsWith(search) && search != '').toList();
                    if (filteredUsers.isEmpty && emailController.text.isNotEmpty) {
                      // No se encontraron usuarios, mostrar el campo "No se han encontrado usuarios"
                      return CustomTileComponent(
                        title: 'No se han encontrado usuarios',
                        leadingIcon: Icons.info,
                        onTap: () {},
                      );
                    }
                    return (!GetStorage().read('userSelected'))
                    ? ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => SizedBox(
                        //height: Sizes.vMarginSmall(context),
                      ),
                      itemCount: user.length,
                      itemBuilder: (context, index) {
                        String textoSinEspacios = emailController.text.replaceAll(RegExp(r'\s+'), '');
                        var search = textoSinEspacios;
                        final usuario = user[index];
                        List<Widget> list = [];
                        List<String> emails = [];
                        Map<String, String> valores = Map<String, String>();

                        //log('*** usuario ${usuario.email} ${usuario.uId} ${usuario.image}');

                        for (var individual in user) {
                          emails.add(individual.email);
                          valores[individual.email] = individual.uId;
                        }

                        if (usuario.email.startsWith(search) && search != '') {
                          if (usuario.email != GetStorage().read('email')) {
                            //log('*** usuarioemail ${usuario.email}');
                            list.add(
                                CustomTileComponent(
                                  title: usuario.email,
                                  leadingIcon: Icons.account_circle,
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();
                                    GetStorage().write('userSelected', true);
                                    emailController.text = usuario.email;
                                    emailController.selection = TextSelection.fromPosition(TextPosition(
                                            offset: emailController.text.length)
                                        );
                                    GetStorage().write('emailSelected', usuario.email);
                                    GetStorage().write('uidSelected', usuario.uId);
                                    GetStorage().write('uidSelectedFoto', usuario.image);

                                    ref.refresh(userListProvider);
                                  },
                            ));
                          } else {
                            if(valores.isNotEmpty){
                              return CustomTileComponent(
                                title: 'No se han encontrado usuarios',
                                leadingIcon: Icons.info,
                                onTap: () {},
                              );
                            }
                          }
                        }
                        return (list.isEmpty) ? SizedBox() : Column(children: list);
                      },
                    )
                    : SizedBox();
                  },
                  error: (err, stack) => Column(),
                  loading: () =>
                      LoadingIndicators.instance.smallLoadingAnimation(context),
                )),
                SizedBox(
                  height: Sizes.vMarginSmall(context),
                ),
                Consumer(
                    builder: (context, ref, child) {
                      final authLoading = ref.watch(
                        authProvider.select((state) => state.maybeWhen(
                            loading: () => true, orElse: () => false)),
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
                            var fotoSub = GetStorage().read('uidSelectedFoto');
                           // log('*** selected uidSup $uidSup y emailSup $emailSup');
                            if (emailSup != null && uidSup != null) {
                              var solicitud = Solicitud(
                                id: '',
                                uidBoss: GetStorage().read(StorageKeys.uidUsuario),
                                emailBoss: GetStorage().read(StorageKeys.email),
                                emailSup: emailSup,
                                estado: 'pendiente',
                                uidSup: uidSup,
                                fotoSup: fotoSub,
                              );

                              //misma entrada para supervisor que para supervisado pero cada una en sus respectivas cuentas
                              ref
                                  .watch(userRepoProvider)
                                  .setPetition(solicitud)
                                  .then((value) =>

                                  value.fold((failure) {
                                    AppDialogs.showWarningPersonalice(
                                        context,
                                        message:
                                        'ya le has enviado una petición a este usuario');
                                    GetStorage().write('userSelected', false);
                                  }, (success) {

                                    AppDialogs.showInfo(context,
                                        message: 'Petición enviada').then((value) => NavigationService.goBack(context));

                                  }
                                  )
                              );
                              //ref.watch(userRepoProvider).setPetitionTOSup(solicitud);
                            }
                          }
                      );
                    }
                )
              ]),
            ]),
          ),)
        );
  }
}
