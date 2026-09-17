"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MlaContactController = void 0;
const mla_contact_service_1 = require("../services/mla-contact.service");
class MlaContactController {
    /**
     * GET /api/v1/mla-contact
     */
    static async getContact(req, res, next) {
        try {
            const contact = await mla_contact_service_1.MlaContactService.getContact();
            const host = req.get('host') || 'localhost:4000';
            const protocol = req.protocol || 'http';
            const baseUrl = process.env.API_BASE_URL || `${protocol}://${host}`;
            let fullPhotoUrl = contact.photoUrl || '';
            if (!fullPhotoUrl || fullPhotoUrl === 'assets/images/mla_photo.jpg' || fullPhotoUrl === 'assets/images/mla_photo.jpeg') {
                fullPhotoUrl = `${baseUrl}/uploads/mla/mla_photo.jpg`;
            }
            else if (!fullPhotoUrl.startsWith('http')) {
                const cleanPath = fullPhotoUrl.startsWith('/') ? fullPhotoUrl : `/${fullPhotoUrl}`;
                fullPhotoUrl = `${baseUrl}${cleanPath}`;
            }
            res.status(200).json({
                success: true,
                data: {
                    ...contact,
                    fullPhotoUrl,
                },
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * PUT /api/v1/mla-contact
     */
    static async updateContact(req, res, next) {
        try {
            const updated = await mla_contact_service_1.MlaContactService.updateContact(req.body);
            const host = req.get('host') || 'localhost:4000';
            const protocol = req.protocol || 'http';
            const baseUrl = process.env.API_BASE_URL || `${protocol}://${host}`;
            let fullPhotoUrl = updated.photoUrl || '';
            if (!fullPhotoUrl || fullPhotoUrl === 'assets/images/mla_photo.jpg' || fullPhotoUrl === 'assets/images/mla_photo.jpeg') {
                fullPhotoUrl = `${baseUrl}/uploads/mla/mla_photo.jpg`;
            }
            else if (!fullPhotoUrl.startsWith('http')) {
                const cleanPath = fullPhotoUrl.startsWith('/') ? fullPhotoUrl : `/${fullPhotoUrl}`;
                fullPhotoUrl = `${baseUrl}${cleanPath}`;
            }
            res.status(200).json({
                success: true,
                message: 'MLA Contact profile updated successfully',
                data: {
                    ...updated,
                    fullPhotoUrl,
                },
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * POST /api/v1/mla-contact/photo
     */
    static async uploadAvatar(req, res, next) {
        try {
            if (!req.file) {
                res.status(400).json({ success: false, message: 'No photo file uploaded' });
                return;
            }
            const host = req.get('host') || 'localhost:4000';
            const protocol = req.protocol || 'http';
            const baseUrl = process.env.API_BASE_URL || `${protocol}://${host}`;
            const relativePath = `/uploads/mla/${req.file.filename}`;
            const fullUrl = `${baseUrl}${relativePath}`;
            // Update contact record with new avatar photo
            const updated = await mla_contact_service_1.MlaContactService.updateContact({
                photoUrl: relativePath,
            });
            res.status(200).json({
                success: true,
                message: 'MLA photo uploaded successfully',
                data: {
                    ...updated,
                    filename: req.file.filename,
                    relativePath: relativePath,
                    url: relativePath,
                    fullPhotoUrl: fullUrl,
                },
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * DELETE /api/v1/mla-contact/photo
     */
    static async deleteAvatar(req, res, next) {
        try {
            const updated = await mla_contact_service_1.MlaContactService.deleteAvatar();
            const host = req.get('host') || 'localhost:4000';
            const protocol = req.protocol || 'http';
            const baseUrl = process.env.API_BASE_URL || `${protocol}://${host}`;
            const defaultUrl = `${baseUrl}/uploads/mla/mla_photo.jpg`;
            res.status(200).json({
                success: true,
                message: 'MLA photo reset to default successfully',
                data: {
                    ...updated,
                    photoUrl: 'assets/images/mla_photo.jpg',
                    fullPhotoUrl: defaultUrl,
                },
            });
        }
        catch (error) {
            next(error);
        }
    }
}
exports.MlaContactController = MlaContactController;
