import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
export declare const register: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const login: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const logout: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const refreshToken: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const getCurrentUser: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const updateProfile: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
export declare const changePassword: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
//# sourceMappingURL=auth.controller.d.ts.map