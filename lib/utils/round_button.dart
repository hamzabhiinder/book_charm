import 'package:book_charm/utils/show_snackBar.dart';
import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({
    Key? key,
    this.buttonColor = AppColors.primaryColor,
    this.textColor,
    required this.title,
    required this.onPress,
    this.width = 60,
    this.height = 50,
    this.borderRadius = 10,
    this.loading = false,
    this.borderColor = AppColors.primaryColor,
  }) : super(key: key);

  final bool loading;
  final String title;
  final double height, width;
  final double borderRadius;
  final VoidCallback onPress;

  final Color? textColor, buttonColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        // margin: const EdgeInsets.symmetric(horizontal: 10),
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor)),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      // fontWeight: FontWeight.bold,
                      color: textColor ?? Colors.white),
                ),
              ),
      ),
    );
  }
}

class RoundElevatedButton extends StatelessWidget {
  const RoundElevatedButton({
    Key? key,
    this.buttonColor = AppColors.primaryColor,
    this.textColor = Colors.white,
    required this.title,
    this.onPress,
    this.width = 60,
    this.height,
    this.borderRadius = 10,
    this.loading = false,
    this.fontStyle,
  }) : super(key: key);

  final bool loading;
  final String title;
  final double? height;
  final double width;
  final double borderRadius;
  final VoidCallback? onPress;
  final FontStyle? fontStyle;

  final Color textColor, buttonColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? getResponsiveHeight(context, 50),
      child: ElevatedButton(
          onPressed: onPress,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(buttonColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),

                // side: BorderSide(color: Colors.red)
              ),
            ),
          ),
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : Center(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: getResponsiveFontSize(context, 18),
                          fontStyle: fontStyle ?? FontStyle.normal,
                          color: textColor,
                        ),
                  ),
                )),
    );
  }
}
