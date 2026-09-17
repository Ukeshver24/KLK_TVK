import { Router } from 'express';
import { LocationController } from '../controllers/location.controller';

const router = Router();

// Public routes for App dropdowns (Taluks & Villages)
router.get('/taluks', LocationController.getTaluks);
router.get('/villages', LocationController.getVillages);

// Admin routes for managing Master Location Data
router.post('/villages', LocationController.createVillage);
router.post('/villages/bulk', LocationController.bulkCreateVillages);
router.post('/villages/bulk-delete', LocationController.bulkDeleteVillages);
router.put('/villages/:id', LocationController.updateVillage);
router.delete('/villages/:id', LocationController.deleteVillage);

export default router;
