import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import mongoose from 'mongoose';
import { connectDB } from './config/db.js';

// Route Imports
import dishRoutes from './routes/dishRoutes.js';
import orderRoutes from './routes/orderRoutes.js';
import promoRoutes from './routes/promoRoutes.js';
import settingRoutes from './routes/settingRoutes.js';
import authRoutes from './routes/authRoutes.js';
import paymentRoutes from './routes/paymentRoutes.js';
import v1Routes from './routes/v1Routes.js';

// Seed Models
import { User } from './models/User.js';
import { Setting } from './models/Setting.js';
import { serveFoodImage } from './controllers/dishController.js';

import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
dotenv.config({ path: path.resolve(__dirname, '.env') });
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Connect to MongoDB
connectDB().then(async (conn) => {
  if (conn && mongoose.connection.readyState === 1) {
    try {
      const adminExists = await User.findOne({ email: 'admin@phumyeung.com' });
      if (!adminExists) {
        await User.create({
          name: 'Phum Yeung Admin',
          email: 'admin@phumyeung.com',
          password: 'admin123',
          role: 'admin'
        });
        console.log('[Server] Default admin initialized: admin@phumyeung.com');
      }

      const settingExists = await Setting.findOne();
      if (!settingExists) {
        await Setting.create({
          isOpen: true,
          standardDeliveryFee: 0.00,
          freeDeliveryThreshold: 0.00,
          khrRate: 4100,
          announcement: {
            active: true,
            text_km: '🔥 ប្រូម៉ូសិនពិសេស៖ បញ្ចុះតម្លៃ ១០% សម្រាប់ការកុម្ម៉ង់ដំបូងដោយប្រើកូដ PHUM10!',
            text_en: '🔥 Special Promo: Enjoy 10% OFF your first delivery order with code PHUM10!'
          }
        });
      }
    } catch (e) {
      console.warn('[Server] Auto-seed check:', e.message);
    }
  }
});

// Middleware
const allowedOrigins = [
  'http://localhost:3000',
  'http://localhost:3001',
  'http://127.0.0.1:3000',
  'http://127.0.0.1:3001',
  process.env.CLIENT_URL,
  process.env.ADMIN_URL
].filter(Boolean);

app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    // Allow any localhost / 127.0.0.1 development port
    if (/^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin)) {
      return callback(null, true);
    }
    // Allow standard cloud deployments
    if (/\.(vercel\.app|workers\.dev|pages\.dev|onrender\.com)$/.test(origin)) {
      return callback(null, true);
    }
    return callback(null, true); // Permissive in dev mode for mobile emulator / web clients
  },
  credentials: true
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static media files (dishes, logos) directly from backend API
app.get('/images/foods/:filename', serveFoodImage);
app.use('/images', express.static(path.join(__dirname, 'public/images')));

// Root Endpoint
app.get('/', (req, res) => {
  res.json({
    status: 'OK',
    service: 'Phum Yeung Online Backend API',
    version: '1.0.0',
    documentation: '/api/v1'
  });
});

// Health Check API
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    service: 'Phum Yeung Online Backend API',
    database: mongoose.connection.readyState === 1 ? 'Connected' : 'In-Memory Fallback Active',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// Mount V1 API Routes (Full E-Commerce + Real Bakong KHQR for Flutter & Web)
app.use('/api/v1', v1Routes);

// Mount Legacy & Web App Routes
app.use('/api/dishes', dishRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/promos', promoRoutes);
app.use('/api/settings', settingRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/payments', paymentRoutes);

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('[API Error]', err.stack);
  res.status(err.statusCode || 500).json({
    success: false,
    message: err.message || 'Internal Server Error'
  });
});

// 404 Handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: `Endpoint ${req.originalUrl} not found`
  });
});

const server = app.listen(PORT, () => {
  console.log(`=============================================`);
  console.log(`🍲 Phum Yeung Online Node.js REST API Server`);
  console.log(`📡 Running on: http://localhost:${PORT}`);
  console.log(`🛡️ Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`=============================================`);
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`\n❌ Error: Port ${PORT} is already in use by another running process.`);
    console.error(`👉 Quick Fix for Windows (PowerShell):`);
    console.error(`   Stop-Process -Id (Get-NetTCPConnection -LocalPort ${PORT}).OwningProcess -Force\n`);
  } else {
    console.error('[Server Error]', err);
  }
  process.exit(1);
});
