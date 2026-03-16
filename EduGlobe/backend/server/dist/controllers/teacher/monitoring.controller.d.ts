import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth';
export declare const getClassroomMonitoring: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const getInteractionStats: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const getHotQuestions: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const getTeachingPaceSuggestion: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
//# sourceMappingURL=monitoring.controller.d.ts.map