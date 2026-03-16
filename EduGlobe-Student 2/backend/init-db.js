const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

async function initDatabase() {
    let connection;
    
    try {
        // 首先连接到 MySQL（不指定数据库）
        console.log('正在连接到 MySQL...');
        connection = await mysql.createConnection({
            host: process.env.DB_HOST || 'localhost',
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD,
            multipleStatements: true,
            port: process.env.DB_PORT || 3306
        });
        
        console.log('✓ MySQL 连接成功');
        
        // 读取 SQL 文件
        const sqlFile = path.join(__dirname, 'database', 'schema.sql');
        console.log('正在读取 schema.sql...');
        const sql = fs.readFileSync(sqlFile, 'utf8');
        
        // 执行 SQL
        console.log('正在创建数据库和表...');
        await connection.query(sql);
        
        console.log('✓ 数据库初始化成功！');
        console.log('✓ 数据库名称: eduglobe_db');
        
    } catch (error) {
        console.error('❌ 数据库初始化失败:');
        console.error(error.message);
        process.exit(1);
    } finally {
        if (connection) {
            await connection.end();
        }
    }
}

initDatabase();
