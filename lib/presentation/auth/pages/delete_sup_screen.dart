import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../screens/popup_page.dart';
import '../../styles/sizes.dart';
import '../widgets/delete_sup_component.dart';

class DeleteSupScreen extends ConsumerWidget {
  const DeleteSupScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, ref) {
    return PopUpPage(
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          padding: EdgeInsets.symmetric(
            vertical: Sizes.screenVPaddingHigh(context),
            horizontal: Sizes.screenHPaddingDefault(context),
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //const AppLogoComponent(),
                SizedBox(
                  height: Sizes.vMarginHigh(context),
                ),
                //const WelcomeComponent(),
                SizedBox(
                  height: Sizes.vMarginHigh(context),
                ),
                 DeleteSupComponent(),
                SizedBox(
                  height: Sizes.vMarginHigh(context),
                ),
              ]),
        ),
      ),
    );
  }

}
