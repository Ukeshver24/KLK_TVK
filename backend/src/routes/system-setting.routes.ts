import { Router } from 'express';
import { SystemSettingController } from '../controllers/system-setting.controller';
import { optionalAuthenticate } from '../middlewares/auth.middleware';

const router = Router();

// GET /api/v1/system/settings (Public)
router.get('/settings', SystemSettingController.getSettings);

// PUT /api/v1/system/settings (Admin & MLA Office)
router.put('/settings', optionalAuthenticate, SystemSettingController.updateSettings);

export default router;
