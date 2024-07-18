import 'package:employee_info/model/emp_info_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmpInfoScreen extends StatelessWidget {
  final String title;
  final List<EmpInfoItem> items;

  EmpInfoScreen({Key? key, required this.title, this.items = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.redAccent,

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: CardList(items: items),
      bottomNavigationBar: BottomAppBar(
        color: Colors.redAccent,
        child: Container(
          child: Center(
            child: Text(
              'Mohammed Ali',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ),
        ),
        height: 49.0,
      ),

    );
  }
}

class CardList extends StatelessWidget {
  final List<EmpInfoItem> items;

  CardList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(8.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return CustomCard(item: items[index], isFirstItem: index == 0);
      },
    );
  }
}

class CustomCard extends StatelessWidget {
  final EmpInfoItem item;
  final bool isFirstItem;

  CustomCard({required this.item, required this.isFirstItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,

              ),
            ),
            _buildValueWidget(item.value),
          ],
        ),
      ),
    );
  }

  Widget _buildValueWidget(String value) {
    // Check if the value is numeric and can be parsed as double
    double? numericValue = double.tryParse(value);

    // Check if the item is the first item and if the value is numeric
    if (isFirstItem || numericValue == null) {
      // If it's the first item or not numeric, display it as text
      return Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    } else {
      // If it's numeric and not the first item, format it as decimal
      NumberFormat decimalFormat = NumberFormat.decimalPattern();
      return Text(
        decimalFormat.format(numericValue),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    }
  }
}
