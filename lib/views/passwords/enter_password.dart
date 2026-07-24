import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/config/app_colors.dart';
import 'package:quickbill/controller/passwords/check_password.dart';
import 'package:quickbill/views/commons/common_pinput.dart';
import 'package:quickbill/views/commons/drop_down.dart';
import 'package:quickbill/views/commons/submit_button.dart';
import 'package:quickbill/views/commons/text_style.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SetPassword extends StatefulWidget {
  const SetPassword({super.key});

  @override
  State<SetPassword> createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> with TickerProviderStateMixin {
  final Map<String, String> accountMap = {
    "1": "After Nature",
    "2": "V.B. Art Line",
    "3": "Ethnic Design",
    "4": "Lion Art Studio",
  };

  final CheckPasswordController checkPasswordController = Get.put(CheckPasswordController());

  late final AnimationController _introController;
  late final AnimationController _logoFloatController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _panelFade;
  late final Animation<Offset> _panelSlide;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

    _logoFloatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);

    _headerFade = CurvedAnimation(parent: _introController, curve: const Interval(0, 0.62, curve: Curves.easeOut));
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _introController, curve: const Interval(0, 0.62, curve: Curves.easeOutCubic)));
    _panelFade = CurvedAnimation(parent: _introController, curve: const Interval(0.28, 1, curve: Curves.easeOut));
    _panelSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _introController, curve: const Interval(0.28, 1, curve: Curves.easeOutCubic)));
  }

  @override
  void dispose() {
    _introController.dispose();
    _logoFloatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry<Object>> accountList =
        accountMap.entries
            .map(
              (entry) => DropdownMenuEntry<Object>(
                value: entry.key,
                label: entry.value,
                style: ButtonStyle(textStyle: WidgetStatePropertyAll(appTextStyle(fontSize: 16, color: Colors.black))),
              ),
            )
            .toList();

    return Scaffold(
      body: Stack(
        children: [
          const _PasswordBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 44),
                    child: Column(
                      children: [
                        SlideTransition(
                          position: _headerSlide,
                          child: FadeTransition(
                            opacity: _headerFade,
                            child: _PasswordHeader(floatController: _logoFloatController),
                          ),
                        ),
                        const SizedBox(height: 34),
                        SlideTransition(
                          position: _panelSlide,
                          child: FadeTransition(
                            opacity: _panelFade,
                            child: _PasswordPanel(
                              accountList: accountList,
                              checkPasswordController: checkPasswordController,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordBackground extends StatelessWidget {
  const _PasswordBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.dark, AppColors.medium, const Color(0xfff6f0ff), AppColors.backGround],
          stops: const [0, 0.38, 0.7, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 112,
            left: -48,
            right: -48,
            child: Transform.rotate(
              angle: -0.08,
              child: Container(
                height: 132,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(36),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordHeader extends StatelessWidget {
  final AnimationController floatController;

  const _PasswordHeader({required this.floatController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: floatController,
          builder: (context, child) {
            final lift = -8 * Curves.easeInOut.transform(floatController.value);
            return Transform.translate(
              offset: Offset(0, lift),
              child: Transform.scale(scale: 1 + (0.025 * floatController.value), child: child),
            );
          },
          child: const _QuickBillLogo(),
        ),
        const SizedBox(height: 20),
        Text(
          "QUICK BILL",
          style: appTextStyle(
            color: Colors.white,
            fontSize: 30,
          ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0),
        ),
        const SizedBox(height: 5),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0),
                Colors.white.withValues(alpha: 0.42),
                Colors.white.withValues(alpha: 0),
              ],
            ),
          ),
        ),

        const SizedBox(height: 5),
        Text("Secure invoice access", style: appTextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 15)),
      ],
    );
  }
}

class _QuickBillLogo extends StatelessWidget {
  const _QuickBillLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 126,
      height: 126,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 26, offset: const Offset(0, 14)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset("assets/images/quickbill-design2.png", fit: BoxFit.cover),
    );
  }
}

class _PasswordPanel extends StatelessWidget {
  final List<DropdownMenuEntry<Object>> accountList;
  final CheckPasswordController checkPasswordController;

  const _PasswordPanel({required this.accountList, required this.checkPasswordController});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(color: AppColors.dark.withValues(alpha: 0.14), blurRadius: 30, offset: const Offset(0, 18)),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Enter PIN",
            style: appTextStyle(
              color: AppColors.dark,
              fontSize: 24,
            ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0),
          ),
          const SizedBox(height: 6),
          Text(
            "Choose your business and unlock Quick Bill",
            textAlign: TextAlign.center,
            style: appTextStyle(color: Colors.black.withValues(alpha: 0.54), fontSize: 14),
          ),
          const SizedBox(height: 24),
          Obx(() {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.medium.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CommonDropDown(
                isEnable: !checkPasswordController.isLoading.value,
                onSelected: (value) {
                  checkPasswordController.selectedAccount.value = value.toString();
                },
                dropdownMenuEntries: accountList,
                width: double.infinity,
                initialSelection: checkPasswordController.selectedAccount.value,
                borderSideBorder: BorderSide(color: AppColors.medium.withValues(alpha: 0.24)),
                borderSideEnable: BorderSide(color: AppColors.medium.withValues(alpha: 0.24)),
                borderSideFocused: BorderSide(color: AppColors.medium, width: 1.5),
              ),
            );
          }),
          const SizedBox(height: 28),
          Obx(
            () => CommonPinput(
              isEnabled: !checkPasswordController.isLoading.value,
              forceErrorState: checkPasswordController.errorState.value,
              errorText: checkPasswordController.pinErrorText.value,
              controller: checkPasswordController.pinController,
              onCompleted: (pin) {
                final businessId = checkPasswordController.selectedAccount.value;
                final pass = int.parse(pin);
                checkPasswordController.verifyPassword(businessId, pass);
              },
            ),
          ),
          const SizedBox(height: 28),
          Obx(() {
            return Skeletonizer(
              enabled: checkPasswordController.isLoading.value,
              child: CommonSubmit(
                data: "Continue",
                onTap: () {
                  final businessId = checkPasswordController.selectedAccount.value;
                  final pass = int.parse(checkPasswordController.pinController.text);

                  checkPasswordController.verifyPassword(businessId, pass);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
