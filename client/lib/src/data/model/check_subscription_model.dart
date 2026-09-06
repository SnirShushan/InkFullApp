class CheckSubscriptionModel {
  String? subscriptionDetail;
  int? subscriptionStatus;
  int? isPremium;
  String? expireDate;
  String? currentDate;
  String? isPostLimit;
  String? popupText;
  String? popupTextTitle;
  String? popupTextSubtitle;
  String? productId;

  CheckSubscriptionModel(
      {this.subscriptionDetail,
      this.subscriptionStatus,
      this.isPremium,
      this.expireDate,
      this.currentDate,
      this.isPostLimit,
      this.productId,
      this.popupTextTitle,
      this.popupTextSubtitle,
      this.popupText});

  CheckSubscriptionModel.fromJson(Map<String, dynamic> json) {
    subscriptionDetail = json.containsKey("subscription_detail")
        ? json['subscription_detail'].toString()
        : "";
    subscriptionStatus = json['subscription_status'];
    isPremium = identical(json['subscription_status'].toString(), "1")
        ? int.parse(json['is_premium'].toString())
        : 0;
    expireDate = identical(json['subscription_status'].toString(), "1")
        ? json['expire_date'].toString()
        : "";
    currentDate = identical(json['subscription_status'].toString(), "1")
        ? json['current_date'].toString()
        : "";
    isPostLimit = identical(json['subscription_status'].toString(), "1")
        ? json['is_post_limit'].toString()
        : "";
    popupText = identical(json['subscription_status'].toString(), "1")
        ? json['popup_text'].toString()
        : "";

    popupTextTitle = identical(json['subscription_status'].toString(), "1")
        ? json['popup_text_title']
        : "";
    popupTextSubtitle = identical(json['subscription_status'].toString(), "1")
        ? json['popup_text_subtitle']
        : "";
    productId = identical(json['subscription_status'].toString(), "1")
        ? json['product_id'].toString()
        : "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subscription_detail'] = this.subscriptionDetail;
    data['subscription_status'] = this.subscriptionStatus;
    data['is_premium'] = this.isPremium;
    data['expire_date'] = this.expireDate;
    data['current_date'] = this.currentDate;
    data['is_post_limit'] = this.isPostLimit;
    data['popup_text'] = this.popupText;
    data['popup_text_title'] = this.popupTextTitle;
    data['popup_text_subtitle'] = this.popupTextSubtitle;
    return data;
  }
}
