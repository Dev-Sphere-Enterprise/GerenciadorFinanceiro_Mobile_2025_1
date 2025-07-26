import 'package:rate_my_app/rate_my_app.dart';

class AppReviewController {
  static RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 0,
    minLaunches: 0,
    remindDays: 3,
    remindLaunches: 5,
    googlePlayIdentifier: 'com.ardevstudio.iegg',
  );
}
