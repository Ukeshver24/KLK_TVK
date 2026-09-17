"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.LocationService = void 0;
const db_1 = __importDefault(require("../config/db"));
const error_middleware_1 = require("../middlewares/error.middleware");
const translator_1 = require("../utils/translator");
class LocationService {
    /**
     * Get all distinct Taluks available strictly from active database records.
     * If DB has no villages/taluks, returns empty array [].
     */
    static async getTaluks() {
        const distinctTaluks = await db_1.default.village.findMany({
            where: { isActive: true },
            select: { taluk: true },
            distinct: ['taluk'],
            orderBy: { taluk: 'asc' },
        });
        const talukMap = new Map();
        for (const item of distinctTaluks) {
            if (item.taluk && item.taluk.trim()) {
                const norm = (0, translator_1.normalizeTaluk)(item.taluk);
                talukMap.set(norm.talukEn.toLowerCase(), {
                    nameEn: norm.talukEn,
                    nameTa: norm.talukTa,
                });
            }
        }
        return Array.from(talukMap.values());
    }
    /**
     * Get all active villages (optionally filtered by taluk in English or Tamil)
     */
    static async getVillages(talukQuery, includeInactive = false) {
        const where = {};
        if (!includeInactive) {
            where.isActive = true;
        }
        if (talukQuery && talukQuery.trim() !== '') {
            const { talukEn, talukTa } = (0, translator_1.normalizeTaluk)(talukQuery);
            where.OR = [
                { taluk: { equals: talukEn, mode: 'insensitive' } },
                { taluk: { equals: talukTa, mode: 'insensitive' } },
                { taluk: { equals: talukQuery.trim(), mode: 'insensitive' } },
            ];
        }
        return db_1.default.village.findMany({
            where,
            orderBy: { nameTa: 'asc' },
        });
    }
    /**
     * Admin: Add a single village (supports optional English & Tamil names)
     */
    static async createVillage(input) {
        const rawName = (input.nameEn || input.nameTa || input.name || '').trim();
        if (!rawName) {
            throw new error_middleware_1.AppError('Village name is required', 400);
        }
        // Normalize Taluk
        const { talukEn } = (0, translator_1.normalizeTaluk)(input.taluk, input.talukTa);
        // Resolve exact names
        const { nameEn, nameTa } = (0, translator_1.resolveVillageNames)({
            nameEn: input.nameEn,
            nameTa: input.nameTa,
            name: rawName,
        });
        // Check if duplicate exists under this taluk
        const existing = await db_1.default.village.findFirst({
            where: {
                taluk: { equals: talukEn, mode: 'insensitive' },
                OR: [
                    { nameTa: { equals: nameTa, mode: 'insensitive' } },
                    { nameEn: { equals: nameEn, mode: 'insensitive' } },
                ],
            },
        });
        if (existing) {
            throw new error_middleware_1.AppError(`Village "${nameEn} / ${nameTa}" already exists under ${talukEn} taluk.`, 400);
        }
        return db_1.default.village.create({
            data: {
                taluk: talukEn,
                nameTa,
                nameEn,
                pincode: input.pincode?.trim() || '606202',
                isActive: true,
            },
        });
    }
    /**
     * Admin: Bulk upload villages (preserves exact Admin inputs)
     */
    static async bulkCreateVillages(villages) {
        let createdCount = 0;
        for (const item of villages) {
            const rawName = (item.nameEn || item.nameTa || item.name || '').trim();
            if (!rawName)
                continue;
            const { talukEn } = (0, translator_1.normalizeTaluk)(item.taluk, item.talukTa);
            const { nameEn, nameTa } = (0, translator_1.resolveVillageNames)({
                nameEn: item.nameEn,
                nameTa: item.nameTa,
                name: rawName,
            });
            await db_1.default.village.upsert({
                where: {
                    taluk_nameTa: {
                        taluk: talukEn,
                        nameTa,
                    },
                },
                update: {
                    nameEn,
                    pincode: item.pincode?.trim() || '606202',
                    isActive: true,
                },
                create: {
                    taluk: talukEn,
                    nameTa,
                    nameEn,
                    pincode: item.pincode?.trim() || '606202',
                    isActive: true,
                },
            });
            createdCount++;
        }
        return { count: createdCount, message: `Successfully processed ${createdCount} villages` };
    }
    /**
     * Admin: Update village details
     */
    static async updateVillage(id, data) {
        const village = await db_1.default.village.findUnique({ where: { id } });
        if (!village) {
            throw new error_middleware_1.AppError('Village not found', 404);
        }
        let nameTa = data.nameTa;
        let nameEn = data.nameEn;
        let taluk = data.taluk;
        if (taluk) {
            taluk = (0, translator_1.normalizeTaluk)(taluk, data.talukTa).talukEn;
        }
        if (nameEn !== undefined || nameTa !== undefined) {
            const resolved = (0, translator_1.resolveVillageNames)({
                nameEn: nameEn ?? village.nameEn,
                nameTa: nameTa ?? village.nameTa,
            });
            nameEn = resolved.nameEn;
            nameTa = resolved.nameTa;
        }
        return db_1.default.village.update({
            where: { id },
            data: {
                ...(taluk && { taluk }),
                ...(nameTa && { nameTa }),
                ...(nameEn && { nameEn }),
                ...(data.pincode && { pincode: data.pincode.trim() }),
                ...(data.isActive !== undefined && { isActive: data.isActive }),
            },
        });
    }
    /**
     * Admin: Delete a village
     */
    static async deleteVillage(id) {
        const village = await db_1.default.village.findUnique({ where: { id } });
        if (!village) {
            throw new error_middleware_1.AppError('Village not found', 404);
        }
        return db_1.default.village.delete({
            where: { id },
        });
    }
    /**
     * Admin: Bulk delete villages
     */
    static async bulkDeleteVillages(ids) {
        if (!Array.isArray(ids) || ids.length === 0) {
            throw new error_middleware_1.AppError('No village IDs provided for deletion', 400);
        }
        const result = await db_1.default.village.deleteMany({
            where: { id: { in: ids } },
        });
        return { count: result.count, message: `Successfully deleted ${result.count} villages` };
    }
}
exports.LocationService = LocationService;
