import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth';
export declare const joinClassroom: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const askQuestion: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const submitInteraction: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const getClassroomStatus: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const playGame: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const submitGameResult: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
//# sourceMappingURL=classroom.controller.d.ts.map