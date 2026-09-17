import path from 'path';
import fs from 'fs';
import prisma from '../config/db';

export interface MlaContactInput {
  name: string;
  degree: string;
  designationEn: string;
  designationTa: string;
  addressEn: string;
  addressTa: string;
  phone: string;
  email: string;
  visitingHoursEn: string;
  visitingHoursTa: string;
  photoUrl?: string | null;
}

export class MlaContactService {
  private static DEFAULT_CONTACT = {
    name: 'C. Arul Vignesh',
    degree: 'M.Sc.,',
    designationEn: 'MLA, KALLAKURICHI',
    designationTa: 'சட்டப்பேரவை உறுப்பினர், கள்ளக்குறிச்சி',
    addressEn: 'No 42, Main Road, Near Bus Stand, Kallakurichi, Tamil Nadu – 606202',
    addressTa: 'எண் 42, பிரதான சாலை, பேருந்து நிலையம் அருகில், கள்ளக்குறிச்சி, தமிழ்நாடு – 606202',
    phone: '+91 98765 43210',
    email: 'mla.kallakurichi@tvk.in',
    visitingHoursEn: 'Monday - Saturday: 09:00 AM - 06:00 PM',
    visitingHoursTa: 'திங்கள் - சனி: காலை 09:00 - மாலை 06:00',
    photoUrl: 'assets/images/mla_photo.jpg',
  };

  /**
   * Helper: Normalize image path to store ONLY relative folder path in DB (e.g. /uploads/mla/xxx.jpg)
   */
  public static normalizeDbPath(url: string | null | undefined): string {
    if (!url) return '';
    const trimmed = url.trim();
    if (!trimmed || trimmed.startsWith('assets/')) return trimmed;

    const uploadIndex = trimmed.indexOf('/uploads/');
    if (uploadIndex !== -1) {
      return trimmed.substring(uploadIndex);
    }

    if (trimmed.startsWith('uploads/')) {
      return `/${trimmed}`;
    }

    return trimmed;
  }

  /**
   * Safe physical file deletion for MLA avatar
   */
  public static deletePhysicalMlaPhoto(photoUrl: string | null | undefined): void {
    if (!photoUrl) return;
    if (photoUrl.startsWith('assets/') || photoUrl.startsWith('data:') || photoUrl.trim() === '') return;

    try {
      const urlWithoutQuery = photoUrl.split('?')[0];
      const filename = path.basename(urlWithoutQuery);
      if (!filename || filename.length < 5 || !filename.includes('.')) return;

      const mlaDir = path.resolve(process.cwd(), 'uploads/mla');
      const targetFilePath = path.join(mlaDir, filename);

      if (fs.existsSync(targetFilePath)) {
        fs.unlinkSync(targetFilePath);
        console.log(`[Disk Cleanup] Deleted old MLA photo: ${targetFilePath}`);
      }
    } catch (err) {
      console.error(`[Disk Cleanup] Error deleting MLA photo ${photoUrl}:`, err);
    }
  }

  /**
   * Get MLA Contact profile
   */
  static async getContact() {
    let contact = await prisma.mlaContact.findFirst();

    if (!contact) {
      contact = await prisma.mlaContact.create({
        data: this.DEFAULT_CONTACT,
      });
    }

    return contact;
  }

  /**
   * Save / Update MLA Contact profile
   */
  static async updateContact(data: Partial<MlaContactInput>) {
    const existing = await this.getContact();

    // If photoUrl changed, delete previous physical photo if applicable
    if (data.photoUrl !== undefined && existing.photoUrl && existing.photoUrl !== data.photoUrl) {
      const cleanNew = this.normalizeDbPath(data.photoUrl);
      if (existing.photoUrl !== cleanNew) {
        this.deletePhysicalMlaPhoto(existing.photoUrl);
      }
    }

    const cleanPhotoUrl = data.photoUrl !== undefined
      ? this.normalizeDbPath(data.photoUrl)
      : existing.photoUrl;

    const updated = await prisma.mlaContact.update({
      where: { id: existing.id },
      data: {
        name: data.name?.trim() || existing.name,
        degree: data.degree?.trim() || existing.degree,
        designationEn: data.designationEn?.trim() || existing.designationEn,
        designationTa: data.designationTa?.trim() || existing.designationTa,
        addressEn: data.addressEn?.trim() || existing.addressEn,
        addressTa: data.addressTa?.trim() || existing.addressTa,
        phone: data.phone?.trim() || existing.phone,
        email: data.email?.trim() || existing.email,
        visitingHoursEn: data.visitingHoursEn?.trim() || existing.visitingHoursEn,
        visitingHoursTa: data.visitingHoursTa?.trim() || existing.visitingHoursTa,
        photoUrl: cleanPhotoUrl,
      },
    });

    return updated;
  }

  /**
   * Delete / Reset MLA Avatar Photo
   */
  static async deleteAvatar() {
    const existing = await this.getContact();
    if (existing.photoUrl) {
      this.deletePhysicalMlaPhoto(existing.photoUrl);
    }

    return prisma.mlaContact.update({
      where: { id: existing.id },
      data: {
        photoUrl: 'assets/images/mla_photo.jpg',
      },
    });
  }
}
