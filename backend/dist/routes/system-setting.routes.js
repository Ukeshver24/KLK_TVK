"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const system_setting_controller_1 = require("../controllers/system-setting.controller");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const router = (0, express_1.Router)();
// GET /api/v1/system/settings (Public)
router.get('/settings', system_setting_controller_1.SystemSettingController.getSettings);
// PUT /api/v1/system/settings (Admin & MLA Office)
router.put('/settings', auth_middleware_1.optionalAuthenticate, system_setting_controller_1.SystemSettingController.updateSettings);
exports.default = router;
