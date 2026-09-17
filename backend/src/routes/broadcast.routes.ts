import { Router } from 'express';
import { BroadcastController } from '../controllers/broadcast.controller';
import { uploadBroadcastPosterMiddleware } from '../middlewares/upload.middleware';
import { optionalAuthenticate } from '../middlewares/auth.middleware';

const router = Router();

// GET /api/v1/broadcasts/active (Public)
router.get('/active', BroadcastController.getActiveAlert);

// Admin Routes
router.put('/active', optionalAuthenticate, BroadcastController.updateAlert);
router.post('/poster', optionalAuthenticate, uploadBroadcastPosterMiddleware.single('poster'), BroadcastController.uploadPoster);
router.delete('/poster', optionalAuthenticate, BroadcastController.deletePoster);

export default router;
