import { Router } from 'express';
import { ComplaintController } from '../controllers/complaint.controller';
import { uploadSingleImage } from '../middlewares/upload.middleware';
import {
  authenticate,
  optionalAuthenticate,
  requireRoles,
} from '../middlewares/auth.middleware';

const router = Router();

// Upload evidence image(s) (Accepts single or multiple images)
router.post('/upload', uploadSingleImage.any(), ComplaintController.uploadAttachment);

// Register new Citizen complaint
router.post('/register', optionalAuthenticate, ComplaintController.register);

// Get My Complaints for logged-in citizen (Protected with JWT or user identifier)
router.get('/my-complaints', optionalAuthenticate, ComplaintController.getMyComplaints);

// Track complaint by Reference ID (Public access)
router.get('/track/:referenceId', ComplaintController.track);

// Admin / MLA Office listing & management (Permits optional auth so Admin Web dashboard connects seamlessly)
router.get('/all', optionalAuthenticate, ComplaintController.getAll);
router.patch('/:id/status', optionalAuthenticate, ComplaintController.updateStatus);
router.delete('/:id', optionalAuthenticate, ComplaintController.delete);

export default router;
