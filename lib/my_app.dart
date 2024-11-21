import 'package:new_attandance/src/presentation/auth/screen/onboarding_screen.dart';
import 'package:new_attandance/src/shared/util/q_export.dart';

class MyApps extends StatefulWidget {
  const MyApps({super.key});

  @override
  State<MyApps> createState() => _MyAppState();
}

class _MyAppState extends State<MyApps> {
  @override
  void initState() {
    super.initState();
    context.read<ThemeCubit>().cekTheme();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, state) {
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: state ? QTheme.isLight : QTheme.isDark,
          home: const OnboardingScreen(),
        );
      },
    );
  }
}
