import { Request, Response, NextFunction } from 'express';
export declare const errorHandler: (err: any, req: Request, res: Response, _next: NextFunction) => void;
export declare class AppError extends Error {
    statusCode: number;
    isOperational: boolean;
    constructor(message: string, statusCode?: number);
}
//# sourceMappingURL=errorHandler.d.ts.map