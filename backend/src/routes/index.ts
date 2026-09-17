import { Router } from 'express';
import authRoutes from './auth.routes';
import locationRoutes from './location.routes';
import complaintRoutes from './complaint.routes';
import bannerRoutes from './banner.routes';
import mlaContactRoutes from './mla-contact.routes';
import systemRoutes from './system-setting.routes';
import broadcastRoutes from './broadcast.routes';
import cadreRoutes from './cadre.routes';

const router = Router();

// Health Check route
router.get('/health', (req, res) => {
  res.status(200).json({
    status: 'online',
    timestamp: new Date().toISOString(),
    service: 'TVK Backend API',
  });
});

// Mount Auth routes under /api/v1/auth
router.use('/auth', authRoutes);

// Mount Location / Master data routes under /api/v1/locations
router.use('/locations', locationRoutes);

// Mount Complaint routes under /api/v1/complaints
router.use('/complaints', complaintRoutes);

// Mount Banner routes under /api/v1/banners
router.use('/banners', bannerRoutes);

// Mount MLA Contact routes under /api/v1/mla-contact
router.use('/mla-contact', mlaContactRoutes);

// Mount System Settings routes under /api/v1/system
router.use('/system', systemRoutes);

// Mount Broadcast Alert routes under /api/v1/broadcasts
router.use('/broadcasts', broadcastRoutes);

// Mount Cadre routes under /api/v1/cadres
router.use('/cadres', cadreRoutes);

export default router;


