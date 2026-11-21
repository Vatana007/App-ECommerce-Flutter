import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import mongoose from 'mongoose';
import { BakongKHQR, IndividualInfo, khqrData } from 'bakong-khqr';
import { Dish } from '../models/Dish.js';
import { Order } from '../models/Order.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// In-memory simulation cache for development testing without spending real money
const simulatedTransactions = new Set();
// In-memory order storage (supplements MongoDB when offline or disconnected)
const inMemoryOrders = new Map();

// Load authentic initial dishes
const dishesJsonPath = path.resolve(__dirname, '../data/dishes.json');
let fallbackDishes = [];
try {
  if (fs.existsSync(dishesJsonPath)) {
    fallbackDishes = JSON.parse(fs.readFileSync(dishesJsonPath, 'utf8'));
  }
} catch (e) {
  console.warn('[v1Controller] Warning loading dishes.json:', e.message);
}

// 14 Authentic Categories with Khmer & English names and dish counts
export const CATEGORIES = [
  { id: 'specials', name_km: 'មុខម្ហូបពិសេសប្រចាំហាង', name_en: 'Chef Specials', icon: 'sparkles', sort_order: 1 },
  { id: 'duck-goose', name_km: 'ទា និង ក្ងាន', name_en: 'Duck & Poultry', icon: 'utensils', sort_order: 2 },
  { id: 'chicken', name_km: 'មាន់ស្រែ និង មាន់បីសាសន៍', name_en: 'Country Chicken', icon: 'drumstick', sort_order: 3 },
  { id: 'pork', name_km: 'មុខម្ហូបសាច់ជ្រូក', name_en: 'Pork Delicacies', icon: 'utensils', sort_order: 4 },
  { id: 'beef', name_km: 'មុខម្ហូបសាច់គោ', name_en: 'Beef Specialties', icon: 'flame', sort_order: 5 },
  { id: 'eel-frog', name_km: 'អន្ទង់ និង កង្កែប', name_en: 'Eel & Frog Legs', icon: 'fish', sort_order: 6 },
  { id: 'fish-crab', name_km: 'ត្រីទន្លេ និង ក្តាម', name_en: 'River Fish & Crab', icon: 'fish', sort_order: 7 },
  { id: 'seafood', name_km: 'គ្រឿងសមុទ្រស្រស់ៗ', name_en: 'Fresh Seafood', icon: 'shrimp', sort_order: 8 },
  { id: 'soups', name_km: 'សម្ល និង ស៊ុបក្ដៅៗ', name_en: 'Traditional Soups', icon: 'soup', sort_order: 9 },
  { id: 'beverages', name_km: 'ភេសជ្ជៈ និង ទឹកផ្លែឈើ', name_en: 'Refreshing Beverages', icon: 'coffee', sort_order: 10 },
  { id: 'beer-wine', name_km: 'ស្រាបៀរ និង គ្រឿងក្លែម', name_en: 'Beer & Drinks', icon: 'wine', sort_order: 11 },
  { id: 'snacks-bari', name_km: 'គ្រឿងក្លែមស្រស់ៗ', name_en: 'Appetizers & Snacks', icon: 'cookie', sort_order: 12 },
  { id: 'kids-menu', name_km: 'មុខម្ហូបកុមារ', name_en: 'Kids Menu', icon: 'smile', sort_order: 13 },
  { id: 'other-foods', name_km: 'មុខម្ហូបផ្សេងៗ', name_en: 'Other Specialties', icon: 'more', sort_order: 14 }
];

export const PROMOS = [
  { code: 'PHUM10', discount: 10, discount_type: 'percentage', description: 'បញ្ចុះតម្លៃ 10% សម្រាប់ការកុម្ម៉ង់ដំបូង', active: true },
  { code: 'KHMER20', discount: 20, discount_type: 'percentage', description: 'បញ្ចុះតម្លៃ 20% សម្រាប់ការកុម្ម៉ង់លើសពី $20', active: true },
  { code: 'FREESHIP', discount: 1.50, discount_type: 'fixed', description: 'មិនគិតថ្លៃសេវាដឹកជញ្ជូន $1.50', active: true }
];

