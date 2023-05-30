
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/data/auth/manage_supervised/solicitud.dart';

import '../../../domain/auth/repo/user_repo.dart';
import '../../routes/navigation_service.dart';
import '../../styles/sizes.dart';
import '../../tasks/components/card_red_button_component.dart';
import '../../widgets/card_button_component.dart';
import '../widgets/card_petition_detail_component.dart';

class PetitionCardItemComponent extends ConsumerWidget {

  const PetitionCardItemComponent({
    required this.solicitud,
    Key? key,
  }) : super(key: key);

  final Solicitud solicitud;

  @override
  Widget build(BuildContext context, ref) {
    final String rol = GetStorage().read('rol') ?? '';
    return Card(
      elevation: 6,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
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
            CardPetitionDetailsComponent(
              solicitud: solicitud,
            ),
            SizedBox(
              height: Sizes.vMarginHigh(context),
            ),
            (solicitud.estado == 'pendiente' && (rol != 'supervisor'))
            ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CardButtonComponent(
                  title: 'Rechazar',
                  onPressed: (){
                    solicitud.estado = 'rechazada';
                    ref.watch(userRepoProvider).updatePetition(solicitud);
                    NavigationService.goBack(context,rootNavigator: true);
                  },
                  isColored: true,),
                SizedBox(width: Sizes.vMarginComment(context),),
                CardButtonComponent(
                  title: 'Aceptar',
                  onPressed: (){
                    solicitud.estado = 'aceptada';
                    ref.watch(userRepoProvider).updatePetition(solicitud);
                    NavigationService.goBack(context,rootNavigator: true);
                  },
                  isColored: false,),
              ],
            )
            : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CardRedButtonComponent(
                  title: 'Borrar',
                  onPressed: (){
                    ref.watch(userRepoProvider).deletePetition(solicitud);
                    NavigationService.goBack(context,rootNavigator: true);
                  },
                  isColored: false,),
              ],
            ),
            SizedBox(
              height: Sizes.vMarginSmallest(context),
            ),

          ],
        ),
      ),
    );
  }
}
