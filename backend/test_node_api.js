import http from 'http';
import { URL } from 'url';

const BASE_URL = 'http://127.0.0.1:5000';

function request(path, options = {}) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const reqOptions = {
      method: options.method || 'GET',
      headers: options.headers || {},
    };

    const req = http.request(url, reqOptions, (res) => {
      let body = '';
      res.on('data', (chunk) => (body += chunk));
      res.on('end', () => {
        let json;
        try {
          json = JSON.parse(body);
        } catch (e) {
          json = body;
        }
        resolve({
          statusCode: res.statusCode,
          headers: res.headers,
          data: json,
        });
      });
    });

    req.on('error', reject);

    if (options.body) {
      req.write(typeof options.body === 'string' ? options.body : JSON.stringify(options.body));
    }
    req.end();
  });
}

async function runTests() {
  console.log('🚀 Starting Full Node.js API Verification...');
  let passed = 0;
  let total = 0;

  async function test(name, fn) {
    total++;
    try {
      await fn();
      console.log(`  ✅ [PASS] ${name}`);
      passed++;
    } catch (err) {
      console.error(`  ❌ [FAIL] ${name}:`, err.message);
    }
  }

  // 1. Root status
  await test('GET / (Server Root Status)', async () => {
    const res = await request('/');
    if (res.statusCode !== 200 || !res.data.status) {
      throw new Error(`Expected 200 OK, got ${res.statusCode}: ${JSON.stringify(res.data)}`);
    }
  });

  // 2. Settings
  await test('GET /api/v1/settings', async () => {
    const res = await request('/api/v1/settings');
    if (res.statusCode !== 200 || res.data?.data?.khr_rate !== 4100) {
      throw new Error(`Expected khr_rate 4100, got: ${JSON.stringify(res.data)}`);
    }
  });

  // 3. Categories
  let sampleCategory = null;
  await test('GET /api/v1/categories', async () => {
    const res = await request('/api/v1/categories');
    if (res.statusCode !== 200 || !Array.isArray(res.data.data) || res.data.data.length === 0) {
      throw new Error(`Expected categories array, got: ${res.statusCode}`);
    }
    sampleCategory = res.data.data[0];
    console.log(`     Found ${res.data.data.length} categories (First: ${sampleCategory.name_en || sampleCategory.name_km || sampleCategory.id})`);
  });

  // 4. Products list
  let sampleProduct = null;
  await test('GET /api/v1/products', async () => {
    const res = await request('/api/v1/products?limit=10');
    if (res.statusCode !== 200 || !Array.isArray(res.data.data) || res.data.data.length === 0) {
      throw new Error(`Expected products array, got: ${res.statusCode}`);
    }
    sampleProduct = res.data.data[0];
    console.log(`     Found total ${res.data.meta.total} dishes (Sample: ${sampleProduct.name_en || sampleProduct.name} - $${sampleProduct.price})`);
  });

  // 5. Product by ID
  await test('GET /api/v1/products/:id', async () => {
    const res = await request(`/api/v1/products/${sampleProduct.id}`);
    if (res.statusCode !== 200 || !res.data.data || res.data.data.id !== sampleProduct.id) {
      throw new Error(`Expected product ${sampleProduct.id}, got: ${res.statusCode}`);
    }
  });

  // 6. Promo Code Validation
  await test('POST /api/v1/promos/validate (PHUM10)', async () => {
    const res = await request('/api/v1/promos/validate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: { code: 'PHUM10', subtotal: 25.0 },
    });
    if (res.statusCode !== 200 || !res.data.success || res.data.data.discount !== 2.5) {
      throw new Error(`Expected $2.50 discount, got: ${JSON.stringify(res.data)}`);
    }
  });

  // 7. Create Order
  let createdOrder = null;
  await test('POST /api/v1/orders (Create Order)', async () => {
    const res = await request('/api/v1/orders', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: {
        customer_name: 'Customer',
        phone: '012999888',
        shipping_address: {
          name: 'Customer',
          phone: '012999888',
          city: 'Phnom Penh',
          street: 'St 271',
        },
        payment_method: 'khqr',
        delivery_type: 'delivery',
        promo_code: 'PHUM10',
        items: [
          {
            product_id: sampleProduct.id,
            quantity: 2,
          },
        ],
      },
    });
    if (res.statusCode !== 201 || !res.data.data || !res.data.data.id) {
      throw new Error(`Expected created order, got: ${res.statusCode} ${JSON.stringify(res.data)}`);
    }
    createdOrder = res.data.data;
    console.log(`     Order created: #${createdOrder.id} (Total: $${createdOrder.total_amount})`);
  });

  // 8. Generate Real Bakong KHQR
  let khqrData = null;
  await test('POST /api/v1/payments/khqr/generate', async () => {
    const res = await request('/api/v1/payments/khqr/generate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: {
        order_id: createdOrder.id,
        currency: 'USD',
      },
    });
    if (res.statusCode !== 200 || !res.data.data || !res.data.data.qr || !res.data.data.md5) {
      throw new Error(`Expected real KHQR string & MD5, got: ${res.statusCode} ${JSON.stringify(res.data)}`);
    }
    khqrData = res.data.data;
    console.log(`     Bakong KHQR EMVCo generated! Length: ${khqrData.qr.length}, MD5: ${khqrData.md5}`);
  });

  // 9. Verify KHQR (Initially Pending)
  await test('POST /api/v1/payments/khqr/verify (Initially Pending)', async () => {
    const res = await request('/api/v1/payments/khqr/verify', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: {
        order_id: createdOrder.id,
        md5: khqrData.md5,
      },
    });
    if (res.statusCode !== 200 || res.data.data.is_paid === true) {
      throw new Error(`Expected is_paid=false initially, got: ${JSON.stringify(res.data)}`);
    }
  });

  // 10. Simulate KHQR Payment
  await test('POST /api/v1/payments/khqr/simulate (Simulate Successful Payment)', async () => {
    const res = await request('/api/v1/payments/khqr/simulate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: {
        order_id: createdOrder.id,
        md5: khqrData.md5,
      },
    });
    if (res.statusCode !== 200 || !res.data.success || res.data.data.is_paid !== true) {
      throw new Error(`Expected simulate success, got: ${JSON.stringify(res.data)}`);
    }
  });

  // 11. Verify KHQR (Now Confirmed Paid)
  await test('POST /api/v1/payments/khqr/verify (Now Confirmed Paid)', async () => {
    const res = await request('/api/v1/payments/khqr/verify', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: {
        order_id: createdOrder.id,
        md5: khqrData.md5,
      },
    });
    if (res.statusCode !== 200 || res.data.data.is_paid !== true || res.data.data.order?.status !== 'preparing') {
      throw new Error(`Expected is_paid=true and status=preparing, got: ${JSON.stringify(res.data)}`);
    }
  });

  // 12. Static Image Serving
  await test('GET /images/foods/ (Static Image Serving)', async () => {
    const imageFilename = sampleProduct.image.replace('/images/foods/', '');
    const res = await request(`/images/foods/${imageFilename}`);
    if (res.statusCode !== 200) {
      throw new Error(`Expected image to return 200 OK, got: ${res.statusCode}`);
    }
    console.log(`     Static food image ${imageFilename} served successfully (${res.data.length} bytes)`);
  });

  console.log(`\n========================================`);
  console.log(`🎉 TEST RESULTS: ${passed}/${total} PASSED!`);
  console.log(`========================================\n`);

  if (passed !== total) {
    process.exit(1);
  }
}

runTests().catch((err) => {
  console.error('Fatal test runner error:', err);
  process.exit(1);
});
