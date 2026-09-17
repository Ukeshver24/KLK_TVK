"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const broadcast_controller_1 = require("../controllers/broadcast.controller");
const upload_middleware_1 = require("../middlewares/upload.middleware");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const router = (0, express_1.Router)();
// GET /api/v1/broadcasts/active (Public)
router.get('/active', broadcast_controller_1.BroadcastController.getActiveAlert);
// Admin Routes
router.put('/active', auth_middleware_1.optionalAuthenticate, broadcast_controller_1.BroadcastController.updateAlert);
router.post('/poster', auth_middleware_1.optionalAuthenticate, upload_middleware_1.uploadBroadcastPosterMiddleware.single('poster'), broadcast_controller_1.BroadcastController.uploadPoster);
router.delete('/poster', auth_middleware_1.optionalAuthenticate, broadcast_controller_1.BroadcastController.deletePoster);
exports.default = router;
