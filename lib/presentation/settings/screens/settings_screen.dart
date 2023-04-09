import 'package:flutter/material.dart';
import '../../screens/popup_page_nested.dart';
import '../../styles/sizes.dart';
import '../components/delete_component.dart';
import '../components/logout_component.dart';
import '../components/settings_sections_components/app_settings_section_component.dart';
import '../components/user_info_component.dart';

//configuracion
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //todo: icon info
    return PopUpPageNested(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: Sizes.screenVPaddingDefault(context),
            horizontal: Sizes.screenHPaddingDefault(context),
          ),
          child: Column(
            children: <Widget>[
              //info usuario
              const UserInfoComponent(),
              SizedBox(
                height: Sizes.vMarginSmall(context),
              ),
              // cambiar, tema, idioma y nombre
              const AppSettingsSectionComponent(),
              SizedBox(
                height: Sizes.vMarginMedium(context),
              ),
              SizedBox(
                height: Sizes.vMarginHigh(context),
              ),
              //cerrar sesión
              const LogoutComponent(),
              SizedBox(
                height: Sizes.vMarginHigh(context),
              ),
              //cerrar sesión
              const DeleteComponent(),
            ],
          ),
        ),
      ),
    );
  }
}
