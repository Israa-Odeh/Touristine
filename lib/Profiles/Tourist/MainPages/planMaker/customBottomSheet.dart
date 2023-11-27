import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomBottomSheet extends StatefulWidget {
  final List<String> itemsList;

  const CustomBottomSheet({super.key, required this.itemsList});

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
      height: 400,
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
                  fontSize: 22,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FaIcon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: focusNode.hasFocus
                        ? const Color(0xFF1E889E)
                        : Colors.black,
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF1E889E),
                    width: 2.0,
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
                      fontSize: 19.5,
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
