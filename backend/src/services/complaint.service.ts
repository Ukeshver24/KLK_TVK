import bcrypt from 'bcryptjs';
import prisma from '../config/db';
import { AppError } from '../middlewares/error.middleware';
import { NotificationService } from './notification.service';
import { AuthService } from './auth.service';

export interface RegisterComplaintInput {
  userId: string;
  fullName: string;
  mobile: string;
  taluk: string;
  village: string;
  address: string;
  pincode: string;
  category: string;
  description: string;
  attachment?: string | null;
  latitude?: number | string | null;
  longitude?: number | string | null;
  locationUrl?: string | null;
}

export class ComplaintService {
  /**
   * Helper: Normalize status string from frontend (e.g. IN_REVIEW -> UNDER_REVIEW)
   */
  static normalizeStatus(rawStatus?: string): string {
    if (!rawStatus) return '';
    const s = String(rawStatus).toUpperCase().trim().replace(/[\s-]+/g, '_');
    if (s === 'IN_REVIEW' || s === 'UNDER_VERIFICATION' || s === 'UNDER_REVIEW') return 'UNDER_REVIEW';
    if (s === 'OFFICER_ASSIGNED' || s === 'ASSIGNED' || s === 'OFFICER') return 'OFFICER_ASSIGNED';
    if (s === 'IN_PROGRESS' || s === 'ACTION_TAKEN' || s === 'PROCESSING' || s === 'INPROGRESS') return 'IN_PROGRESS';
    if (s === 'RESOLVED' || s === 'COMPLETED') return 'RESOLVED';
    if (s === 'REJECTED' || s === 'CLOSED') return 'REJECTED';
    if (s === 'SUBMITTED' || s === 'NEW' || s === 'REGISTERED') return 'SUBMITTED';
    if (s === 'OTHERS' || s === 'NOTICE') return 'OTHERS';
    return s;
  }

  /**
   * Generate Next Sequential Grievance Token ID (e.g., TVK-KKI-26-0001)
   */
  private static async generateReferenceId(): Promise<string> {
    const currentYear = new Date().getFullYear().toString().slice(-2); // "26"
    const prefix = `TVK-KKI-${currentYear}-`;
    try {
      const result: any = await prisma.$queryRaw`SELECT nextval('complaint_ref_seq') as seq`;
      const seq = Number(result[0]?.seq || 1);
      return `${prefix}${String(seq).padStart(4, '0')}`;
    } catch {
      const count = await prisma.complaint.count();
      return `${prefix}${String(count + 1).padStart(4, '0')}`;
    }
  }

  /**
   * Register a new complaint for a citizen
   */
  static async registerComplaint(input: RegisterComplaintInput) {
    // Validate or auto-resolve user account in database before proceeding
    let validUserId = input.userId;
    let existingUser = null;

    if (input.userId) {
      existingUser = await prisma.user.findUnique({
        where: { id: input.userId },
        select: { id: true },
      });
    }

    if (!existingUser && input.mobile) {
      existingUser = await prisma.user.findUnique({
        where: { mobile: input.mobile.trim() },
        select: { id: true },
      });
    }

    if (existingUser) {
      validUserId = existingUser.id;
    } else if (input.mobile && input.mobile.trim().length >= 10) {
      // Auto-register citizen in DB so grievances are never blocked or lost
      try {
        const userCode = await AuthService.generateUserCode('CITIZEN');
        const defaultHash = await bcrypt.hash('0000', 6);
        const newUser = await prisma.user.create({
          data: {
            userCode,
            fullName: input.fullName?.trim() || 'Citizen',
            mobile: input.mobile.trim(),
            address: input.address?.trim() || null,
            mpinHash: defaultHash,
            role: 'CITIZEN',
            status: 'ACTIVE',
          },
        });
        validUserId = newUser.id;
      } catch (userCreateErr) {
        console.error('Error auto-creating citizen during complaint registration:', userCreateErr);
        const fallbackUser = await prisma.user.findUnique({
          where: { mobile: input.mobile.trim() },
          select: { id: true },
        });
        if (fallbackUser) {
          validUserId = fallbackUser.id;
        } else {
          throw new AppError('User not found. Please log in or register again.', 401);
        }
      }
    } else {
      throw new AppError('A valid mobile number is required to register a complaint.', 400);
    }

    const referenceId = await this.generateReferenceId();

    const createdComplaint = await prisma.complaint.create({
      data: {
        referenceId,
        userId: validUserId,
        fullName: input.fullName.trim(),
        mobile: input.mobile.trim(),
        taluk: input.taluk.trim(),
        village: input.village.trim(),
        address: input.address.trim(),
        pincode: input.pincode.trim(),
        category: input.category.trim(),
        description: input.description.trim(),
        attachment: input.attachment || null,
        latitude: input.latitude ? Number(input.latitude) : null,
        longitude: input.longitude ? Number(input.longitude) : null,
        locationUrl: input.locationUrl || (input.latitude && input.longitude ? `https://www.google.com/maps?q=${input.latitude},${input.longitude}` : null),
        status: 'SUBMITTED',
        timelineEvents: [
          {
            step: 1,
            status: 'SUBMITTED',
            titleEn: '1. Grievance Registered by Citizen',
            titleTa: '1. மனுதாரரால் புகார் பதிவு செய்யப்பட்டது',
            date: this.formatTimelineDate(new Date()),
            isCompleted: true,
            isNotice: false,
          },
        ],
      },
    });

    return createdComplaint;
  }

