import { Response, NextFunction } from 'express';
import { AuthRequest } from '../../middleware/auth';
export declare const getKnowledgeMap: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const getConceptCard: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const getPreviewTest: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const submitPreviewTest: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const getPersonalizedReview: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
//# sourceMappingURL=preview.controller.d.ts.map