// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';

class TextFormFieldWidget extends StatelessWidget {
  final String titleText;
  final bool titleTextVisible;
  final String hintText;
  final int minlines;
  final int maxlines;
  final controller;
  final TextInputType keyboardType;

  TextFormFieldWidget({
    this.titleTextVisible = true,
    required this.hintText,
    required this.keyboardType,
    required this.titleText,
    this.minlines = 1,
    this.maxlines = 1,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleTextVisible ? SizedBox(height: 8) : SizedBox(),
        titleTextVisible
            ? Text(titleText, style: Theme.of(context).textTheme.bodyMedium)
            : SizedBox(),
        SizedBox(height: 4),
        TextFormField(
          controller: controller,
          cursorColor: Theme.of(context).primaryColor,
          keyboardType: keyboardType,
          style: Theme.of(context).textTheme.bodyMedium,
          autocorrect: false,
          minLines: minlines,
          maxLines: maxlines,
          onChanged: (value) {
            if (value.length <= 2) {}
          },
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 4), //Change this value to custom as you like
            hintStyle: Theme.of(context).textTheme.bodyMedium,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: BorderSide(
                color: kBlack,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: BorderSide(
                color: defaultGrey,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: defaultGrey,
                )),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: kRed,
                )),
          ),
        ),
      ],
    );
  }
}
