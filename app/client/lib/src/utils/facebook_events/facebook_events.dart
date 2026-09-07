import 'dart:io';

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:ink/src/utils/webService.dart';

class FacebookEvents {
  static final facebookAppEvents = FacebookAppEvents();

  //all log for tattoo request
  static addTattooRequestLog({params}) async {
    final tattooEvent = {
      "eventName": "Request Sending",
      "parameters": _filterOutNulls(params),
    };

    await logEvent(
        name: "Request Sending",
        valueToSum: 0,
        parameters: _filterOutNulls(params));

    // WebService.platform.invokeMethod<void>('logEvent', tattooEvent);
  }

  //Registration
  static registrationEvent({params}) async {
    await logEvent(
        name: "Registration",
        valueToSum: 0,
        parameters: _filterOutNulls(params));
  }

  //Artist Profile Creation
  static artistProfileCreationEvent({params}) async {
    await logEvent(
        name: "Artist Profile Creation",
        valueToSum: 0,
        parameters: _filterOutNulls(params));
  }

  //Studio Profile Creation
  static studioProfileCreationEvent({params}) async {
    final tattooEvent = {
      "eventName": "Studio Profile Creation",
      "parameters": _filterOutNulls(params),
    };

    await logEvent(
        name: "Studio Profile Creation",
        valueToSum: 0,
        parameters: _filterOutNulls(params));

    // WebService.platform
    //     .invokeMethod<void>('logEvent', _filterOutNulls(tattooEvent));
  }

  //Subscription
  static subscriptionEvent({amount, currency, params}) async {
    final tattooEvent = {
      // "eventName": "Subscription",
      "amount": double.parse(amount),
      "currency": "EUR",
      // "currency": "EUR",
      "parameters": _filterOutNulls(params),
    };
    print("calling handlePurchase $tattooEvent");
    WebService.platform
        .invokeMethod<void>('handlePurchase', _filterOutNulls(tattooEvent));
  }

  //Subscription
  // static subscriptionBasicEvent({required String amount, currency, params}) async {
  static Future<void> subscriptionBasicEvent({
    required String amount,
    dynamic params,
  }) async {
    double? value = double.tryParse(amount??"0.0");

    await logEvent(
      name: "Subscription Basic",
      valueToSum: value, // null is OK if parse fails
      parameters: _filterOutNulls(params),
    );

    if (value == null) {
      await logEvent(
        name: "Subscription Basic",
        valueToSum: 0.0, // null is OK if parse fails
        parameters: _filterOutNulls(params),
      );
    }
  }


  //Subscription
  // static subscriptionPremiumEvent({amount, currency, params}) async {
  static subscriptionPremiumEvent({amount,  params}) async {
    double? value = double.tryParse(amount??"0.0");

    await logEvent(
        name: "Subscription Premium",
        valueToSum: value,
        parameters: _filterOutNulls(params));

    if (value == null) {
      await logEvent(
        name: "Subscription Basic",
        valueToSum: 0.0, // null is OK if parse fails
        parameters: _filterOutNulls(params),
      );
    }
  }

  //filter map and remove null values
  static Map<String, dynamic> _filterOutNulls(Map<String, dynamic> parameters) {
    final Map<String, dynamic> filtered = <String, dynamic>{};
    parameters.forEach((String key, dynamic value) {
      if (value != null) {
        filtered[key] = value;
      }
    });
    return filtered;
  }

  static const _paramNameValueToSum = "_valueToSum";

  /// Log an app event with the specified [name] and the supplied [parameters] value.
  static Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
    double? valueToSum,
  }) async {
    final args = <String, dynamic>{
      'name': name,
      _paramNameValueToSum: valueToSum,
    };

    if (parameters != null) {
      args['parameters'] = _filterOutNulls(parameters);
    }
    if (Platform.isAndroid) {
      await WebService.platform
          .invokeMethod<void>('logEvent', _filterOutNulls(args));
    } else {
      await facebookAppEvents.logEvent(name: name, parameters: parameters);
    }
  }

  //subscription
  static Future<void> addSubscription({
    required String amount,
    required String currency,
    Map<String, dynamic>? parameters,
    double? valueToSum,
  }) async {
    final args = <String, dynamic>{
      'amount': double.parse(amount),
      'currency': currency,
      _paramNameValueToSum: valueToSum,
    };

    if (parameters != null) {
      args['parameters'] = _filterOutNulls(parameters);
    }

    await WebService.platform
        .invokeMethod<void>('handlePurchase', _filterOutNulls(args));
  }
}
