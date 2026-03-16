import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth';
export declare const getAssignmentsToGrade: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const gradeAssignment: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const batchGrade: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const recognizeHandDrawnMap: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
//# sourceMappingURL=grading.controller.d.ts.map