export const SETTINGS = {
  is_open: true,
  standard_delivery_fee: 0.00,
  free_delivery_threshold: 0.00,
  khr_rate: 4100,
  announcement_km: '🔥 ប្រូម៉ូសិនពិសេស៖ បញ្ចុះតម្លៃ ១០% សម្រាប់ការកុម្ម៉ង់ដំបូងដោយប្រើកូដ PHUM10!',
  announcement_en: '🔥 Special Promo: Enjoy 10% OFF your first delivery order with code PHUM10!',
  store_name: 'ភោជនីយដ្ឋាន ភូមិយើង (Phum Yeung Restaurant)',
  store_phone: '012 345 678 / 098 765 432',
  store_address: 'ផ្លូវ 271 កែងផ្លូវ 371 សង្កាត់បឹងទំពុន ខណ្ឌមានជ័យ រាជធានីភ្នំពេញ'
};

function formatProduct(dish) {
  const id = dish.dishId || (dish._id ? String(dish._id) : dish.id);
  const name_km = dish.name_km || 'ម្ហូបខ្មែរ';
  const name_en = dish.name_en || '';
  const fullName = name_en ? `${name_km} (${name_en})` : name_km;
  const image = dish.image || '/images/foods/cmt1krpbt00180aj7e18d2xp6.jpg';

  return {
    id,
    name: fullName,
    name_km,
    name_en,
    description: dish.desc_km || dish.desc_en || 'ម្ហូបឆ្ងាញ់ប្រចាំហាងភូមិយើង រសជាតិដើមបែបខ្មែរពិតៗ។',
    desc_km: dish.desc_km || '',
    desc_en: dish.desc_en || '',
    price: Number(dish.price) || 4.50,
    spice_level: dish.spice_level || 'mild',
    featured: Boolean(dish.featured),
    stock: 50,
    images: [image],
    image,
    category_id: dish.category || 'specials',
    rating: Number(dish.rating) || 5.0,
    review_count: Number(dish.reviews_count) || 15
  };
}

function formatOrder(order) {
  return {
    id: order.orderId || order.order_id || order.id,
    order_id: order.orderId || order.order_id || order.id,
    user_id: order.customer_id || order.user_id || 'guest',
    customer_name: order.customerName || order.customer_name || 'Customer',
    customer_phone: order.phone || order.customer_phone || '',
    delivery_type: order.orderType || order.delivery_type || 'delivery',
    items: (order.items || []).map((i) => ({
      product_id: i.dishId || i.product_id,
      name: i.name_km ? `${i.name_km} (${i.name_en || ''})` : (i.name || 'Food Item'),
      price: Number(i.price) || 0,
      image: i.image || null,
      quantity: Number(i.quantity) || 1,
      subtotal: Number(i.subtotal) || (Number(i.price) * Number(i.quantity))
    })),
    subtotal: Number(order.subtotal) || 0,
    delivery_fee: Number(order.deliveryFee ?? order.delivery_fee ?? 0.00),
    shipping_fee: Number(order.deliveryFee ?? order.shipping_fee ?? 0.00),
    discount: Number(order.discount) || 0,
    total_amount: Number(order.total ?? order.total_amount) || 0,
    currency: order.currency || 'USD',
    status: order.status || 'pending',
    payment_status: order.payment_status || (order.paymentMethod === 'cod' ? 'unpaid' : 'paid'),
    payment_method: order.paymentMethod || order.payment_method || 'khqr',
    khqr_string: order.khqr_string || null,
    khqr_md5: order.khqr_md5 || null,
    paid_at: order.paid_at || null,
    shipping_address: order.shipping_address || {
      name: order.customerName || '',
      phone: order.phone || '',
      city: 'Phnom Penh',
      district: order.district || 'Khan Boeng Keng Kang (BKK)',
      street: order.address || '',
      notes: order.notes || ''
    },
    created_at: order.createdAt || order.created_at || new Date().toISOString()
  };
}

