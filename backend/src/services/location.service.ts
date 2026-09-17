import prisma from '../config/db';
import { AppError } from '../middlewares/error.middleware';
import { resolveVillageNames, normalizeTaluk, KNOWN_TALUKS } from '../utils/translator';

export interface CreateVillageInput {
  district?: string;
  taluk: string;
  talukTa?: string;
  nameTa?: string;
  nameEn?: string;
  name?: string;
  pincode?: string;
}

export class LocationService {
  /**
   * Get all distinct Taluks available strictly from active database records.
   * If DB has no villages/taluks, returns empty array [].
   */
  static async getTaluks(): Promise<{ nameEn: string; nameTa: string }[]> {
    const distinctTaluks = await prisma.village.findMany({
      where: { isActive: true },
      select: { taluk: true },
      distinct: ['taluk'],
      orderBy: { taluk: 'asc' },
    });

    const talukMap = new Map<string, { nameEn: string; nameTa: string }>();

    for (const item of distinctTaluks) {
      if (item.taluk && item.taluk.trim()) {
        const norm = normalizeTaluk(item.taluk);
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
  static async getVillages(talukQuery?: string, includeInactive: boolean = false) {
    const where: Record<string, any> = {};
    if (!includeInactive) {
      where.isActive = true;
    }

    if (talukQuery && talukQuery.trim() !== '') {
      const { talukEn, talukTa } = normalizeTaluk(talukQuery);
      where.OR = [
        { taluk: { equals: talukEn, mode: 'insensitive' } },
        { taluk: { equals: talukTa, mode: 'insensitive' } },
        { taluk: { equals: talukQuery.trim(), mode: 'insensitive' } },
      ];
    }

    return prisma.village.findMany({
      where,
      orderBy: { nameTa: 'asc' },
    });
  }

  /**
   * Admin: Add a single village (supports optional English & Tamil names)
   */
  static async createVillage(input: CreateVillageInput) {
    const rawName = (input.nameEn || input.nameTa || input.name || '').trim();
    if (!rawName) {
      throw new AppError('Village name is required', 400);
    }

    // Normalize Taluk
    const { talukEn } = normalizeTaluk(input.taluk, input.talukTa);

    // Resolve exact names
    const { nameEn, nameTa } = resolveVillageNames({
      nameEn: input.nameEn,
      nameTa: input.nameTa,
      name: rawName,
    });

    // Check if duplicate exists under this taluk
    const existing = await prisma.village.findFirst({
      where: {
        taluk: { equals: talukEn, mode: 'insensitive' },
        OR: [
          { nameTa: { equals: nameTa, mode: 'insensitive' } },
          { nameEn: { equals: nameEn, mode: 'insensitive' } },
        ],
      },
    });

    if (existing) {
      throw new AppError(`Village "${nameEn} / ${nameTa}" already exists under ${talukEn} taluk.`, 400);
    }

    return prisma.village.create({
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
  static async bulkCreateVillages(villages: CreateVillageInput[]) {
    let createdCount = 0;

    for (const item of villages) {
      const rawName = (item.nameEn || item.nameTa || item.name || '').trim();
      if (!rawName) continue;

      const { talukEn } = normalizeTaluk(item.taluk, item.talukTa);
      const { nameEn, nameTa } = resolveVillageNames({
        nameEn: item.nameEn,
        nameTa: item.nameTa,
        name: rawName,
      });

      await prisma.village.upsert({
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
  static async updateVillage(id: string, data: Partial<CreateVillageInput & { isActive: boolean }>) {
    const village = await prisma.village.findUnique({ where: { id } });
    if (!village) {
      throw new AppError('Village not found', 404);
    }

    let nameTa = data.nameTa;
    let nameEn = data.nameEn;
    let taluk = data.taluk;

    if (taluk) {
      taluk = normalizeTaluk(taluk, data.talukTa).talukEn;
    }

    if (nameEn !== undefined || nameTa !== undefined) {
      const resolved = resolveVillageNames({
        nameEn: nameEn ?? village.nameEn,
        nameTa: nameTa ?? village.nameTa,
      });
      nameEn = resolved.nameEn;
      nameTa = resolved.nameTa;
    }

    return prisma.village.update({
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
  static async deleteVillage(id: string) {
    const village = await prisma.village.findUnique({ where: { id } });
    if (!village) {
      throw new AppError('Village not found', 404);
    }

    return prisma.village.delete({
      where: { id },
    });
  }

  /**
   * Admin: Bulk delete villages
   */
  static async bulkDeleteVillages(ids: string[]) {
    if (!Array.isArray(ids) || ids.length === 0) {
      throw new AppError('No village IDs provided for deletion', 400);
    }
    const result = await prisma.village.deleteMany({
      where: { id: { in: ids } },
    });
    return { count: result.count, message: `Successfully deleted ${result.count} villages` };
  }
}
