import 'package:book_charm/providers/signin_provider.dart';
import 'package:flutter/material.dart';

import 'package:book_charm/screens/profile/view/widget/switch_button.dart';
import 'package:book_charm/utils/show_snackBar.dart';
import 'package:provider/provider.dart';

import '../../authentication/view/signup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final sp = context.read<SignInProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kToolbarHeight - 10),
            Text(
              'Settings',
              style: TextStyle(
                color: const Color(0xff686868),
                fontSize: getResponsiveFontSize(context, 30),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: getResponsiveHeight(context, 10)),
            Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(15), // Adjust the radius as needed
                border: Border.all(
                  color: Colors.transparent,
                  width: 2.0,
                ),
                color: Colors.white,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromARGB(255, 188, 137, 250),
                        width: 2.0,
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/flame.png',
                      width: getResponsiveWidth(
                          context, 50), // Adjust the width as needed
                      height: getResponsiveHeight(
                          context, 50), // Adjust the height as needed
                    ),
                  ),
                  SizedBox(
                      width: getResponsiveWidth(context,
                          10)), // Adjust the spacing between leading and title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name',
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(context, 22),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Edit personal details',
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(context, 14),
                          color: const Color(0xff686868),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(), // This will push the trailing icon to the end
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primaryColor,
                    size: 20,
                    weight: 40,
                  ),
                ],
              ),
            ),
            SizedBox(height: getResponsiveHeight(context, 25)),
            const Text(
              'Account Settings',
              style: TextStyle(
                color: Color(0xff686868),
                fontSize: 20,
                // fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white.withOpacity(0.7),
              ),
              child: const Column(
                children: [
                  CustomListTile(
                    title: 'Change Name',
                    imagePath: 'assets/images/profile.png',
                    trailingIcon: Icons.arrow_forward_ios,
                    trailingIconColor: AppColors.primaryColor,
                  ),
                  CustomListTile(
                    title: 'Change Email',
                    imagePath: 'assets/images/email.png',
                    trailingIcon: Icons.arrow_forward_ios,
                    trailingIconColor: AppColors.primaryColor,
                  ),
                  CustomListTile(
                    title: 'Change Password',
                    imagePath: 'assets/images/pass.png',
                    trailingIcon: Icons.arrow_forward_ios,
                    trailingIconColor: AppColors.primaryColor,
                  ),
                ],
              ),
            ),
            SizedBox(height: getResponsiveHeight(context, 25)),
            const Text(
              'Notifications',
              style: TextStyle(
                color: Color(0xff686868),
                fontSize: 20,
                // fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            CustomListTile(
              title: 'Notifications',
              imagePath: 'assets/images/notification.png',
              trailingIcon: Icons.arrow_forward_ios,
              trailingIconColor: AppColors.primaryColor,
              trailingWidget: Center(
                child: WhiteSwitch(
                  value: true,
                  onChanged: (value) {
                    // Handle switch state change
                    print('Switch value: $value');
                  },
                ),
              ),
            ),
            SizedBox(height: getResponsiveHeight(context, 25)),
            const Text(
              'Regional',
              style: TextStyle(
                color: Color(0xff686868),
                fontSize: 20,
                // fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white.withOpacity(0.7),
              ),
              child: Column(
                children: [
                  CustomListTile(
                    title: 'Languages',
                    imagePath: 'assets/images/translator.png',
                    trailingIcon: Icons.arrow_forward_ios,
                    trailingIconColor: AppColors.primaryColor,
                  ),
                  CustomListTile(
                    title: 'Help',
                    imagePath: 'assets/images/help.png',
                    trailingIcon: Icons.arrow_forward_ios,
                    trailingIconColor: AppColors.primaryColor,
                  ),
                  CustomListTile(
                    onTap: () {
                      sp.userSignOut().then((value) {
                        nextScreenReplace(context, AuthenticationScreen());
                      });
                    },
                    title: 'Logout',
                    imagePath: 'assets/images/logout.png',
                    trailingIcon: Icons.arrow_forward_ios,
                    trailingIconColor: AppColors.primaryColor,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String? subtitle;
  final IconData trailingIcon;
  final Color trailingIconColor;
  final Widget? trailingWidget;
  final Function()? onTap;

  const CustomListTile({
    super.key,
    required this.imagePath,
    required this.title,
    this.subtitle,
    required this.trailingIcon,
    required this.trailingIconColor,
    this.trailingWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.transparent,
            width: 2.0,
          ),
          color: Colors.white.withOpacity(0.7),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: getResponsiveHeight(context, 2)),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                // border: Border.all(
                //   color: Color.fromARGB(255, 188, 137, 250),
                //   width: 2.0,
                // ),
              ),
              child: Image.asset(
                imagePath,
                width: getResponsiveWidth(context, 35),
                height: getResponsiveWidth(context, 35),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context, 20),
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                subtitle != null
                    ? Text(
                        subtitle ?? '',
                        style: TextStyle(
                          fontSize: getResponsiveFontSize(context, 14),
                          color: const Color(0xff686868),
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    : Container(),
              ],
            ),
            const Spacer(),
            trailingWidget ??
                Icon(
                  trailingIcon,
                  color: trailingIconColor,
                  size: 20,
                  weight: 30,
                ),
          ],
        ),
      ),
    );
  }
}
