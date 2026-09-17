"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const mla_contact_controller_1 = require("../controllers/mla-contact.controller");
const upload_middleware_1 = require("../middlewares/upload.middleware");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const router = (0, express_1.Router)();
// GET /api/v1/mla-contact - Fetch MLA Contact Details (Public)
router.get('/', mla_contact_controller_1.MlaContactController.getContact);
// Admin Routes
router.put('/', auth_middleware_1.optionalAuthenticate, mla_contact_controller_1.MlaContactController.updateContact);
router.post('/photo', auth_middleware_1.optionalAuthenticate, upload_middleware_1.uploadMlaAvatarMiddleware.single('photo'), mla_contact_controller_1.MlaContactController.uploadAvatar);
router.delete('/photo', auth_middleware_1.optionalAuthenticate, mla_contact_controller_1.MlaContactController.deleteAvatar);
exports.default = router;
