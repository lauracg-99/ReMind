import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/presentation/tasks/components/task_name_text_fields.dart';
import '../../../data/tasks/models/task_model.dart';
import '../../../domain/services/localization_service.dart';
import '../../routes/navigation_service.dart';
import '../../routes/route_paths.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../../widgets/buttons/custom_text_button.dart';
import '../../widgets/card_button_component.dart';
import '../../widgets/card_user_details_component.dart';
import '../../widgets/custom_text.dart';
import '../providers/name_task_provider.dart';
import 'card_red_button_component.dart';


class NameTaskComponent extends HookConsumerWidget {
  const NameTaskComponent( {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {

    final nameController = useTextEditingController(text: '');

    final nameProvider = ref.read(nameTaskProvider.notifier);

    final nameTaskFormKey = useMemoized(() => GlobalKey<FormState>());



    return Form(
      key: nameTaskFormKey,
      child: Column(
        children: [
          NameTaskTextFieldsSection(
            nameController: nameController,
            onFieldSubmitted: (value) {
              //log(value + 'component');
              //log('hey');
              if (nameTaskFormKey.currentState!.validate()) {
                useEffect(() {
                  nameController.text = value;
                },);
                nameController.text= value;
                //  nameProvider.controllerName();
                nameProvider.setNameTask(value);
              }
            },
          ),
        ],
      ),
    );
  }
}