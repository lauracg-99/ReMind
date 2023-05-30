import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/data/auth/models/supervised.dart';

import '../../../data/auth/manage_supervised/solicitud.dart';
import '../../../data/auth/models/user_model.dart';
import '../../../domain/auth/repo/user_repo.dart';
import '../../styles/sizes.dart';
import '../card_supervised_details_components.dart';

class SupervisedCardItemComponent extends ConsumerWidget {

  final Supervised supervised;

  const SupervisedCardItemComponent(
      this.supervised, {
    Key? key,
  }) : super(key: key);


  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            CardSupervisedDetailsComponent(supervised),
          ],
        ),
      ),
    );
  }
}
