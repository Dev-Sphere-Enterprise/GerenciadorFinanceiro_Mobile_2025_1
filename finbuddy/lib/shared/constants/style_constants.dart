import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//**FONT CONFIGURATION*/
final kDefaultFontFamily = GoogleFonts.poppins().fontFamily;
final kSecondaryFontFamily = GoogleFonts.nunito().fontFamily;
final kDescriptionFontFamily = GoogleFonts.firaSans().fontFamily;
//**LIGHT COLORS */
const Color kPrimaryColor = Color(0xFFE57C19);
// const Color kBackgroundColor = Colors.white;
const Color kBackgroundColor = Color.fromARGB(255, 225, 225, 225);
const Color kSecondaryColor = Color(0xFF435969);
const Color kDetailColor = Color(0xFFF87F01);
const Color kOnBackgroundColor = Colors.white;
const Color kTextColor = Color(0xFF435969);
const Color kOnSurfaceColor = Colors.white;
const Color kTextButtonColor = Colors.grey;
//**LIGHT COLORS */

//**DARK COLORS */
const Color kPrimaryDarkColor = Color(0xFF303841);
const Color kSecondaryDarkColor = Color(0xFF3A4750);
const Color kDarkTextColor = Colors.white;
//**DARK COLORS */

//*GENERAL COLORS*//
const Color kSuccessColor = Colors.greenAccent;
const Color kErrorColor = Colors.redAccent;
const Color kAlertColor = Colors.orangeAccent;
//*GENERAL COLORS*//

//*DEFAULT COLORS*//
const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);
const Color finBuddyBlueSelectedday = Color(0x5F3A86E0);
const Color corFundoScaffold = Color(0xFFF0F4F8);
const Color corCardPrincipal = Color(0x8BFAF3DD);
const Color corItemGasto = Color(0x89B9CD67);
//*DEFAULT COLORS*//

//*GRAFHIC COLORS*//
const List<Color> _barColors = [
  Colors.blueAccent,
  Colors.greenAccent,
  Colors.orangeAccent,
  Colors.purpleAccent,
  Colors.redAccent,
  Colors.cyanAccent,
];

const List<Color> _chartColors = [
  Colors.blueAccent,
  Colors.greenAccent,
  Colors.orangeAccent,
  Colors.purpleAccent,
  Colors.redAccent,
  Colors.cyanAccent,
];

//*GRAFHIC COLORS*//

//**TEXT STYLES */
const TextStyle kTitle1 = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w900,
);
const TextStyle kTitle2 = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w900,
);
const TextStyle kBody1 = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w900,
);
const TextStyle kBody2 = TextStyle(
  fontSize: 18,
);
const TextStyle kBody3 = TextStyle(
  fontSize: 16,
);
const TextStyle kCaption1 = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w900,
);
const TextStyle kCaption2 = TextStyle(
  fontSize: 14,
);
const TextStyle estiloFonteMonospace = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
  color: finBuddyDark,
);