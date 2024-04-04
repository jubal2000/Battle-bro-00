import 'package:battle_bro_00/common/enums.dart';
import 'package:battle_bro_00/common/text_style.dart';
import 'package:battle_bro_00/common/theme_style.dart';
import 'package:battle_bro_00/model/stat_model.dart';
import 'package:battle_bro_00/provider/stat_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/utils.dart';
import 'widget/inkButton.dart';

class StatScreen extends ConsumerStatefulWidget {
  const StatScreen({super.key, required this.title});

  final String title;

  @override
  ConsumerState createState() => _StatScreenState();
}

class _StatScreenState extends ConsumerState<StatScreen> {
  final statMinTextController =
  List.generate(StatType.values.length, (index) => TextEditingController());
  final statNowTextController =
  List.generate(StatType.values.length, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    final statProv = ref.watch(statProvider);
    final maxWidth = MediaQuery.of(context).size.width > 400.0 ? 400.0 : MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLevelBox(),
                _buildMinMaxBox(),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: 1.8,
                  children: List<Widget>.of(statProv.statInfo.map((e) => _buildStatItem(e))),
                ),
                _buildButtonBox()
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildLevelBox() {
    final statProv = ref.read(statProvider);
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1)
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            alignment: Alignment.centerLeft,
            child: Text('LEVEL', style: text16bold),
          ),
          InkButton(
            onTap: () => statProv.decLevel,
            contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: Icon(Icons.remove),
          ),
          Container(
            width: 50,
            alignment: Alignment.center,
            child: Text('${statProv.currentLevel}', style: text20bold),
          ),
          InkButton(
            onTap: () => statProv.incLevel,
            contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: Icon(Icons.add),
          ),
          SizedBox(width: 5),
          Expanded(child:
            InkButton(
              onTap: () => statProv.maxLevel,
              contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              bgColor: statProv.isMaxLevel ? null : GRAY_5,
              child: Text('Max', style: text14bold),
            ),
          ),
        ],
      )
    );
  }

  _buildMinMaxBox() {
    final statProv = ref.read(statProvider);
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1)
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            alignment: Alignment.centerLeft,
            child: Text('RESULT', style: text16bold),
          ),
          Expanded(child: Row(
            children: [
              Expanded(
                child: InkButton(
                  onTap: () => statProv.setResultType(0),
                  bgColor: statProv.resultType == 0 ? null : GRAY_5,
                  contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: Text('Min', style: text14bold),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: InkButton(
                  onTap: () => statProv.setResultType(1),
                  bgColor: statProv.resultType == 1 ? null : GRAY_5,
                  contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: Text('Average', style: text14bold),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: InkButton(
                  onTap: () => statProv.setResultType(2),
                  bgColor: statProv.resultType == 2 ? null : GRAY_5,
                  contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: Text('Max', style: text14bold),
                ),
              ),
            ],
          ))
        ],
      )
    );
  }

  _buildStatItem(StatModel stat) {
    final statProv = ref.read(statProvider);
    statMinTextController[stat.type.index].text = '${statProv.getStatValue(stat.type, levelMin)}';
    statNowTextController[stat.type.index].text = '${statProv.getStatValue(stat.type)}';
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 2, color: GRAY_30),
        color: Colors.white
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image(
                  image: AssetImage('assets/images/${stat.type.index}.webp'),
                  height: 24,
                ),
                SizedBox(width: 5),
                Text(stat.type.title, style: text14bold)
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatValue(stat.type, statMinTextController[stat.type.index], true),
                Icon(Icons.arrow_forward_ios, size: 14),
                _buildStatValue(stat.type, statNowTextController[stat.type.index]),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: RatingBar.builder(
              initialRating: DBL(stat.star),
              minRating: 0,
              itemCount: 3,
              itemSize: 24,
              unratedColor: GRAY_10,
              direction: Axis.horizontal,
              itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                LOG('--> star : $rating');
                statProv.setStarValue(stat.type, DBL(rating).toInt());
              },
            ),
          ),
        ],
      )
    );
  }

  _buildStatValue(stat, controller, [bool isCanEdit = false]) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
        alignment: Alignment.center,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            filled: true,
            fillColor: isCanEdit ? Colors.white : GRAY_10,
            contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          cursorHeight: 15,
          style: text18bold,
          readOnly: !isCanEdit,
          textAlign: TextAlign.center,
          maxLines: 1,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          onTap: () {
            if (!isCanEdit) return;
            controller.clear();
          },
          onChanged: (value) {
            try {
              ref.read(statProvider).setStatValue(stat, int.parse(value));
            } catch (e) {
              LOG('--> value error : $e');
            }
          },
        ),
    ));
  }


  _buildButtonBox() {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 5),
      child: Row(
        children: [
          InkButton(
            onTap: () {
              ref.read(statProvider).clear;
            },
            child: Container(
              width: 100,
              height: 40,
              padding:  EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              child: Text('RESET', style: text14bold.copyWith(color: Colors.white)),
            )
          )
        ],
      ),
    );
  }
}
