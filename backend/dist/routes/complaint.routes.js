"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const complaint_controller_1 = require("../controllers/complaint.controller");
const upload_middleware_1 = require("../middlewares/upload.middleware");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const router = (0, express_1.Router)();
// Upload evidence image(s) (Accepts single or multiple images)
router.post('/upload', upload_middleware_1.uploadSingleImage.any(), complaint_controller_1.ComplaintController.uploadAttachment);
// Register new Citizen complaint
router.post('/register', auth_middleware_1.optionalAuthenticate, complaint_controller_1.ComplaintController.register);
// Get My Complaints for logged-in citizen (Protected with JWT or user identifier)
router.get('/my-complaints', auth_middleware_1.optionalAuthenticate, complaint_controller_1.ComplaintController.getMyComplaints);
// Track complaint by Reference ID (Public access)
router.get('/track/:referenceId', complaint_controller_1.ComplaintController.track);
// Admin / MLA Office listing & management (Permits optional auth so Admin Web dashboard connects seamlessly)
router.get('/all', auth_middleware_1.optionalAuthenticate, complaint_controller_1.ComplaintController.getAll);
router.patch('/:id/status', auth_middleware_1.optionalAuthenticate, complaint_controller_1.ComplaintController.updateStatus);
router.delete('/:id', auth_middleware_1.optionalAuthenticate, complaint_controller_1.ComplaintController.delete);
exports.default = router;
