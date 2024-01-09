import 'package:flutter/material.dart';

class ContentBox extends StatelessWidget {
  final String title;
  final String descriptionFirst;
  final String descriptionSecond;
  final bool secondBtn;
  final VoidCallback onPressedFirst;
  final VoidCallback onPressedSecond;

  const ContentBox({
    Key? key,
    required this.title,
    required this.descriptionFirst,
    required this.descriptionSecond,
    required this.secondBtn,
    required this.onPressedFirst,
    required this.onPressedSecond,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.lightGreen[100],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onPressedFirst,
                child: Text(descriptionFirst),
              ),
              const SizedBox(width: 10),
              if (secondBtn)
                ElevatedButton(
                  onPressed: onPressedSecond,
                  child: Text(descriptionSecond),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
