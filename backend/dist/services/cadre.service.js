"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CadreService = void 0;
const db_1 = __importDefault(require("../config/db"));
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
const error_middleware_1 = require("../middlewares/error.middleware");
class CadreService {
    /**
     * Format cadre with full photo URL
     */
    static formatCadre(cadre) {
        let fullPhotoUrl = null;
        if (cadre.photoUrl) {
            if (cadre.photoUrl.startsWith('http') || cadre.photoUrl.startsWith('data:')) {
                fullPhotoUrl = cadre.photoUrl;
            }
            else {
                const clean = cadre.photoUrl.replace(/^\/uploads\/cadres\//, '');
                fullPhotoUrl = `/uploads/cadres/${clean}`;
            }
        }
        return {
            ...cadre,
            fullPhotoUrl,
            assignedGrievancesCount: cadre._count?.complaints ?? (cadre.complaints ? cadre.complaints.length : 0),
        };
    }
    /**
     * Get all cadres with optional filtering
     */
    static async getAllCadres(query) {
        const where = {};
        if (query?.taluk && query.taluk !== 'all') {
            where.taluk = { contains: query.taluk, mode: 'insensitive' };
        }
        if (query?.village) {
            where.village = { contains: query.village, mode: 'insensitive' };
        }
        if (query?.role) {
            where.role = { contains: query.role, mode: 'insensitive' };
        }
        if (query?.search && query.search.trim()) {
            const s = query.search.trim();
            where.OR = [
                { name: { contains: s, mode: 'insensitive' } },
                { nameTa: { contains: s, mode: 'insensitive' } },
                { phone: { contains: s } },
                { role: { contains: s, mode: 'insensitive' } },
                { roleTa: { contains: s, mode: 'insensitive' } },
                { taluk: { contains: s, mode: 'insensitive' } },
                { village: { contains: s, mode: 'insensitive' } },
                { boothNumber: { contains: s, mode: 'insensitive' } },
                { voterId: { contains: s, mode: 'insensitive' } },
                { cadreCode: { contains: s, mode: 'insensitive' } },
            ];
        }
        const cadres = await db_1.default.cadre.findMany({
            where,
            include: {
                _count: {
                    select: { complaints: true },
                },
            },
            orderBy: { createdAt: 'desc' },
        });
        return cadres.map(this.formatCadre);
    }
    /**
     * Get cadre by ID
     */
    static async getCadreById(id) {
        const cadre = await db_1.default.cadre.findUnique({
            where: { id },
            include: {
                _count: {
                    select: { complaints: true },
                },
            },
        });
        if (!cadre) {
            throw new error_middleware_1.AppError('Cadre member not found', 404);
        }
        return this.formatCadre(cadre);
    }
    /**
     * Create new cadre member
     */
    static async createCadre(data) {
        const formattedPhone = data.phone.startsWith('+91')
            ? data.phone
            : `+91 ${data.phone.replace(/\D/g, '').slice(-10)}`;
        // Check if phone already exists
        const existing = await db_1.default.cadre.findUnique({
            where: { phone: formattedPhone },
        });
        if (existing) {
            throw new error_middleware_1.AppError('A cadre member with this mobile number already exists', 400);
        }
        // Generate Cadre Code
        const count = await db_1.default.cadre.count();
        const cadreCode = `TVK-CAD-${String(count + 1).padStart(3, '0')}`;
        const created = await db_1.default.cadre.create({
            data: {
                cadreCode,
                name: data.name.trim(),
                nameTa: data.nameTa?.trim() || data.name.trim(),
                phone: formattedPhone,
                role: data.role.trim(),
                roleTa: data.roleTa?.trim() || data.role.trim(),
                taluk: data.taluk?.trim() || 'Kallakurichi',
                talukTa: data.talukTa?.trim() || (data.taluk?.trim() || 'கள்ளக்குறிச்சி'),
                village: data.village.trim(),
                villageTa: data.villageTa?.trim() || data.village.trim(),
                boothNumber: data.boothNumber.trim(),
                voterId: data.voterId?.trim() || null,
                photoUrl: data.photoUrl || null,
                isVerified: data.isVerified ?? true,
            },
        });
        return this.formatCadre(created);
    }
    /**
     * Update existing cadre member
     */
    static async updateCadre(id, data) {
        const existing = await db_1.default.cadre.findUnique({ where: { id } });
        if (!existing) {
            throw new error_middleware_1.AppError('Cadre member not found', 404);
        }
        let formattedPhone = existing.phone;
        if (data.phone) {
            formattedPhone = data.phone.startsWith('+91')
                ? data.phone
                : `+91 ${data.phone.replace(/\D/g, '').slice(-10)}`;
            if (formattedPhone !== existing.phone) {
                const duplicate = await db_1.default.cadre.findUnique({ where: { phone: formattedPhone } });
                if (duplicate) {
                    throw new error_middleware_1.AppError('A cadre member with this mobile number already exists', 400);
                }
            }
        }
        let finalPhotoUrl = existing.photoUrl;
        if ('photoUrl' in data) {
            if (data.photoUrl === null || data.photoUrl === '') {
                if (existing.photoUrl) {
                    this.deletePhysicalPhotoFile(existing.photoUrl);
                }
                finalPhotoUrl = null;
            }
            else if (data.photoUrl && !data.photoUrl.startsWith('http') && !data.photoUrl.startsWith('data:')) {
                finalPhotoUrl = data.photoUrl;
            }
        }
        let finalVoterId = existing.voterId;
        if ('voterId' in data) {
            finalVoterId = (data.voterId && data.voterId.trim()) ? data.voterId.trim() : null;
        }
        const updated = await db_1.default.cadre.update({
            where: { id },
            data: {
                name: data.name !== undefined ? data.name.trim() : existing.name,
                nameTa: data.nameTa !== undefined ? data.nameTa.trim() : existing.nameTa,
                phone: formattedPhone,
                role: data.role !== undefined ? data.role.trim() : existing.role,
                roleTa: data.roleTa !== undefined ? data.roleTa.trim() : existing.roleTa,
                taluk: data.taluk !== undefined ? data.taluk.trim() : existing.taluk,
                talukTa: data.talukTa !== undefined ? data.talukTa.trim() : existing.talukTa,
                village: data.village !== undefined ? data.village.trim() : existing.village,
                villageTa: data.villageTa !== undefined ? data.villageTa.trim() : existing.villageTa,
                boothNumber: data.boothNumber !== undefined ? data.boothNumber.trim() : existing.boothNumber,
                voterId: finalVoterId,
                photoUrl: finalPhotoUrl,
                isVerified: data.isVerified !== undefined ? data.isVerified : existing.isVerified,
            },
            include: {
                _count: {
                    select: { complaints: true },
                },
            },
        });
        return this.formatCadre(updated);
    }
    /**
     * Delete cadre member
     */
    static async deleteCadre(id) {
        const existing = await db_1.default.cadre.findUnique({ where: { id } });
        if (!existing) {
            throw new error_middleware_1.AppError('Cadre member not found', 404);
        }
        if (existing.photoUrl) {
            this.deletePhysicalPhotoFile(existing.photoUrl);
        }
        // Detach any assigned complaints first so foreign keys don't fail
        await db_1.default.complaint.updateMany({
            where: { assignedCadreId: id },
            data: { assignedCadreId: null },
        });
        await db_1.default.cadre.delete({ where: { id } });
        return { success: true, message: 'Cadre member removed successfully' };
    }
    /**
     * Handle photo upload for a cadre
     */
    static async uploadPhoto(id, file) {
        const existing = await db_1.default.cadre.findUnique({ where: { id } });
        if (!existing) {
            throw new error_middleware_1.AppError('Cadre member not found', 404);
        }
        if (existing.photoUrl) {
            this.deletePhysicalPhotoFile(existing.photoUrl);
        }
        const relativePath = `/uploads/cadres/${file.filename}`;
        const updated = await db_1.default.cadre.update({
            where: { id },
            data: { photoUrl: relativePath },
        });
        return this.formatCadre(updated);
    }
    /**
     * Helper to delete physical photo file
     */
    static deletePhysicalPhotoFile(photoPath) {
        try {
            if (photoPath && !photoPath.startsWith('http') && !photoPath.startsWith('data:')) {
                const filename = photoPath.replace(/^\/uploads\/cadres\//, '').replace(/^uploads\/cadres\//, '');
                const fullDiskPath = path_1.default.resolve(process.cwd(), 'uploads', 'cadres', filename);
                if (fs_1.default.existsSync(fullDiskPath)) {
                    fs_1.default.unlinkSync(fullDiskPath);
                }
            }
        }
        catch (err) {
            console.error('Error cleaning old cadre photo from disk:', err);
        }
    }
}
exports.CadreService = CadreService;
