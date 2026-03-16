import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth';
export declare const generateLessonPlan: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const saveLessonPlan: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const getLessonPlans: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const getLessonPlanDetail: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const shareLessonPlan: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
//# sourceMappingURL=lesson.controller.d.ts.map