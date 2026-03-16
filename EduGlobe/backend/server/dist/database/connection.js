"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.connectDatabase = connectDatabase;
exports.getPool = getPool;
exports.query = query;
exports.transaction = transaction;
const promise_1 = __importDefault(require("mysql2/promise"));
const logger_1 = require("../utils/logger");
let pool;
async function connectDatabase() {
    try {
        pool = promise_1.default.createPool({
            host: process.env.DB_HOST || 'localhost',
            port: parseInt(process.env.DB_PORT || '3306'),
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || '',
            database: process.env.DB_NAME || 'eduglobe_db',
            connectionLimit: parseInt(process.env.DB_CONNECTION_LIMIT || '10'),
            waitForConnections: true,
            queueLimit: 0,
            enableKeepAlive: true,
            keepAliveInitialDelay: 0,
            charset: 'utf8mb4',
        });
        // 测试连接
        const connection = await pool.getConnection();
        logger_1.logger.info('数据库连接池创建成功');
        connection.release();
        return pool;
    }
    catch (error) {
        logger_1.logger.error('数据库连接失败:', error);
        throw error;
    }
}
function getPool() {
    if (!pool) {
        throw new Error('数据库连接池未初始化');
    }
    return pool;
}
async function query(sql, params) {
    const connection = await pool.getConnection();
    try {
        const [rows] = await connection.execute(sql, params);
        return rows;
    }
    finally {
        connection.release();
    }
}
async function transaction(callback) {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        const result = await callback(connection);
        await connection.commit();
        return result;
    }
    catch (error) {
        await connection.rollback();
        throw error;
    }
    finally {
        connection.release();
    }
}
//# sourceMappingURL=connection.js.map