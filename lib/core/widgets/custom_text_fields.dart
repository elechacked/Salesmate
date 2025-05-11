import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salesmate/app/themes/app_colors.dart';
import 'package:salesmate/app/themes/app_constants.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? prefixText;
  final int? maxLines;
  final bool noBorderOnLeft;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool enabled;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;

  const CustomTextFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
    this.prefixText,
    this.maxLines = 1,
    this.noBorderOnLeft = false,
    this.inputFormatters,
    this.maxLength,
    this.enabled = true,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    required EdgeInsetsGeometry contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              labelText!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          enabled: enabled,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.hintTextColor),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(AppConstants.defaultBorderRadius),
                bottomRight: Radius.circular(AppConstants.defaultBorderRadius),
                topLeft: Radius.circular(
                    noBorderOnLeft ? 0 : AppConstants.defaultBorderRadius),
                bottomLeft: Radius.circular(
                    noBorderOnLeft ? 0 : AppConstants.defaultBorderRadius),
              ),
              borderSide: BorderSide(color: AppColors.hintTextColor.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(AppConstants.defaultBorderRadius),
                bottomRight: Radius.circular(AppConstants.defaultBorderRadius),
                topLeft: Radius.circular(
                    noBorderOnLeft ? 0 : AppConstants.defaultBorderRadius),
                bottomLeft: Radius.circular(
                    noBorderOnLeft ? 0 : AppConstants.defaultBorderRadius),
              ),
              borderSide: BorderSide(color: AppColors.hintTextColor.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(AppConstants.defaultBorderRadius),
                bottomRight: Radius.circular(AppConstants.defaultBorderRadius),
                topLeft: Radius.circular(
                    noBorderOnLeft ? 0 : AppConstants.defaultBorderRadius),
                bottomLeft: Radius.circular(
                    noBorderOnLeft ? 0 : AppConstants.defaultBorderRadius),
              ),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(AppConstants.defaultBorderRadius),
                bottomRight: Radius.circular(AppConstants.defaultBorderRadius),
                topLeft: Radius.circular(
                    noBorderOnLeft ? 0 : AppConstants.defaultBorderRadius),
                bottomLeft: Radius.circular(
                    noBorderOnLeft ? 0 : AppConstants.defaultBorderRadius),
              ),
              borderSide: const BorderSide(color: AppColors.errorColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            prefixText: prefixText,
            counterText: '',
          ),
        ),
      ],
    );
  }
}