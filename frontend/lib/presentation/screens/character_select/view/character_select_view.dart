import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palink_v2/core/theme/app_fonts.dart';
import 'package:palink_v2/di/locator.dart';
import 'package:palink_v2/presentation/screens/character_select/controller/character_select_viewmodel.dart';
import 'package:palink_v2/presentation/screens/character_select/view/components/character_list.dart';
import 'package:palink_v2/presentation/screens/common/appbar_perferred_size.dart';
import 'package:sizing/sizing.dart';

class CharacterSelectView extends StatelessWidget {
  final CharacterSelectViewModel viewModel = Get.put(getIt<CharacterSelectViewModel>());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('PALINK', style: textTheme().titleLarge),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: const Text('️Coming soon. \nPlease look forward to the next update ☺️'),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
        bottom: appBarBottomLine(),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 0.06.sh),
            Text('Please select \none of the friends below.', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 0.05.sh),
            Expanded(
              child: Obx(() {
                if (viewModel.characters.isEmpty) {
                  return const Center(child: Text('No characters available.'));
                }
                return CharacterList(characters: viewModel.characters);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
