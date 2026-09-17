"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_routes_1 = __importDefault(require("./auth.routes"));
const location_routes_1 = __importDefault(require("./location.routes"));
const complaint_routes_1 = __importDefault(require("./complaint.routes"));
const banner_routes_1 = __importDefault(require("./banner.routes"));
const mla_contact_routes_1 = __importDefault(require("./mla-contact.routes"));
const system_setting_routes_1 = __importDefault(require("./system-setting.routes"));
const broadcast_routes_1 = __importDefault(require("./broadcast.routes"));
const cadre_routes_1 = __importDefault(require("./cadre.routes"));
const router = (0, express_1.Router)();
// Health Check route
router.get('/health', (req, res) => {
    res.status(200).json({
        status: 'online',
        timestamp: new Date().toISOString(),
        service: 'TVK Backend API',
    });
});
// Mount Auth routes under /api/v1/auth
router.use('/auth', auth_routes_1.default);
// Mount Location / Master data routes under /api/v1/locations
router.use('/locations', location_routes_1.default);
// Mount Complaint routes under /api/v1/complaints
router.use('/complaints', complaint_routes_1.default);
// Mount Banner routes under /api/v1/banners
router.use('/banners', banner_routes_1.default);
// Mount MLA Contact routes under /api/v1/mla-contact
router.use('/mla-contact', mla_contact_routes_1.default);
// Mount System Settings routes under /api/v1/system
router.use('/system', system_setting_routes_1.default);
// Mount Broadcast Alert routes under /api/v1/broadcasts
router.use('/broadcasts', broadcast_routes_1.default);
// Mount Cadre routes under /api/v1/cadres
router.use('/cadres', cadre_routes_1.default);
exports.default = router;