  /**
   * Fetch all complaints filed by a specific user (Mobile History)
   */
  static async getUserComplaints(userId: string) {
    return prisma.complaint.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      include: {
        user: {
          select: {
            userCode: true,
            fullName: true,
            mobile: true,
          },
        },
        assignedCadre: true,
      },
    });
  }

  static async getCitizenComplaints(userId: string) {
    return this.getUserComplaints(userId);
  }

  /**
   * Track complaints by Reference ID or Registered Mobile Number
   */
  static async trackComplaints(query: string) {
    const cleanQuery = query.trim();
    if (!cleanQuery) {
      throw new AppError('Reference ID or Mobile Number is required', 400);
    }

    const cleanPhone = cleanQuery.replace('+91', '').replace(/\s+/g, '').trim();
    const isNumericPhone = /^\d{7,15}$/.test(cleanPhone);

    if (isNumericPhone) {
      return prisma.complaint.findMany({
        where: {
          OR: [
            { mobile: { contains: cleanPhone } },
            { user: { mobile: { contains: cleanPhone } } },
          ],
        },
        orderBy: { createdAt: 'desc' },
        include: {
          user: {
            select: {
              userCode: true,
              fullName: true,
              mobile: true,
            },
          },
        },
      });
    }

    // Search by Reference ID (exact match)
    const exact = await prisma.complaint.findMany({
      where: {
        referenceId: {
          equals: cleanQuery,
          mode: 'insensitive',
        },
      },
      orderBy: { createdAt: 'desc' },
      include: {
        user: {
          select: {
            userCode: true,
            fullName: true,
            mobile: true,
          },
        },
      },
    });

    if (exact.length > 0) {
      return exact;
    }

    // Partial search
    return prisma.complaint.findMany({
      where: {
        referenceId: {
          contains: cleanQuery,
          mode: 'insensitive',
        },
      },
      orderBy: { createdAt: 'desc' },
      include: {
        user: {
          select: {
            userCode: true,
            fullName: true,
            mobile: true,
          },
        },
      },
    });
  }

  /**
   * Admin: Fetch all complaints with filters
   */
  static async getAllComplaints(filters: {
    status?: string;
    category?: string;
    village?: string;
  }) {
    const where: any = {};
    if (filters.status) where.status = this.normalizeStatus(filters.status);
    if (filters.category) where.category = filters.category;
    if (filters.village) where.village = filters.village;

    return prisma.complaint.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: {
        user: {
          select: {
            userCode: true,
            fullName: true,
            mobile: true,
          },
        },
        assignedCadre: true,
      },
    });
  }

  private static formatTimelineDate(d: Date = new Date()): string {
    try {
      const formatter = new Intl.DateTimeFormat('en-IN', {
        timeZone: 'Asia/Kolkata',
        day: '2-digit',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        hour12: true,
      });
      const parts = formatter.formatToParts(d);
      const day = parts.find((p) => p.type === 'day')?.value || String(d.getDate()).padStart(2, '0');
      const month = parts.find((p) => p.type === 'month')?.value || 'Aug';
      const year = parts.find((p) => p.type === 'year')?.value || String(d.getFullYear());
      const hour = parts.find((p) => p.type === 'hour')?.value || '12';
      const minute = parts.find((p) => p.type === 'minute')?.value || '00';
      const dayPeriod = (parts.find((p) => p.type === 'dayPeriod')?.value || 'AM').toUpperCase();

      return `${day} ${month} ${year}, ${hour}:${minute} ${dayPeriod}`;
    } catch {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      const day = String(d.getDate()).padStart(2, '0');
      const month = months[d.getMonth()];
      const year = d.getFullYear();
      let hours = d.getHours();
      const minutes = String(d.getMinutes()).padStart(2, '0');
      const ampm = hours >= 12 ? 'PM' : 'AM';
      hours = hours % 12 || 12;
      const hourStr = String(hours).padStart(2, '0');
      return `${day} ${month} ${year}, ${hourStr}:${minutes} ${ampm}`;
    }
  }

  /**
   * Admin: Update status, assigned cadre, and remarks of a complaint
   */
  static async updateComplaintStatus(
    id: string, 
    data: { 
      status?: any; 
      assignedCadreId?: string | null; 
      adminRemarks?: string | null; 
      statusReason?: string | null; 
    }
  ) {
    const complaint = await prisma.complaint.findUnique({ where: { id } });
    if (!complaint) {
      throw new AppError('Complaint not found', 404);
    }

    const updateData: any = {};
    const normalizedStatus = this.normalizeStatus(data.status);

    if (normalizedStatus) {
      updateData.status = normalizedStatus;
    }
    if (data.assignedCadreId !== undefined) {
      updateData.assignedCadreId = data.assignedCadreId || null;
    }
    if (data.adminRemarks !== undefined) {
      updateData.adminRemarks = data.adminRemarks;
    }
    if (data.statusReason !== undefined) {
      updateData.statusReason = data.statusReason;
    }

    // Timeline Configuration mapping
    const stepDefinitions: Record<string, { step: number; titleEn: string; titleTa: string }> = {
      SUBMITTED: {
        step: 1,
        titleEn: '1. Grievance Registered by Citizen',
        titleTa: '1. மனுதாரரால் புகார் பதிவு செய்யப்பட்டது',
      },
      UNDER_REVIEW: {
        step: 2,
        titleEn: '2. Grievance Under Review',
        titleTa: '2. சட்டமன்ற உறுப்பினர் அலுவலகத்தில் பரிசீலனை',
      },
      OFFICER_ASSIGNED: {
        step: 3,
        titleEn: '3. Officer Assigned for Action',
        titleTa: '3. களப் பொறுப்பாளர் ஆய்வு பணி ஒதுக்கீடு',
      },
      IN_PROGRESS: {
        step: 4,
        titleEn: '4. Action in Progress',
        titleTa: '4. களப்பணிகள் நடைபெற்று வருகின்றன',
      },
      RESOLVED: {
        step: 5,
        titleEn: '5. Grievance Successfully Resolved',
        titleTa: '5. புகார் வெற்றிகரமாக தீர்க்கப்பட்டது',
      },
      REJECTED: {
        step: 6,
        titleEn: '6. Grievance Rejected / Closed',
        titleTa: '6. புகார் பரிசீலிக்கப்பட்டு முடித்து வைக்கப்பட்டது',
      },
      OTHERS: {
        step: 99,
        titleEn: 'Official Notice / Administrative Update',
        titleTa: 'நிர்வாக அறிவிப்பு / காரண விளக்கம்',
      },
    };

    // Standard sequence of stages
    const progressiveStages = ['SUBMITTED', 'UNDER_REVIEW', 'OFFICER_ASSIGNED', 'IN_PROGRESS', 'RESOLVED'];

    // Load existing events
    let events: any[] = [];
    if (Array.isArray(complaint.timelineEvents) && (complaint.timelineEvents as any[]).length > 0) {
      events = [...(complaint.timelineEvents as any[])];
    } else {
      events = [
        {
          step: 1,
          status: 'SUBMITTED',
          titleEn: stepDefinitions.SUBMITTED.titleEn,
          titleTa: stepDefinitions.SUBMITTED.titleTa,
          date: this.formatTimelineDate(complaint.createdAt),
          isCompleted: true,
          isNotice: false,
        },
      ];
    }

    const nowStr = this.formatTimelineDate();
    const notes = (data.statusReason && data.statusReason.trim()) || (data.adminRemarks && data.adminRemarks.trim()) || undefined;

    // Helper: Determine the active stage step number (1=SUBMITTED, 2=UNDER_REVIEW, 3=OFFICER_ASSIGNED, 4=IN_PROGRESS, 5=RESOLVED)
    const getActiveStageStep = (): number => {
      const standardSteps = events.filter((e) => !e.isNotice && typeof e.step === 'number' && e.step <= 10);
      if (standardSteps.length === 0) return 1;
      return Math.max(...standardSteps.map((e) => e.step));
    };

    if (normalizedStatus && stepDefinitions[normalizedStatus]) {
      if (normalizedStatus === 'OTHERS') {
        // Keep existing complaint status or set to OTHERS, but place notice right after active stage
        const currentStageStep = getActiveStageStep();
        const existingNoticesAtThisStage = events.filter(
          (e) => e.isNotice && typeof e.step === 'number' && Math.floor(e.step) === currentStageStep
        );
        const noticeStep = Number((currentStageStep + (existingNoticesAtThisStage.length + 1) * 0.1).toFixed(2));

        events.push({
          step: noticeStep,
          status: 'OTHERS',
          titleEn: 'Official Notice / Reason for Delay',
          titleTa: 'நிர்வாக அறிவிப்பு / தாமத விளக்கம்',
          notes: notes || 'Administrative notice issued',
          date: nowStr,
          isCompleted: true,
          isNotice: true,
        });

        // Don't downgrade complaint status if already progressed
        updateData.status = complaint.status || 'SUBMITTED';
      } else {
        const targetIndex = progressiveStages.indexOf(normalizedStatus);

        if (targetIndex >= 0) {
          // Ensure all progressive stages up to targetIndex exist in timeline
          for (let i = 0; i <= targetIndex; i++) {
            const st = progressiveStages[i];
            const def = stepDefinitions[st];
            const existingIdx = events.findIndex((e) => e.status === st && !e.isNotice);

            if (existingIdx >= 0) {
              // If it's the target step being updated now, refresh its timestamp & notes
              if (st === normalizedStatus) {
                events[existingIdx] = {
                  ...events[existingIdx],
                  date: nowStr,
                  isCompleted: true,
                  ...(notes ? { notes } : {}),
                };
              }
            } else {
              // Add missing stage
              events.push({
                step: def.step,
                status: st,
                titleEn: def.titleEn,
                titleTa: def.titleTa,
                date: nowStr,
                isCompleted: true,
                isNotice: false,
                ...(st === normalizedStatus && notes ? { notes } : {}),
              });
            }
          }
        } else {
          // For REJECTED
          const def = stepDefinitions[normalizedStatus];
          events.push({
            step: def.step,
            status: normalizedStatus,
            titleEn: def.titleEn,
            titleTa: def.titleTa,
            date: nowStr,
            isCompleted: true,
            isNotice: false,
            ...(notes ? { notes } : {}),
          });
        }
      }
    } else if (data.statusReason && data.statusReason.trim().length > 0) {
      // Standalone delay/administrative notice
      const currentStageStep = getActiveStageStep();
      const existingNoticesAtThisStage = events.filter(
        (e) => e.isNotice && typeof e.step === 'number' && Math.floor(e.step) === currentStageStep
      );
      const noticeStep = Number((currentStageStep + (existingNoticesAtThisStage.length + 1) * 0.1).toFixed(2));

      events.push({
        step: noticeStep,
        status: 'OTHERS',
        titleEn: 'Official Notice / Reason for Delay',
        titleTa: 'நிர்வாக அறிவிப்பு / தாமத விளக்கம்',
        notes: data.statusReason.trim(),
        date: nowStr,
        isCompleted: true,
        isNotice: true,
      });
    }

    // Sort events strictly by step number (e.g., 1 -> 1.1 -> 2 -> 2.1 -> 3 -> 4 -> 5)
    events.sort((a, b) => (Number(a.step) || 0) - (Number(b.step) || 0));

    updateData.timelineEvents = events;

    const updatedComplaint = await prisma.complaint.update({
      where: { id },
      data: updateData,
      include: {
        user: {
          select: {
            id: true,
            userCode: true,
            fullName: true,
            mobile: true,
            fcmToken: true,
          },
        },
        assignedCadre: true,
      },
    });

    // 🚀 Automatically push notification to citizen's mobile phone
    if (normalizedStatus) {
      NotificationService.sendComplaintStatusPush({
        userId: updatedComplaint.userId,
        referenceId: updatedComplaint.referenceId,
        status: normalizedStatus,
        cadreName: updatedComplaint.assignedCadre?.name,
        remarks: data.adminRemarks || data.statusReason || undefined,
      }).catch((err) => {
        console.error('Background automated push notification error:', err);
      });
    }

    return updatedComplaint;
  }

  /**
   * Admin: Delete a complaint
   */
  static async deleteComplaint(id: string) {
    const complaint = await prisma.complaint.findUnique({ where: { id } });
    if (!complaint) {
      throw new AppError('Complaint not found', 404);
    }
    return prisma.complaint.delete({
      where: { id },
    });
  }
}
