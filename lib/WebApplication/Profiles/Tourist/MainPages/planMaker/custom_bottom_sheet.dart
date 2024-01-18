import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class CustomBottomSheet extends StatefulWidget {
  final List<String> itemsList;
  final double height;

  const CustomBottomSheet(
      {super.key, required this.itemsList, this.height = 280});

  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  List<String> filteredItems = [];
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    filteredItems.addAll(widget.itemsList);
    focusNode = FocusNode();
  }

  void _filterItems(String query) {
    setState(() {
      filteredItems = widget.itemsList
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              focusNode: focusNode,
              onChanged: _filterItems,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(
                  fontSize: 18,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FaIcon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: 20,
                    color: focusNode.hasFocus
                        ? const Color(0xFF1E889E)
                        : Colors.black,
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF1E889E),
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    filteredItems[index],
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, filteredItems[index]);
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
