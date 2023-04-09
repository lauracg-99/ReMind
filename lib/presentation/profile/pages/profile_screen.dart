import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screens/popup_page_nested.dart';
import '../../styles/sizes.dart';
import '../../widgets/loading_indicators.dart';
import '../components/user_details_component.dart';
import '../components/user_image_component.dart';
import '../providers/profile_provider.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //todo: icon info
    return PopUpPageNested(
      body: Consumer(
        builder: (context, ref, child) {
          final profileIsLoading = ref.watch(
            profileProvider.select((state) =>
                state.maybeWhen(loading: () => true, orElse: () => false)),
          );
          return profileIsLoading
              ? LoadingIndicators.instance.smallLoadingAnimation(context)
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    vertical: Sizes.screenVPaddingDefault(context),
                    horizontal: Sizes.screenHPaddingDefault(context),
                  ),
                  child: Column(
                    children: [
                      const UserImageComponent(),
                      SizedBox(
                        height: Sizes.vMarginComment(context),
                      ),
                      const UserDetailsComponent(),
                      SizedBox(
                        height: Sizes.vMarginHigh(context),
                      ),
                     // const ProfileFormComponent(),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
