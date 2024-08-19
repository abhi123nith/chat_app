import 'package:flutter/material.dart';

class UserSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onChanged;

  const UserSearchBar(
      {super.key, required this.searchController, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: 'Search users...',
      ),
    );
  }
}
