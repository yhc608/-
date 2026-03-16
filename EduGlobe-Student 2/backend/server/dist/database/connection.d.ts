import mysql from 'mysql2/promise';
export declare function connectDatabase(): Promise<mysql.Pool>;
export declare function getPool(): mysql.Pool;
export declare function query<T = any>(sql: string, params?: any[]): Promise<T>;
export declare function transaction<T>(callback: (connection: mysql.PoolConnection) => Promise<T>): Promise<T>;
//# sourceMappingURL=connection.d.ts.map