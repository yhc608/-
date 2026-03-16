import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth';
export declare const getTeachingDashboard: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const getClassSituation: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const getStudentAnalysis: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const exportTeachingData: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
//# sourceMappingURL=dashboard.controller.d.ts.map