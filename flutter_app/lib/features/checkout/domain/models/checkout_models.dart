import 'package:flutter_app/features/orders/domain/entities/order_entity.dart';

class ShippingAddress {
  final String name;
  final String phone;
  final String city;
  final String street;
  final String? note;

  const ShippingAddress({
    required this.name,
    required this.phone,
    required this.city,
    required this.street,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'city': city,
        'street': street,
        if (note != null && note!.isNotEmpty) 'note': note,
      };
}

class ShippingOption {
  final String id;
  final String title;
  final String description;
  final double fee;
  final String estimatedTime;

  const ShippingOption({
    required this.id,
    required this.title,
    required this.description,
    required this.fee,
    required this.estimatedTime,
  });
}

class CheckoutState {
  final ShippingAddress address;
  final ShippingOption shippingOption;
  final PaymentMethod paymentMethod;
  final String? promoCode;
  final double discountAmount;
  final bool isSubmitting;

  const CheckoutState({
    this.address = const ShippingAddress(
      name: 'អតិថិជន (Customer)',
      phone: '012 888 999',
      city: 'ភ្នំពេញ (Phnom Penh)',
      street: '#123, ផ្លូវ 271, Boeng Tumpun',
    ),
    this.shippingOption = const ShippingOption(
      id: 'standard',
      title: 'ដឹកជញ្ជូនធម្មតា (Standard Delivery)',
      description: 'ដឹកជញ្ជូនរហ័សទូទាំងរាជធានី និងខេត្ត',
      fee: 0.00,
      estimatedTime: '1 - 2 ថ្ងៃ',
    ),
    this.paymentMethod = PaymentMethod.khqr,
    this.promoCode,
    this.discountAmount = 0.0,
    this.isSubmitting = false,
  });

  CheckoutState copyWith({
    ShippingAddress? address,
    ShippingOption? shippingOption,
    PaymentMethod? paymentMethod,
    String? promoCode,
    double? discountAmount,
    bool? isSubmitting,
  }) {
    return CheckoutState(
      address: address ?? this.address,
      shippingOption: shippingOption ?? this.shippingOption,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      promoCode: promoCode ?? this.promoCode,
      discountAmount: discountAmount ?? this.discountAmount,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
