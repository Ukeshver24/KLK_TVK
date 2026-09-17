import { Router } from 'express';
import { CadreController } from '../controllers/cadre.controller';
import { uploadCadreAvatarMiddleware } from '../middlewares/upload.middleware';
import { optionalAuthenticate } from '../middlewares/auth.middleware';

const router = Router();

// GET /api/v1/cadres (Public / Member directory lookup)
router.get('/', CadreController.getAllCadres);

// GET /api/v1/cadres/:id
router.get('/:id', CadreController.getCadreById);

// Admin Management Routes
router.post('/', optionalAuthenticate, CadreController.createCadre);
router.put('/:id', optionalAuthenticate, CadreController.updateCadre);
router.delete('/:id', optionalAuthenticate, CadreController.deleteCadre);
router.post('/:id/photo', optionalAuthenticate, uploadCadreAvatarMiddleware.single('photo'), CadreController.uploadPhoto);

export default router;
