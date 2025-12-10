import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static const String _creatorMonthlyUrl = "https://buy.stripe.com/test_creator_monthly"; 
  static const String _proMonthlyUrl = "https://buy.stripe.com/test_pro_monthly"; 
  static const String _agencyMonthlyUrl = "https://buy.stripe.com/test_agency_monthly";

  static const String _creatorAnnualUrl = "https://buy.stripe.com/test_creator_annual";
  static const String _proAnnualUrl = "https://buy.stripe.com/test_pro_annual";
  static const String _agencyAnnualUrl = "https://buy.stripe.com/test_agency_annual";

  Future<void> launchCheckout(String planId, {bool isAnnual = false}) async {
    String url = "";

    switch (planId.toLowerCase()) {
      case 'creator':
        url = isAnnual ? _creatorAnnualUrl : _creatorMonthlyUrl; 
        break;
      case 'pro':
        url = isAnnual ? _proAnnualUrl : _proMonthlyUrl;
        break;
      case 'agency':
        url = isAnnual ? _agencyAnnualUrl : _agencyMonthlyUrl;
        break;
      default:
        print("Unknown plan ID: $planId");
        return;
    }

    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication); 
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  Future<void> launchCustomerPortal() async {
    const portalUrl = "https://billing.stripe.com/p/login/test"; 
    final uri = Uri.parse(portalUrl);
     if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication); 
      }
  }
}
