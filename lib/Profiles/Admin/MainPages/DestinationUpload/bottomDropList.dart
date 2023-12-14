import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomDropList extends StatefulWidget {
  final List<String> itemsList;
  final double height;
  final List<String> initiallySelectedItems;
  final Function(List<String>) onDone;

  const BottomDropList({
    Key? key,
    required this.itemsList,
    required this.initiallySelectedItems,
    required this.onDone,
    this.height = 400,
  }) : super(key: key);

  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<BottomDropList> {
  late List<bool> selectedItems;

  @override
  void initState() {
    super.initState();
    selectedItems = List<bool>.filled(widget.itemsList.length, false);

    // Set initially selected items
    for (var item in widget.initiallySelectedItems) {
      int index = widget.itemsList.indexOf(item);
      if (index != -1) {
        selectedItems[index] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            color: Colors.black12,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Text(
                      'Working Days',
                      style: TextStyle(
                        fontFamily: 'Andalus',
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 18, 83, 96),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      backgroundColor: const Color(0xFF1E889E),
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontFamily: 'Zilla',
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Get the list of selected items
                      List<String> selectedItemsList = [];
                      for (int i = 0; i < selectedItems.length; i++) {
                        if (selectedItems[i]) {
                          selectedItemsList.add(widget.itemsList[i]);
                        }
                      }

                      // Pass the selected items back to the calling widget
                      widget.onDone(selectedItemsList);
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    child: const Text('Done'),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.itemsList.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  activeColor: const Color(0xFF1E889E),
                  title: Text(
                    widget.itemsList[index],
                    style: const TextStyle(
                      fontSize: 19.5,
                    ),
                  ),
                  value: selectedItems[index],
                  onChanged: (bool? value) {
                    setState(() {
                      selectedItems[index] = value!;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
