import 'package:flutter/material.dart';

class BottomDropList extends StatefulWidget {
  final List<String> itemsList;
  final double height;
  final String title;
  final List<String> initiallySelectedItems;
  final Function(List<String>) onDone;

  const BottomDropList(
      {super.key,
      required this.itemsList,
      this.height = 400,
      required this.title,
      required this.initiallySelectedItems,
      required this.onDone});

  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<BottomDropList> {
  late List<bool> selectedItems;

  @override
  void initState() {
    super.initState();
    selectedItems = List<bool>.filled(widget.itemsList.length, false);

    // Set initially selected items.
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
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'Andalus',
                        fontSize: 20,
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
                        vertical: 20,
                      ),
                      backgroundColor: const Color(0xFF1E889E),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Zilla',
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Get the list of selected items.
                      List<String> selectedItemsList = [];
                      for (int i = 0; i < selectedItems.length; i++) {
                        if (selectedItems[i]) {
                          selectedItemsList.add(widget.itemsList[i]);
                        }
                      }
                      // Pass the selected items back to the calling widget
                      widget.onDone(selectedItemsList);
                      Navigator.pop(context);
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
                      fontSize: 17,
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