// Generate real Bakong KHQR EMVCo string and MD5 hash
export function generateBakongPayload(amount, currency = 'USD', billNumber = `PY-ORD-${Date.now().toString().slice(-4)}`) {
  const isUSD = String(currency).toUpperCase() === 'USD';
  const currencyCode = isUSD ? khqrData.currency.usd : khqrData.currency.khr;

  const formattedAmount = isUSD
    ? parseFloat(Number(amount).toFixed(2))
    : Math.round(Number(amount));

  const bakongAccountID = process.env.BAKONG_ACCOUNT_ID || 'vatana@bkrt';
  const merchantName = process.env.BAKONG_MERCHANT_NAME || 'VUTH VATANA';
  const merchantCity = process.env.BAKONG_MERCHANT_CITY || 'Phnom Penh';

  const optionalData = {
    currency: currencyCode,
    amount: formattedAmount,
    expirationTimestamp: Date.now() + 15 * 60 * 1000,
    billNumber: String(billNumber).slice(0, 25),
    storeLabel: 'Phum Yeung Restaurant',
    terminalLabel: 'Cashier 01'
  };

  const individualInfo = new IndividualInfo(
    bakongAccountID,
    merchantName,
    merchantCity,
    optionalData
  );

  const khqr = new BakongKHQR();
  const result = khqr.generateIndividual(individualInfo);

  if (result && result.status?.code === 0 && result.data?.qr) {
    return {
      qr: result.data.qr,
      qr_string: result.data.qr,
      md5: result.data.md5,
      amount: formattedAmount,
      currency: isUSD ? 'USD' : 'KHR',
      bakong_account: bakongAccountID,
      merchant_name: merchantName,
      bill_number: billNumber
    };
  }

  // Fallback
  const fallbackQr = `00020101021229150011${bakongAccountID}520459995303${isUSD ? '840' : '116'}5405${formattedAmount}5802KH5911${merchantName}6010${merchantCity}62250107${billNumber}0310Phum Yeung6304`;
  return {
    qr: fallbackQr,
    qr_string: fallbackQr,
    md5: `md5_${Date.now()}`,
    amount: formattedAmount,
    currency: isUSD ? 'USD' : 'KHR',
    bill_number: billNumber
  };
}

