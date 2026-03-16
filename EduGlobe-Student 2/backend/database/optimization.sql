-- EduGlobe 数据库性能优化SQL
-- 为现有表添加索引和优化

USE eduglobe_db;

-- ==================== 性能优化索引 ====================

-- 用户表优化
ALTER TABLE users 
  ADD INDEX idx_username_status (username, status),
  ADD INDEX idx_role_status (role, status),
  ADD INDEX idx_last_login (last_login),
  ADD INDEX idx_created_at (created_at);

-- 知识节点表优化
ALTER TABLE knowledge_nodes
  ADD INDEX idx_chapter_section (chapter, section),
  ADD INDEX idx_difficulty (difficulty_level),
  ADD INDEX idx_updated_at (updated_at);

-- 知识关系表优化
ALTER TABLE knowledge_relations
  ADD INDEX idx_source (source_node_id),
  ADD INDEX idx_target (target_node_id),
  ADD INDEX idx_relation_type (relation_type);

-- 课程表优化
ALTER TABLE courses
  ADD INDEX idx_teacher_status (teacher_id, status),
  ADD INDEX idx_class (class_id),
  ADD INDEX idx_start_time (start_time),
  ADD INDEX idx_end_time (end_time);

-- 课堂互动表优化
ALTER TABLE classroom_interactions
  ADD INDEX idx_course_student (course_id, student_id),
  ADD INDEX idx_created_at (created_at),
  ADD INDEX idx_interaction_type (interaction_type);

-- 作业表优化
ALTER TABLE assignments
  ADD INDEX idx_teacher_class (teacher_id, class_id),
  ADD INDEX idx_due_date (due_date),
  ADD INDEX idx_created_at (created_at),
  ADD INDEX idx_status (status);

-- 作业提交表优化
ALTER TABLE assignment_submissions
  ADD INDEX idx_student_assignment (student_id, assignment_id),
  ADD INDEX idx_submit_time (submit_time),
  ADD INDEX idx_graded (is_graded),
  ADD INDEX idx_score (score);

-- 问答记录表优化
ALTER TABLE qa_records
  ADD INDEX idx_student_created (student_id, created_at),
  ADD INDEX idx_knowledge_node (knowledge_node_id),
  ADD INDEX idx_question_type (question_type),
  ADD INDEX idx_rating (rating),
  ADD INDEX idx_created_at (created_at);

-- 学习报告表优化
ALTER TABLE learning_reports
  ADD INDEX idx_student_report (student_id, report_type),
  ADD INDEX idx_date_range (start_date, end_date),
  ADD INDEX idx_generated_at (generated_at);

-- 虚拟实验表优化
ALTER TABLE virtual_experiments
  ADD INDEX idx_type_difficulty (experiment_type, difficulty_level),
  ADD INDEX idx_active (is_active);

-- 实验记录表优化
ALTER TABLE experiment_records
  ADD INDEX idx_student_experiment (student_id, experiment_id),
  ADD INDEX idx_start_time (start_time),
  ADD INDEX idx_completed (is_completed);

-- 地理频道表优化
ALTER TABLE geo_channels
  ADD INDEX idx_type_active (channel_type, is_active),
  ADD INDEX idx_created_at (created_at);

-- 频道帖子表优化
ALTER TABLE channel_posts
  ADD INDEX idx_channel_created (channel_id, created_at),
  ADD INDEX idx_author (author_id),
  ADD INDEX idx_views (views_count),
  ADD INDEX idx_likes (likes_count);

-- 教学资源表优化
ALTER TABLE teaching_resources
  ADD INDEX idx_type_format (resource_type, file_format),
  ADD INDEX idx_uploader (uploader_id),
  ADD INDEX idx_downloads (download_count),
  ADD INDEX idx_created_at (created_at);

-- 教案表优化
ALTER TABLE lesson_plans
  ADD INDEX idx_teacher_grade (teacher_id, grade),
  ADD INDEX idx_chapter (textbook_version, chapter),
  ADD INDEX idx_public (is_public),
  ADD INDEX idx_created_at (created_at);

-- 课堂监控数据表优化
ALTER TABLE classroom_monitoring
  ADD INDEX idx_course_time (course_id, check_time),
  ADD INDEX idx_check_time (check_time);

-- 批改记录表优化
ALTER TABLE grading_records
  ADD INDEX idx_teacher_submission (teacher_id, submission_id),
  ADD INDEX idx_graded_at (graded_at);

-- 教学数据驾驶舱表优化
ALTER TABLE teaching_dashboard
  ADD INDEX idx_teacher_class (teacher_id, class_id),
  ADD INDEX idx_date (date),
  ADD INDEX idx_generated_at (generated_at);

-- ==================== 复合索引优化 ====================

-- 用户学习行为复合索引
ALTER TABLE qa_records
  ADD INDEX idx_student_node_time (student_id, knowledge_node_id, created_at);

-- 作业完成情况复合索引  
ALTER TABLE assignment_submissions
  ADD INDEX idx_assignment_status_score (assignment_id, is_graded, score);

-- 课堂参与度复合索引
ALTER TABLE classroom_interactions
  ADD INDEX idx_course_student_type (course_id, student_id, interaction_type);

-- 实验完成情况复合索引
ALTER TABLE experiment_records
  ADD INDEX idx_experiment_student_complete (experiment_id, student_id, is_completed);

-- ==================== 分区优化（针对大表）====================

