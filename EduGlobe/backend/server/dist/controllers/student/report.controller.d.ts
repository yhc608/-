import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth';
export declare const getLearningReport: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const getWeakPoints: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const getAbilityRadar: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const getPersonalizedPath: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
//# sourceMappingURL=report.controller.d.ts.map