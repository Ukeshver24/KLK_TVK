"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const location_controller_1 = require("../controllers/location.controller");
const router = (0, express_1.Router)();
// Public routes for App dropdowns (Taluks & Villages)
router.get('/taluks', location_controller_1.LocationController.getTaluks);
router.get('/villages', location_controller_1.LocationController.getVillages);
// Admin routes for managing Master Location Data
router.post('/villages', location_controller_1.LocationController.createVillage);
router.post('/villages/bulk', location_controller_1.LocationController.bulkCreateVillages);
router.post('/villages/bulk-delete', location_controller_1.LocationController.bulkDeleteVillages);
router.put('/villages/:id', location_controller_1.LocationController.updateVillage);
router.delete('/villages/:id', location_controller_1.LocationController.deleteVillage);
exports.default = router;
