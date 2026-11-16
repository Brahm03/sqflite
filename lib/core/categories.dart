import 'package:flutter/cupertino.dart';

class Category {
  final String name;
  final IconData icon;
  final Color color;
  const Category(this.name, this.icon, this.color);
}

abstract final class Categories {
  static const expense = [
    Category('Food', CupertinoIcons.cart_fill, CupertinoColors.systemOrange),
    Category('Transport', CupertinoIcons.car_fill, CupertinoColors.systemBlue),
    Category('Shopping', CupertinoIcons.bag_fill, CupertinoColors.systemPink),
    Category('Bills', CupertinoIcons.doc_text_fill, CupertinoColors.systemTeal),
    Category('Health', CupertinoIcons.heart_fill, CupertinoColors.systemRed),
    Category(
      'Fun',
      CupertinoIcons.game_controller_solid,
      CupertinoColors.systemPurple,
    ),
    Category('Home', CupertinoIcons.house_fill, CupertinoColors.systemBrown),
    Category(
      'Other',
      CupertinoIcons.square_grid_2x2_fill,
      CupertinoColors.systemGrey,
    ),
  ];

  static const income = [
    Category(
      'Salary',
      CupertinoIcons.briefcase_fill,
      CupertinoColors.systemGreen,
    ),
    Category(
      'Freelance',
      CupertinoIcons.device_laptop,
      CupertinoColors.systemIndigo,
    ),
    Category('Gift', CupertinoIcons.gift_fill, CupertinoColors.systemPink),
    Category(
      'Investment',
      CupertinoIcons.chart_bar_alt_fill,
      CupertinoColors.systemTeal,
    ),
    Category(
      'Other',
      CupertinoIcons.square_grid_2x2_fill,
      CupertinoColors.systemGrey,
    ),
  ];

  static Category of(String type, {required bool income}) {
    final list = income ? Categories.income : expense;
    return list.firstWhere(
      (c) => c.name == type,
      orElse: () => Category(
        type,
        CupertinoIcons.circle_grid_hex_fill,
        CupertinoColors.systemGrey,
      ),
    );
  }
}
