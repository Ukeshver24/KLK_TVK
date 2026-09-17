import { Router } from 'express';
import { BannerController } from '../controllers/banner.controller';
import { uploadBannerImageMiddleware } from '../middlewares/upload.middleware';
import { optionalAuthenticate } from '../middlewares/auth.middleware';

const router = Router();

// GET /api/v1/banners - Fetch active banners (Public)
router.get('/', BannerController.getBanners);

// Admin Banner Management Routes
router.post('/upload', optionalAuthenticate, uploadBannerImageMiddleware.single('image'), BannerController.uploadBannerImage);
router.put('/', optionalAuthenticate, BannerController.saveBanners);
router.post('/', optionalAuthenticate, BannerController.saveBanners);
router.delete('/:slot', optionalAuthenticate, BannerController.deleteBanner);
router.post('/delete/:slot', optionalAuthenticate, BannerController.deleteBanner);

export default router;
