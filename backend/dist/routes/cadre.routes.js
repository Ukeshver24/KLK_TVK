"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const cadre_controller_1 = require("../controllers/cadre.controller");
const upload_middleware_1 = require("../middlewares/upload.middleware");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const router = (0, express_1.Router)();
// GET /api/v1/cadres (Public / Member directory lookup)
router.get('/', cadre_controller_1.CadreController.getAllCadres);
// GET /api/v1/cadres/:id
router.get('/:id', cadre_controller_1.CadreController.getCadreById);
// Admin Management Routes
router.post('/', auth_middleware_1.optionalAuthenticate, cadre_controller_1.CadreController.createCadre);
router.put('/:id', auth_middleware_1.optionalAuthenticate, cadre_controller_1.CadreController.updateCadre);
router.delete('/:id', auth_middleware_1.optionalAuthenticate, cadre_controller_1.CadreController.deleteCadre);
router.post('/:id/photo', auth_middleware_1.optionalAuthenticate, upload_middleware_1.uploadCadreAvatarMiddleware.single('photo'), cadre_controller_1.CadreController.uploadPhoto);
exports.default = router;
