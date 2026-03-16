import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth';
export declare const askMultimodalQuestion: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const getQAHistory: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const rateAnswer: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
//# sourceMappingURL=qa.controller.d.ts.map