// 1. GET /api/v1/categories
export const getCategories = async (req, res) => {
  try {
    const list = CATEGORIES.map((cat) => {
      const count = fallbackDishes.filter((d) => d.category === cat.id).length;
      return {
        ...cat,
        products_count: count
      };
    });
    res.json({ success: true, message: 'Categories fetched successfully', data: list });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 2. GET /api/v1/products
export const getProducts = async (req, res) => {
  try {
    const { category_id, search, featured, limit = 50, page = 1 } = req.query;

    let pool = fallbackDishes;

    // If MongoDB is connected and ready, query MongoDB
    if (mongoose.connection.readyState === 1) {
      try {
        const query = {};
        if (category_id && category_id !== 'all') query.category = category_id;
        if (featured !== undefined) query.featured = String(featured) === 'true';
        if (search) {
          query.$or = [
            { name_km: { $regex: search, $options: 'i' } },
            { name_en: { $regex: search, $options: 'i' } },
            { desc_km: { $regex: search, $options: 'i' } }
          ];
        }
        const dbDishes = await Dish.find(query).limit(Number(limit));
        if (dbDishes && dbDishes.length > 0) {
          const formatted = dbDishes.map(formatProduct);
          return res.json({
            success: true,
            message: 'Products fetched successfully',
            data: formatted,
            meta: {
              total: formatted.length,
              current_page: Number(page),
              last_page: 1,
              next_cursor: null
            }
          });
        }
      } catch (dbErr) {
        // Fall through to in-memory fallback
      }
    }

    // In-memory filtering
    if (category_id && category_id !== 'all') {
      pool = pool.filter((d) => d.category === category_id);
    }
    if (featured !== undefined) {
      const isFeat = String(featured) === 'true';
      pool = pool.filter((d) => Boolean(d.featured) === isFeat);
    }
    if (search) {
      const q = search.toLowerCase();
      pool = pool.filter(
        (d) =>
          (d.name_km && d.name_km.toLowerCase().includes(q)) ||
          (d.name_en && d.name_en.toLowerCase().includes(q)) ||
          (d.desc_km && d.desc_km.toLowerCase().includes(q))
      );
    }

    const start = (Number(page) - 1) * Number(limit);
    const paginated = pool.slice(start, start + Number(limit));
    const formatted = paginated.map(formatProduct);

    res.json({
      success: true,
      message: 'Products fetched successfully',
      data: formatted,
      meta: {
        total: pool.length,
        current_page: Number(page),
        last_page: Math.ceil(pool.length / Number(limit)),
        next_cursor: start + Number(limit) < pool.length ? String(Number(page) + 1) : null
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 3. GET /api/v1/products/:id
export const getProductById = async (req, res) => {
  try {
    const id = req.params.id;
    let found = null;

    if (mongoose.connection.readyState === 1) {
      try {
        found = await Dish.findOne({
          $or: [{ dishId: id }, ...(mongoose.Types.ObjectId.isValid(id) ? [{ _id: id }] : [])]
        });
      } catch (_) {}
    }

    if (!found) {
      found = fallbackDishes.find((d) => d.dishId === id || d.id === id);
    }

    if (!found) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    res.json({
      success: true,
      message: 'Product details fetched successfully',
      data: formatProduct(found)
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 4. GET /api/v1/orders
export const getOrders = async (req, res) => {
  try {
    const list = Array.from(inMemoryOrders.values()).map(formatOrder);
    res.json({ success: true, message: 'Orders fetched successfully', data: list });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 5. GET /api/v1/orders/:id
export const getOrderById = async (req, res) => {
  try {
    const id = req.params.id;
    const order = inMemoryOrders.get(id);
    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }
    res.json({ success: true, message: 'Order fetched successfully', data: formatOrder(order) });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 6. POST /api/v1/orders
export const createOrder = async (req, res) => {
  try {
    const { items, shipping_address = {}, payment_method = 'khqr', delivery_type = 'delivery', promo_code } = req.body;

    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(422).json({ success: false, message: 'Items array is required' });
    }

    let subtotal = 0;
    const orderItems = [];

    for (const item of items) {
      const prodId = item.product_id || item.dishId;
      const qty = Number(item.quantity) || 1;
      const found = fallbackDishes.find((d) => d.dishId === prodId || d.id === prodId);

      const price = found ? Number(found.price) : 4.50;
      const itemSubtotal = price * qty;
      subtotal += itemSubtotal;

      orderItems.push({
        dishId: prodId,
        product_id: prodId,
        name: found ? `${found.name_km} (${found.name_en})` : 'Khmer Dish',
        name_km: found?.name_km || 'ម្ហូបខ្មែរ',
        name_en: found?.name_en || 'Khmer Dish',
        price,
        image: found?.image || '/images/foods/cmt1krpbt00180aj7e18d2xp6.jpg',
        quantity: qty,
        subtotal: itemSubtotal
      });
    }

    // Delivery fee
    const deliveryFee = delivery_type === 'pickup' || subtotal >= SETTINGS.free_delivery_threshold ? 0.0 : SETTINGS.standard_delivery_fee;

    // Promo calculation
    let discount = 0.0;
    if (promo_code) {
      const promo = PROMOS.find((p) => p.code === String(promo_code).trim().toUpperCase() && p.active);
      if (promo) {
        if (promo.discount_type === 'percentage') {
          discount = parseFloat(((subtotal * promo.discount) / 100).toFixed(2));
        } else {
          discount = Number(promo.discount);
        }
      }
    }

    const totalAmount = Math.max(0, parseFloat((subtotal - discount + deliveryFee).toFixed(2)));
    const orderId = `PY-ORD-${Math.floor(1000 + Math.random() * 9000)}`;

    // Generate real Bakong KHQR
    let khqrPayload = null;
    if (payment_method === 'khqr' && totalAmount > 0) {
      khqrPayload = generateBakongPayload(totalAmount, 'USD', orderId);
    }

    const orderRecord = {
      id: orderId,
      orderId,
      order_id: orderId,
      customer_id: req.body.user_id || 'guest',
      customerName: shipping_address.name || 'Customer',
      phone: shipping_address.phone || '012999888',
      delivery_type,
      orderType: delivery_type,
      shipping_address,
      items: orderItems,
      subtotal,
      deliveryFee,
      shipping_fee: deliveryFee,
      discount,
      total: totalAmount,
      total_amount: totalAmount,
      currency: 'USD',
      status: 'pending',
      payment_method,
      paymentMethod: payment_method,
      payment_status: 'unpaid',
      khqr_string: khqrPayload?.qr || null,
      khqr_md5: khqrPayload?.md5 || null,
      createdAt: new Date().toISOString()
    };

    inMemoryOrders.set(orderId, orderRecord);

    res.status(201).json({
      success: true,
      message: 'Order placed successfully',
      data: formatOrder(orderRecord)
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 7. POST /api/v1/payments/khqr/generate
export const generateKhqr = async (req, res) => {
  try {
    const { order_id, currency = 'USD' } = req.body;
    const order = inMemoryOrders.get(order_id);

    const amount = order ? order.total_amount : 5.00;
    const payload = generateBakongPayload(amount, currency, order_id || `PY-${Date.now().toString().slice(-4)}`);

    if (order) {
      order.khqr_string = payload.qr;
      order.khqr_md5 = payload.md5;
    }

    res.json({
      success: true,
      message: 'Bakong KHQR generated successfully',
      data: payload
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 8. POST /api/v1/payments/khqr/verify
export const verifyKhqr = async (req, res) => {
  try {
    const { order_id, md5 } = req.body;

    let targetOrder = null;
    let targetMd5 = md5;

    if (order_id) {
      targetOrder = inMemoryOrders.get(order_id);
      if (targetOrder && !targetMd5) {
        targetMd5 = targetOrder.khqr_md5;
      }
    }

    // 1. Check if simulated
    if (targetMd5 && simulatedTransactions.has(targetMd5)) {
      if (targetOrder) {
        targetOrder.payment_status = 'paid';
        targetOrder.status = 'preparing';
        targetOrder.paid_at = new Date().toISOString();
      }
      return res.json({
        success: true,
        message: 'Bakong KHQR payment confirmed (Simulated)!',
        data: {
          is_paid: true,
          response_code: 0,
          response_message: 'Success (Simulated)',
          order: targetOrder ? formatOrder(targetOrder) : null,
          verified_at: new Date().toISOString()
        }
      });
    }

    // 2. Query NBC Bakong API if real token is provided
    const DEFAULT_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7ImlkIjoiNWNhM2I0ZmQwMDMyNDY3YiJ9LCJpYXQiOjE3OTAwNjQ1NTQsImV4cCI6MTc5Nzg0MDU1NH0.yoIdI6hSVc-bY-tqcjvlTEl9BZRLKc-YBTayr15XPn8';
    const token = process.env.BAKONG_TOKEN || DEFAULT_TOKEN;

    if (token && targetMd5) {
      try {
        const response = await fetch('https://api-bakong.nbc.gov.kh/v1/check_transaction_by_md5', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${token}`
          },
          body: JSON.stringify({ md5: targetMd5 })
        });
        const data = await response.json();
        const isPaid = data.responseCode === 0 && Boolean(data.data?.hash);

        if (isPaid && targetOrder) {
          targetOrder.payment_status = 'paid';
          targetOrder.status = 'preparing';
          targetOrder.paid_at = new Date().toISOString();
        }

        return res.json({
          success: isPaid,
          message: isPaid ? 'Payment confirmed!' : 'Payment pending',
          data: {
            is_paid: isPaid,
            response_code: data.responseCode,
            response_message: data.responseMessage,
            order: targetOrder ? formatOrder(targetOrder) : null,
            verified_at: new Date().toISOString()
          }
        });
      } catch (apiErr) {
        // Fallback to unconfirmed
      }
    }

    res.json({
      success: false,
      message: 'Payment pending',
      data: {
        is_paid: false,
        response_code: 1,
        response_message: 'Awaiting transaction',
        order: targetOrder ? formatOrder(targetOrder) : null,
        verified_at: new Date().toISOString()
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 9. POST /api/v1/payments/khqr/simulate
export const simulateKhqr = async (req, res) => {
  try {
    const { order_id, md5 } = req.body;
    let targetMd5 = md5;
    let targetOrder = null;

    if (order_id) {
      targetOrder = inMemoryOrders.get(order_id);
      if (targetOrder) {
        targetMd5 = targetOrder.khqr_md5 || `sim_${order_id}`;
        targetOrder.khqr_md5 = targetMd5;
        targetOrder.payment_status = 'paid';
        targetOrder.status = 'preparing';
        targetOrder.paid_at = new Date().toISOString();
      }
    }

    if (!targetMd5) {
      targetMd5 = `sim_${Date.now()}`;
    }

    simulatedTransactions.add(targetMd5);

    res.json({
      success: true,
      message: 'Payment simulated successfully as PAID for development testing',
      data: {
        is_paid: true,
        md5: targetMd5,
        order: targetOrder ? formatOrder(targetOrder) : null,
        simulated: true
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 10. POST /api/v1/promos/validate
export const validatePromo = async (req, res) => {
  try {
    const code = String(req.body.code || '').trim().toUpperCase();
    const subtotal = Number(req.body.subtotal) || 0;

    const promo = PROMOS.find((p) => p.code === code && p.active);

    if (!promo) {
      return res.status(404).json({
        success: false,
        message: 'លេខកូដបញ្ចុះតម្លៃមិនត្រឹមត្រូវ ឬផុតកំណត់ហើយ (Invalid or expired promo code)'
      });
    }

    let discount = 0.0;
    if (promo.discount_type === 'percentage') {
      discount = parseFloat(((subtotal * promo.discount) / 100).toFixed(2));
    } else {
      discount = Math.min(subtotal, promo.discount);
    }

    res.json({
      success: true,
      message: 'បានអនុវត្តកូដបញ្ចុះតម្លៃដោយជោគជ័យ (Promo applied)',
      data: {
        code: promo.code,
        discount,
        discount_type: promo.discount_type,
        rate: promo.discount,
        description: promo.description
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 11. GET /api/v1/settings
export const getSettings = async (req, res) => {
  try {
    res.json({
      success: true,
      message: 'Store settings fetched successfully',
      data: SETTINGS
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 12. POST /api/v1/auth/login
export const adminLogin = async (req, res) => {
  try {
    const { email, password } = req.body;
    if ((email === 'admin@phumyeung.com' || email === 'admin') && (password === 'admin123' || password === '123456')) {
      return res.json({
        success: true,
        message: 'Admin logged in successfully',
        data: {
          token: `admin_token_${Date.now()}`,
          user: {
            id: 'admin_1',
            name: 'Phum Yeung Admin',
            email: 'admin@phumyeung.com',
            role: 'admin'
          }
        }
      });
    }

    if (mongoose.connection.readyState === 1) {
      try {
        const user = await User.findOne({ email });
        if (user && (user.password === password || (await user.comparePassword?.(password)))) {
          return res.json({
            success: true,
            message: 'User logged in successfully',
            data: {
              token: `jwt_token_${Date.now()}`,
              user: {
                id: user._id,
                name: user.name,
                email: user.email,
                role: user.role || 'customer'
              }
            }
          });
        }
      } catch (_) {}
    }

    res.status(401).json({
      success: false,
      message: 'អុីមែល ឬពាក្យសម្ងាត់មិនត្រឹមត្រូវទេ (Invalid email or password)'
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 13. PUT /api/v1/orders/:id/status
export const updateOrderStatus = async (req, res) => {
  try {
    const id = req.params.id;
    const { status, payment_status } = req.body;
    const order = inMemoryOrders.get(id);

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    if (status) order.status = status;
    if (payment_status) order.payment_status = payment_status;
    if (status === 'delivered') order.delivered_at = new Date().toISOString();

    res.json({
      success: true,
      message: `Order #${id} status updated to ${status}`,
      data: formatOrder(order)
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 14. PUT /api/v1/settings
export const updateSettings = async (req, res) => {
  try {
    const { is_open, standard_delivery_fee, khr_rate, announcement_km, announcement_en } = req.body;
    if (is_open !== undefined) SETTINGS.is_open = Boolean(is_open);
    if (standard_delivery_fee !== undefined) SETTINGS.standard_delivery_fee = Number(standard_delivery_fee);
    if (khr_rate !== undefined) SETTINGS.khr_rate = Number(khr_rate);
    if (announcement_km !== undefined) SETTINGS.announcement_km = String(announcement_km);
    if (announcement_en !== undefined) SETTINGS.announcement_en = String(announcement_en);

    res.json({
      success: true,
      message: 'Store settings updated successfully',
      data: SETTINGS
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 15. GET /api/v1/admin/dashboard
export const getDashboardStats = async (req, res) => {
  try {
    const ordersList = Array.from(inMemoryOrders.values());
    const totalOrders = ordersList.length;
    const totalRevenue = ordersList
      .filter((o) => o.payment_status === 'paid' || o.status === 'delivered')
      .reduce((sum, o) => sum + (Number(o.total || o.total_amount) || 0), 0);
    const pendingOrders = ordersList.filter((o) => o.status === 'pending' || o.status === 'preparing').length;
    const totalDishes = fallbackDishes.length;

    res.json({
      success: true,
      message: 'Dashboard statistics fetched successfully',
      data: {
        total_revenue: parseFloat(totalRevenue.toFixed(2)),
        total_orders: totalOrders,
        pending_orders: pendingOrders,
        total_dishes: totalDishes,
        is_open: SETTINGS.is_open,
        active_promos: PROMOS.filter((p) => p.active).length
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 16. PUT /api/v1/products/:id
export const updateDish = async (req, res) => {
  try {
    const id = req.params.id;
    const { price, featured, spice_level, name_km, name_en } = req.body;
    const dish = fallbackDishes.find((d) => d.dishId === id || d.id === id);

    if (!dish) {
      return res.status(404).json({ success: false, message: 'Dish not found' });
    }

    if (price !== undefined) dish.price = Number(price);
    if (featured !== undefined) dish.featured = Boolean(featured);
    if (spice_level !== undefined) dish.spice_level = spice_level;
    if (name_km !== undefined) dish.name_km = name_km;
    if (name_en !== undefined) dish.name_en = name_en;

    res.json({
      success: true,
      message: 'Dish updated successfully',
      data: formatProduct(dish)
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
