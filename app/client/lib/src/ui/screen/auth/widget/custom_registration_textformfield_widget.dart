import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ink/src/utils/colors.dart';

class CustomRegistrationTextForm extends StatefulWidget {
  final String title;
  final String errormsg;
  final bool showError;
  final bool isreadonly;
  final TextInputType keyboardType;
  final FormFieldValidator<String> txtvalidation;
  final TextEditingController textEditingController;
  final ValueChanged<String>? onChanged;

  const CustomRegistrationTextForm({
    super.key,
    this.isreadonly = false,
    this.showError = false,
    required this.textEditingController,
    required this.errormsg,
    required this.title,
    this.keyboardType = TextInputType.text,
    required this.txtvalidation,
    this.onChanged,
  });

  @override
  State<CustomRegistrationTextForm> createState() =>
      _CustomRegistrationTextFormState();
}

class _CustomRegistrationTextFormState
    extends State<CustomRegistrationTextForm> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: titleTextWhiteColor, fontWeight: FontWeight.w400),
        ).tr(),
        SizedBox(height: size.height * 0.01),
        TextFormField(
          readOnly: widget.isreadonly,
          autofocus: false,
          controller: widget.textEditingController,
          keyboardType: widget.keyboardType,
          cursorColor: kWhite,
          style: const TextStyle(color: kWhite),
          maxLines: 1,
          validator: widget.txtvalidation,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            filled: true,
            fillColor: socialoginbtn,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.showError ? Colors.red : Colors.transparent,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.showError ? Colors.red : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.showError ? Colors.red : Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            errorMaxLines: 1,
            errorText: widget.showError ? widget.errormsg : null,
            errorStyle: const TextStyle(
              height: 0,
              color: Colors.transparent,
              fontSize: 0,
            ),
          ),
        ),
        if (widget.showError)
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: errorColor),
                SizedBox(width: size.width * 0.02),
                Text(
                  widget.errormsg,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: errorColor, fontWeight: FontWeight.w400),
                ).tr(),
              ],
            ),
          ),
      ],
    );
  }
}