-- 对qa_records按月分区（提高历史数据查询性能）
ALTER TABLE qa_records
PARTITION BY RANGE (YEAR(created_at) * 100 + MONTH(created_at)) (
    PARTITION p202601 VALUES LESS THAN (202602),
    PARTITION p202602 VALUES LESS THAN (202603),
    PARTITION p202603 VALUES LESS THAN (202604),
    PARTITION p202604 VALUES LESS THAN (202605),
    PARTITION p202605 VALUES LESS THAN (202606),
    PARTITION p202606 VALUES LESS THAN (202607),
    PARTITION p202607 VALUES LESS THAN (202608),
    PARTITION p202608 VALUES LESS THAN (202609),
    PARTITION p202609 VALUES LESS THAN (202610),
    PARTITION p202610 VALUES LESS THAN (202611),
    PARTITION p202611 VALUES LESS THAN (202612),
    PARTITION p202612 VALUES LESS THAN (202701),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- ==================== 查询优化建议 ====================

-- 1. 常用查询的物化视图

-- 学生学习统计视图
CREATE OR REPLACE VIEW v_student_learning_stats AS
SELECT 
    s.id AS student_id,
    s.username,
    s.real_name,
    COUNT(DISTINCT qa.id) AS question_count,
    COUNT(DISTINCT sub.id) AS assignment_count,
    AVG(sub.score) AS avg_score,
    COUNT(DISTINCT er.id) AS experiment_count,
    MAX(qa.created_at) AS last_active_time
FROM users s
LEFT JOIN qa_records qa ON s.id = qa.student_id
LEFT JOIN assignment_submissions sub ON s.id = sub.student_id
LEFT JOIN experiment_records er ON s.id = er.student_id
WHERE s.role = 'student'
GROUP BY s.id, s.username, s.real_name;

-- 知识点热度统计视图
CREATE OR REPLACE VIEW v_knowledge_node_popularity AS
SELECT 
    kn.id AS node_id,
    kn.name AS node_name,
    kn.chapter,
    kn.section,
    COUNT(DISTINCT qa.id) AS question_count,
    COUNT(DISTINCT asq.id) AS assignment_question_count,
    (COUNT(DISTINCT qa.id) + COUNT(DISTINCT asq.id)) AS total_mentions
FROM knowledge_nodes kn
LEFT JOIN qa_records qa ON kn.id = qa.knowledge_node_id
LEFT JOIN assignment_questions asq ON kn.id = asq.knowledge_node_id
GROUP BY kn.id, kn.name, kn.chapter, kn.section
ORDER BY total_mentions DESC;

-- 班级学习进度视图
CREATE OR REPLACE VIEW v_class_learning_progress AS
SELECT 
    c.id AS class_id,
    c.name AS class_name,
    COUNT(DISTINCT cs.student_id) AS student_count,
    COUNT(DISTINCT a.id) AS total_assignments,
    COUNT(DISTINCT sub.id) AS submitted_assignments,
    ROUND(COUNT(DISTINCT sub.id) * 100.0 / NULLIF(COUNT(DISTINCT a.id) * COUNT(DISTINCT cs.student_id), 0), 2) AS completion_rate,
    AVG(sub.score) AS avg_score
FROM classes c
LEFT JOIN class_students cs ON c.id = cs.class_id AND cs.status = 'active'
LEFT JOIN assignments a ON c.id = a.class_id
LEFT JOIN assignment_submissions sub ON a.id = sub.assignment_id AND sub.student_id = cs.student_id
GROUP BY c.id, c.name;

-- ==================== 数据库配置优化建议 ====================

-- 在my.cnf/my.ini中添加以下配置：

-- [mysqld]
-- # InnoDB Buffer Pool（建议设置为物理内存的50-70%）
-- innodb_buffer_pool_size = 2G
-- innodb_buffer_pool_instances = 4

-- # 查询缓存
-- query_cache_type = 1
-- query_cache_size = 256M

-- # 连接数
-- max_connections = 500
-- max_connect_errors = 1000

-- # 慢查询日志
-- slow_query_log = 1
-- slow_query_log_file = /var/log/mysql/slow.log
-- long_query_time = 2

-- # 二进制日志
-- log_bin = /var/log/mysql/mysql-bin.log
-- expire_logs_days = 7

-- # InnoDB性能优化
-- innodb_flush_log_at_trx_commit = 2
-- innodb_log_buffer_size = 32M
-- innodb_log_file_size = 256M

-- # 临时表
-- tmp_table_size = 256M
-- max_heap_table_size = 256M

-- ==================== 定期维护任务 ====================

-- 1. 每周执行表优化
-- OPTIMIZE TABLE qa_records;
-- OPTIMIZE TABLE assignment_submissions;
-- OPTIMIZE TABLE classroom_interactions;

-- 2. 每月分析表
-- ANALYZE TABLE users;
-- ANALYZE TABLE knowledge_nodes;
-- ANALYZE TABLE courses;

-- 3. 定期清理过期数据（示例：删除2年前的日志数据）
-- DELETE FROM classroom_monitoring WHERE check_time < DATE_SUB(NOW(), INTERVAL 2 YEAR);

-- ==================== 备份策略 ====================

-- 1. 每日全量备份
-- mysqldump -u root -p --all-databases --single-transaction --quick --lock-tables=false > backup_$(date +%Y%m%d).sql

-- 2. 每小时增量备份（使用二进制日志）
-- mysqlbinlog --start-datetime="2026-03-14 00:00:00" --stop-datetime="2026-03-14 01:00:00" mysql-bin.000001 > incremental_backup.sql
