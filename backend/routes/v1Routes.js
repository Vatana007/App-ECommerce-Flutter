import express from 'express';
import {
  getCategories,
  getProducts,
  getProductById,
  getOrders,
  getOrderById,
  createOrder,
  generateKhqr,
  verifyKhqr,
  simulateKhqr,
  validatePromo,
  getSettings,
  adminLogin,
  updateOrderStatus,
  updateSettings,
  getDashboardStats,
  updateDish
} from '../controllers/v1Controller.js';

const router = express.Router();

// Auth / Admin Login
router.post('/auth/login', adminLogin);

// Categories
router.get('/categories', getCategories);

// Products / Dishes
router.get('/products', getProducts);
router.get('/products/:id', getProductById);
router.put('/products/:id', updateDish);

// Orders
router.get('/orders', getOrders);
router.post('/orders', createOrder);
router.get('/orders/:id', getOrderById);
router.put('/orders/:id/status', updateOrderStatus);

// Admin Dashboard Stats
router.get('/admin/dashboard', getDashboardStats);

// Bakong KHQR
router.post('/payments/khqr/generate', generateKhqr);
router.post('/payments/khqr/verify', verifyKhqr);
router.post('/payments/khqr/simulate', simulateKhqr);

// Promos
router.post('/promos/validate', validatePromo);

// Settings
router.get('/settings', getSettings);
router.put('/settings', updateSettings);

export default router;
