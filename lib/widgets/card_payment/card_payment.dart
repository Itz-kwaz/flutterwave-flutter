import 'package:flutter/material.dart';
import 'package:flutterwave/core/card_payment_manager/card_payment_manager.dart';
import 'package:flutterwave/core/core_utils/flutterwave_api_utils.dart';
import 'package:flutterwave/interfaces/card_payment_listener.dart';
import 'package:flutterwave/models/requests/charge_card/charge_card_request.dart';
import 'package:flutterwave/models/requests/charge_card/charge_request_address.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:flutterwave/utils/flutterwave_constants.dart';
import 'package:flutterwave/widgets/card_payment/authorization_webview.dart';
import 'package:flutterwave/widgets/card_payment/request_address.dart';
import 'package:flutterwave/widgets/flutterwave_view_utils.dart';
import 'package:http/http.dart' as http;

import 'request_otp.dart';
import 'request_pin.dart';

class CardPayment extends StatefulWidget {
  final CardPaymentManager _paymentManager;

  CardPayment(this._paymentManager);

  @override
  _CardPaymentState createState() => _CardPaymentState();
}

class _CardPaymentState extends State<CardPayment> implements CardPaymentListener {
  final _cardFormKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BuildContext loadingDialogContext;

  final TextEditingController _cardNumberFieldController =
      TextEditingController();
  final TextEditingController _cardMonthFieldController =
      TextEditingController();
  final TextEditingController _cardYearFieldController =
      TextEditingController();
  final TextEditingController _cardCvvFieldController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    this._cardMonthFieldController.dispose();
    this._cardYearFieldController.dispose();
    this._cardCvvFieldController.dispose();
    this._cardNumberFieldController.dispose();
  }
  var outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(6.0),
      borderSide: BorderSide(
        color: Color(0xFF9098B1),
        width: 0.5,
      )
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: widget._paymentManager.isDebugMode,
      home: Scaffold(
        key: this._scaffoldKey,
       appBar:  AppBar(
          backgroundColor: Color(0xFFfff1d0),
          title: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              text: "Pay with ",
              style: TextStyle(fontSize: 20, color: Colors.black),
              children: [
                TextSpan(
                  text: "Card",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black),
                )
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: this._cardFormKey,
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Card Number',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '1231 - 2312 - 3123 - 1231',
                      hintStyle: TextStyle(
                        color: Color(0xFF9098B1),
                      ),
                      border: outlineInputBorder,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 1.0,
                        )
                      ),
                      enabledBorder: outlineInputBorder,
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    autocorrect: false,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                    controller: this._cardNumberFieldController,
                    validator: this._validateCardField,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Expiry Date',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0,right: 8.0,bottom: 8.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: "Month",
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                  borderSide: BorderSide(
                                    color: Colors.blue,
                                    width: 1.0,
                                  )
                              ),
                              enabledBorder: outlineInputBorder,
                              border: outlineInputBorder,
                            ),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            autocorrect: false,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                            ),
                            controller: this._cardMonthFieldController,
                            validator: this._validateCardField,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Year",
                              border: outlineInputBorder,
                              enabledBorder: outlineInputBorder,
                            ),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            autocorrect: false,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                            ),
                            controller: this._cardYearFieldController,
                            validator: this._validateCardField,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Security Code',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width  * 0.4,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "cvv",
                        enabledBorder: outlineInputBorder,
                        border: outlineInputBorder,
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      autocorrect: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      ),
                      controller: this._cardCvvFieldController,
                      validator: (value) =>
                      value.isEmpty ? "cvv is required" : null,
                    ),
                  ),
                  SizedBox(
                    height: 32.0,
                  ),
                  Container(
                    width: double.infinity,
                    child: RaisedButton(
                      onPressed: this._onCardFormClick,
                      color: Colors.orangeAccent,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "PAY",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onCardFormClick() {
    this._hideKeyboard();
    if (this._cardFormKey.currentState.validate()) {
      final CardPaymentManager pm = this.widget._paymentManager;
      FlutterwaveViewUtils.showConfirmPaymentModal(
          this.context, pm.currency, pm.amount, this._makeCardPayment);
    }
  }

  void _makeCardPayment() {
    Navigator.of(this.context).pop();
    this._showLoading(FlutterwaveConstants.INITIATING_PAYMENT);
    final ChargeCardRequest chargeCardRequest = ChargeCardRequest(
        cardNumber: this._cardNumberFieldController.value.text.trim(),
        cvv: this._cardCvvFieldController.value.text.trim(),
        expiryMonth: this._cardMonthFieldController.value.text.trim(),
        expiryYear: this._cardYearFieldController.value.text.trim(),
        currency: this.widget._paymentManager.currency.trim(),
        amount: this.widget._paymentManager.amount.trim(),
        email: this.widget._paymentManager.email.trim(),
        fullName: this.widget._paymentManager.fullName.trim(),
        txRef: this.widget._paymentManager.txRef.trim(),
        country: this.widget._paymentManager.country);
    final client = http.Client();
    this
        .widget
        ._paymentManager
        .setCardPaymentListener(this)
        .payWithCard(client, chargeCardRequest);
  }

  String _validateCardField(String value) {
    return value.trim().isEmpty ? "Please fill this" : null;
  }

  void _hideKeyboard() {
    FocusScope.of(this.context).requestFocus(FocusNode());
  }

  @override
  void onRedirect(ChargeResponse chargeResponse, String url) async {
    this._closeDialog();
    final result = await Navigator.of(this.context).push(MaterialPageRoute(
        builder: (context) => AuthorizationWebview(Uri.encodeFull(url))));
    if (result != null) {
      final bool hasError = result.runtimeType != " ".runtimeType;
      this._closeDialog();
      if (hasError) {
        this._showSnackBar(result["error"]);
        return;
      }
      final flwRef = result;
      this._showLoading(FlutterwaveConstants.VERIFYING);
      final response = await FlutterwaveAPIUtils.verifyPayment(
          flwRef,
          http.Client(),
          this.widget._paymentManager.publicKey,
          this.widget._paymentManager.isDebugMode);
      this._closeDialog();
      if (response.data.status == FlutterwaveConstants.SUCCESSFUL) {
        this.onComplete(response);
      }
    } else {
      this._showSnackBar("Transaction cancelled");
    }
  }

  @override
  void onRequireAddress(ChargeResponse response) async {
    this._closeDialog();
    final ChargeRequestAddress addressDetails = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => RequestAddress()));
    if (addressDetails != null) {
      this._showLoading(FlutterwaveConstants.VERIFYING_ADDRESS);
      this.widget._paymentManager.addAddress(addressDetails);
      return;
    }
    this._closeDialog();
  }

  @override
  void onRequirePin(ChargeResponse response) async {
    this._closeDialog();
    final pin = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => RequestPin()));
    if (pin == null) return;
    this._showLoading(FlutterwaveConstants.AUTHENTICATING_PIN);
    this.widget._paymentManager.addPin(pin);
  }

  @override
  void onRequireOTP(ChargeResponse response, String message) async {
    this._closeDialog();
    final otp = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => RequestOTP(message)));
    if (otp == null) return;
    this._showLoading(FlutterwaveConstants.VERIFYING);
    final ChargeResponse chargeResponse =
        await this.widget._paymentManager.addOTP(otp, response.data.flwRef);
    this._closeDialog();
    if (chargeResponse.message == FlutterwaveConstants.CHARGE_VALIDATED) {
      this._showLoading(FlutterwaveConstants.VERIFYING);
      this._handleTransactionVerification(chargeResponse);
    } else {
      this._closeDialog();
      this._showSnackBar(chargeResponse.message);
    }
  }

  void _handleTransactionVerification(
      final ChargeResponse chargeResponse) async {
    final verifyResponse = await FlutterwaveAPIUtils.verifyPayment(
        chargeResponse.data.flwRef,
        http.Client(),
        this.widget._paymentManager.publicKey,
        this.widget._paymentManager.isDebugMode);
    this._closeDialog();

    if (verifyResponse.status == FlutterwaveConstants.SUCCESS &&
        verifyResponse.data.txRef == this.widget._paymentManager.txRef &&
        verifyResponse.data.amount == this.widget._paymentManager.amount) {
      this.onComplete(verifyResponse);
    } else {
      this._showSnackBar(verifyResponse.message);
    }
  }

  @override
  void onError(String error) {
    this._closeDialog();
    this._showSnackBar(error);
  }

  @override
  void onComplete(ChargeResponse chargeResponse) {
    Navigator.pop(this.context, chargeResponse);
  }

  void _showSnackBar(String message) {
    SnackBar snackBar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
    );
    this._scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Future<void> _showLoading(String message) {
    return showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        this.loadingDialogContext = context;
        return AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressIndicator(
                backgroundColor: Colors.orangeAccent,
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
              )
            ],
          ),
        );
      },
    );
  }

  void _closeDialog() {
    if (this.loadingDialogContext != null) {
      Navigator.of(this.loadingDialogContext).pop();
      this.loadingDialogContext = null;
    }
  }
}
