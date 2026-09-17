import { Request, Response, NextFunction } from 'express';
import { ComplaintService } from '../services/complaint.service';
import { convertToWebP } from '../utils/image-processor';

export class ComplaintController {
  /**
   * POST /api/v1/complaints/upload (Upload single proof image with WebP optimization)
   */
  static async uploadAttachment(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const files: Express.Multer.File[] = [];
      if (req.file) {
        files.push(req.file);
      } else if (req.files) {
        if (Array.isArray(req.files)) {
          files.push(...req.files);
        } else {
          for (const key of Object.keys(req.files)) {
            const val = (req.files as any)[key];
            if (Array.isArray(val)) {
              files.push(...val);
            } else if (val) {
              files.push(val);
            }
          }
        }
      }

      if (files.length === 0) {
        res.status(400).json({ success: false, message: 'No image file uploaded' });
        return;
      }

      const host = req.get('host') || 'localhost:4000';
      const protocol = req.protocol || 'http';

      // Process all uploaded files with WebP optimization in parallel
      const processedList = await Promise.all(
        files.map(async (file) => {
          const { filename, size } = await convertToWebP(file.path, {
            maxWidth: 1280,
            maxHeight: 1280,
            quality: 80,
          });
          const fileUrl = `${protocol}://${host}/uploads/complaints/${filename}`;
          return {
            filename,
            originalName: file.originalname,
            size,
            url: fileUrl,
          };
        })
      );

      if (processedList.length === 1) {
        res.status(200).json({
          success: true,
          message: 'Image uploaded and optimized to WebP successfully',
          data: {
            filename: processedList[0].filename,
            originalName: processedList[0].originalName,
            size: processedList[0].size,
            url: processedList[0].url,
            filenames: processedList[0].filename,
            urls: processedList[0].url,
          },
        });
      } else {
        const filenamesStr = processedList.map((p) => p.filename).join(',');
        const urlsStr = processedList.map((p) => p.url).join(',');
        res.status(200).json({
          success: true,
          message: `${processedList.length} images uploaded and optimized to WebP successfully`,
          data: {
            filename: filenamesStr,
            url: urlsStr,
            filenames: filenamesStr,
            urls: urlsStr,
            files: processedList,
          },
        });
      }
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/complaints/register
   */
  static async register(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      // If citizen is authenticated, ensure complaint is bound to their authenticated userId
      const payload = { ...req.body };
      if (req.user?.userId && req.user.role === 'CITIZEN') {
        payload.userId = req.user.userId;
      }

      const complaint = await ComplaintService.registerComplaint(payload);
      res.status(201).json({
        success: true,
        message: 'Complaint registered successfully',
        data: complaint,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/v1/complaints/my-complaints?userId=xxx (IDOR protected)
   */
  static async getMyComplaints(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      // If authenticated as citizen, strictly use authenticated userId
      let userId: string | undefined;
      if (req.user?.role === 'CITIZEN') {
        userId = req.user.userId;
      } else {
        userId = (req.query.userId as string) || (req.headers['x-user-id'] as string) || req.user?.userId;
      }

      if (!userId) {
        res.status(400).json({ success: false, message: 'User ID is required' });
        return;
      }

      const complaints = await ComplaintService.getCitizenComplaints(userId);
      res.status(200).json({
        success: true,
        count: complaints.length,
        data: complaints,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/v1/complaints/track/:referenceId (Supports Reference ID & Mobile Number)
   */
  static async track(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const query = String(req.params.referenceId);
      const complaints = await ComplaintService.trackComplaints(query);

      if (!complaints || complaints.length === 0) {
        res.status(404).json({
          success: false,
          message: 'No complaints found for this Reference ID or Mobile Number',
          data: [],
        });
        return;
      }

      res.status(200).json({
        success: true,
        count: complaints.length,
        data: complaints,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/v1/complaints/all (Admin / MLA Office only)
   */
  static async getAll(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { status, category, village } = req.query;
      const complaints = await ComplaintService.getAllComplaints({
        status: status as any,
        category: category as string,
        village: village as string,
      });
      res.status(200).json({
        success: true,
        count: complaints.length,
        data: complaints,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * PATCH /api/v1/complaints/:id/status (Admin / MLA Office only)
   */
  static async updateStatus(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = String(req.params.id);
      const { status, assignedCadreId, adminRemarks, statusReason } = req.body;
      if (!status) {
        res.status(400).json({ success: false, message: 'Status is required' });
        return;
      }

      const updated = await ComplaintService.updateComplaintStatus(id, {
        status,
        assignedCadreId,
        adminRemarks,
        statusReason,
      });
      res.status(200).json({
        success: true,
        message: 'Complaint status updated successfully',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * DELETE /api/v1/complaints/:id (Admin / MLA Office only)
   */
  static async delete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = String(req.params.id);
      await ComplaintService.deleteComplaint(id);
      res.status(200).json({
        success: true,
        message: 'Complaint deleted successfully',
      });
    } catch (error) {
      next(error);
    }
  }
}
