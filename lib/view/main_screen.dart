import 'package:battle_bro_00/common/text_style.dart';
import 'package:battle_bro_00/provider/stat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/utils.dart';
import 'stat_screen.dart';
import 'widget/inkButton.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {

  final menuTitleN = [
    'STAT CALCULATOR',
  ];

  @override
  Widget build(BuildContext context) {
    LOG('---> show main');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('BATTLE BROTHERS INFO', style: text16bold),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuItem(menuTitleN[0], onTap: () {
              Navigator.of(context).push(createAniRoute(StatScreen(title: menuTitleN[0])));
            }),
          ],
        ),
      ),
    );
  }

  _buildMenuItem(String title, {Function()? onTap}) {
    return InkButton(
      onTap: onTap,
      child: Container(
        width: 300,
        padding:  EdgeInsets.all(14),
        alignment: Alignment.center,
        child: Text(title, style: text14bold.copyWith(color: Colors.white)),
      )
    );
  }
}
