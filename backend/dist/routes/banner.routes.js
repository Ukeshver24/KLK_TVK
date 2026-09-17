"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const banner_controller_1 = require("../controllers/banner.controller");
const upload_middleware_1 = require("../middlewares/upload.middleware");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const router = (0, express_1.Router)();
// GET /api/v1/banners - Fetch active banners (Public)
router.get('/', banner_controller_1.BannerController.getBanners);
// Admin Banner Management Routes
router.post('/upload', auth_middleware_1.optionalAuthenticate, upload_middleware_1.uploadBannerImageMiddleware.single('image'), banner_controller_1.BannerController.uploadBannerImage);
router.put('/', auth_middleware_1.optionalAuthenticate, banner_controller_1.BannerController.saveBanners);
router.post('/', auth_middleware_1.optionalAuthenticate, banner_controller_1.BannerController.saveBanners);
router.delete('/:slot', auth_middleware_1.optionalAuthenticate, banner_controller_1.BannerController.deleteBanner);
router.post('/delete/:slot', auth_middleware_1.optionalAuthenticate, banner_controller_1.BannerController.deleteBanner);
exports.default = router;
