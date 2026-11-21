enum OrderStatus { pending, preparing, processing, delivering, shipped, delivered, cancelled }
enum PaymentStatus { unpaid, paid, failed, refunded }
enum PaymentMethod { khqr, cod, card }

class OrderItemEntity {
  final String productId;
  final String name;
  final double price;
  final String? image;
  final int quantity;
  final double subtotal;

  const OrderItemEntity({
    required this.productId,
    required this.name,
    required this.price,
    this.image,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
    return OrderItemEntity(
      productId: json['product_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'name': name,
        'price': price,
        'image': image,
        'quantity': quantity,
        'subtotal': subtotal,
      };
}

class OrderEntity {
  final String id;
  final String userId;
  final List<OrderItemEntity> items;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double totalAmount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final PaymentMethod paymentMethod;
  final Map<String, dynamic> shippingAddress;
  final String? khqrString;
  final String? khqrMd5;
  final String deliveryType;
  final String? notes;
  final DateTime? paidAt;
  final DateTime createdAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    this.shippingFee = 1.5,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.unpaid,
    required this.paymentMethod,
    required this.shippingAddress,
    this.khqrString,
    this.khqrMd5,
    this.deliveryType = 'delivery',
    this.notes,
    this.paidAt,
    required this.createdAt,
  });

  static OrderStatus parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'preparing':
        return OrderStatus.preparing;
      case 'processing':
        return OrderStatus.processing;
      case 'delivering':
        return OrderStatus.delivering;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  static PaymentStatus parsePaymentStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.unpaid;
    }
  }

  static PaymentMethod parsePaymentMethod(String? method) {
    switch (method?.toLowerCase()) {
      case 'cod':
        return PaymentMethod.cod;
      case 'card':
        return PaymentMethod.card;
      default:
        return PaymentMethod.khqr;
    }
  }

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems.map((e) => OrderItemEntity.fromJson(e as Map<String, dynamic>)).toList();

    return OrderEntity(
      id: json['id']?.toString() ?? json['order_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      items: itemsList,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shipping_fee'] ?? json['delivery_fee'] as num?)?.toDouble() ?? 0.00,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: parseStatus(json['status']?.toString()),
      paymentStatus: parsePaymentStatus(json['payment_status']?.toString()),
      paymentMethod: parsePaymentMethod(json['payment_method']?.toString()),
      shippingAddress: (json['shipping_address'] as Map<String, dynamic>?) ?? {},
      khqrString: json['khqr_string']?.toString(),
      khqrMd5: json['khqr_md5']?.toString(),
      deliveryType: json['delivery_type']?.toString() ?? 'delivery',
      notes: json['notes']?.toString(),
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at'].toString()) : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'discount': discount,
        'shipping_fee': shippingFee,
        'total_amount': totalAmount,
        'status': status.name,
        'payment_status': paymentStatus.name,
        'payment_method': paymentMethod.name,
        'shipping_address': shippingAddress,
        'khqr_string': khqrString,
        'khqr_md5': khqrMd5,
        'delivery_type': deliveryType,
        'notes': notes,
        'paid_at': paidAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  String get statusDisplay {
    switch (status) {
      case OrderStatus.pending:
        return 'រង់ចាំការបញ្ជាក់ (Pending)';
      case OrderStatus.preparing:
      case OrderStatus.processing:
        return 'ផ្ទះបាយកំពុងចម្អិន (Preparing)';
      case OrderStatus.delivering:
      case OrderStatus.shipped:
        return 'កំពុងដឹកជញ្ជូន (Out for Delivery)';
      case OrderStatus.delivered:
        return 'បានប្រគល់ជូនជោគជ័យ (Delivered)';
      case OrderStatus.cancelled:
        return 'បានលុបចោល (Cancelled)';
    }
  }

  String get paymentMethodDisplay {
    switch (paymentMethod) {
      case PaymentMethod.khqr:
        return 'Bakong KHQR (ABA / ACLEDA / Wing)';
      case PaymentMethod.cod:
        return 'ទូទាត់ប្រាក់ពេលទំនិញមកដល់ (Cash on Delivery)';
      case PaymentMethod.card:
        return 'កាតធនាគារ (Credit/Debit Card)';
    }
  }

  OrderEntity copyWith({
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? khqrString,
    String? khqrMd5,
    DateTime? paidAt,
  }) {
    return OrderEntity(
      id: id,
      userId: userId,
      items: items,
      subtotal: subtotal,
      discount: discount,
      shippingFee: shippingFee,
      totalAmount: totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod,
      shippingAddress: shippingAddress,
      khqrString: khqrString ?? this.khqrString,
      khqrMd5: khqrMd5 ?? this.khqrMd5,
      deliveryType: deliveryType,
      notes: notes,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt,
    );
  }
}
