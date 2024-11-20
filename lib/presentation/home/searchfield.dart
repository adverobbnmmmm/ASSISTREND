import 'package:assistrend/presentation/main/debouncer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  _SearchFieldState createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _debouncer = Debouncer(milliseconds: 500);
  final ValueNotifier<double> widthFactor = ValueNotifier<double>(0.42);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ValueListenableBuilder<double>(
      valueListenable: widthFactor,
      builder: (context, value, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size.width * (1 - widthFactor.value),
          height: 50,
          child: CupertinoSearchTextField(
            onChanged: (value) {
              if (value.isEmpty) {
                return;
              }
              _debouncer.run(() {});
            },
            onTap: () {
              setState(() {
                widthFactor.value = 0.0;
              });
            },
            decoration: BoxDecoration(
              color: const Color(0xFF181A1C),
              borderRadius: BorderRadius.circular(20),
            ),
            prefixIcon: const Icon(
              CupertinoIcons.search,
              color: Colors.grey,
            ),
            prefixInsets: const EdgeInsetsDirectional.only(start: 5),
            suffixIcon: const Icon(
              CupertinoIcons.xmark_circle_fill,
              color: Colors.grey,
            ),
            style: const TextStyle(
              color: Colors.white,
            ),
            placeholder: 'Search Message',
            placeholderStyle: const TextStyle(
              color: Colors.white70,
            ),
          ),
        );
      },
    );
  }
}
