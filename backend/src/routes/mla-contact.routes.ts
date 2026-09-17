import { Router } from 'express';
import { MlaContactController } from '../controllers/mla-contact.controller';
import { uploadMlaAvatarMiddleware } from '../middlewares/upload.middleware';
import { optionalAuthenticate } from '../middlewares/auth.middleware';

const router = Router();

// GET /api/v1/mla-contact - Fetch MLA Contact Details (Public)
router.get('/', MlaContactController.getContact);

// Admin Routes
router.put('/', optionalAuthenticate, MlaContactController.updateContact);
router.post('/photo', optionalAuthenticate, uploadMlaAvatarMiddleware.single('photo'), MlaContactController.uploadAvatar);
router.delete('/photo', optionalAuthenticate, MlaContactController.deleteAvatar);

export default router;
