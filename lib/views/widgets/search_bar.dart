import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final String placeholder;
  final TextEditingController controller;
  final bool autofocus;

  const SearchBar({this.placeholder = 'Search...', required this.controller, this.autofocus = false, Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10)
      ),
      child: Center(
        child: TextField(
          autofocus: autofocus,
          controller: controller,
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => controller.clear()
              ),
              hintText: placeholder,
              border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}