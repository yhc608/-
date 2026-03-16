-- ========================================
-- EduGlobe 四大功能模块数据库表设计
-- 包含：经纬瞰政、赛博实验、情景互动、AI地理伴学
-- ========================================

USE eduglobe_db;

-- ========================================
-- 一、经纬瞰政（时政热点地理解读）
-- ========================================

-- 时政热点表
CREATE TABLE IF NOT EXISTS geopolitics_hotspots (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '热点ID',
    title VARCHAR(200) NOT NULL COMMENT '热点标题',
    summary TEXT COMMENT '摘要',
    content LONGTEXT COMMENT '详细内容',
    source VARCHAR(100) COMMENT '来源（新华社、人民日报等）',
    source_url VARCHAR(500) COMMENT '原文链接',
    publish_date DATETIME COMMENT '发布时间',
    category VARCHAR(50) COMMENT '分类（一带一路、碳达峰、自然灾害等）',
    region VARCHAR(100) COMMENT '涉及地区',
    latitude DECIMAL(10, 6) COMMENT '纬度',
    longitude DECIMAL(11, 6) COMMENT '经度',
    cover_image VARCHAR(500) COMMENT '封面图',
    view_count INT DEFAULT 0 COMMENT '浏览量',
    like_count INT DEFAULT 0 COMMENT '点赞数',
    status ENUM('draft', 'published', 'archived') DEFAULT 'published' COMMENT '状态',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_region (region),
    INDEX idx_publish_date (publish_date),
    FULLTEXT idx_title_content (title, content)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='时政热点表';

-- 热点知识点关联表
CREATE TABLE IF NOT EXISTS geopolitics_knowledge_links (
    id INT PRIMARY KEY AUTO_INCREMENT,
    hotspot_id INT NOT NULL COMMENT '热点ID',
    knowledge_node_id INT NOT NULL COMMENT '知识点ID',
    relevance_score DECIMAL(3, 2) DEFAULT 0.8 COMMENT '相关度评分(0-1)',
    analysis_content TEXT COMMENT '地理分析内容',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hotspot_id) REFERENCES geopolitics_hotspots(id) ON DELETE CASCADE,
    FOREIGN KEY (knowledge_node_id) REFERENCES knowledge_nodes(id) ON DELETE CASCADE,
    INDEX idx_hotspot (hotspot_id),
    INDEX idx_knowledge (knowledge_node_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='热点知识点关联表';

-- 热点思维训练题目表
CREATE TABLE IF NOT EXISTS geopolitics_questions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    hotspot_id INT NOT NULL COMMENT '热点ID',
    question_text TEXT NOT NULL COMMENT '问题内容',
    question_type ENUM('open', 'analysis', 'reasoning') DEFAULT 'analysis' COMMENT '题型',
    difficulty ENUM('easy', 'medium', 'hard') DEFAULT 'medium' COMMENT '难度',
    reference_answer TEXT COMMENT '参考答案',
    answer_framework TEXT COMMENT '答题框架',
    scoring_criteria JSON COMMENT '评分标准',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hotspot_id) REFERENCES geopolitics_hotspots(id) ON DELETE CASCADE,
    INDEX idx_hotspot (hotspot_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='热点思维训练题目表';

-- 学生热点答题记录表
CREATE TABLE IF NOT EXISTS geopolitics_answer_records (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL COMMENT '用户ID',
    question_id INT NOT NULL COMMENT '题目ID',
    answer_content TEXT COMMENT '学生答案',
    ai_feedback TEXT COMMENT 'AI批改反馈',
    score DECIMAL(5, 2) COMMENT '得分',
    thinking_path JSON COMMENT '思维路径图数据',
    submit_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES geopolitics_questions(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_question (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生热点答题记录表';

-- ========================================
-- 二、赛博实验（地理虚拟实验室）
-- ========================================

-- 虚拟实验模板表
CREATE TABLE IF NOT EXISTS cyber_lab_templates (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL COMMENT '实验名称',
    category VARCHAR(50) COMMENT '分类（自然地理、人文地理、环境）',
    sub_category VARCHAR(100) COMMENT '子分类（火山、水循环、城市规划等）',
    description TEXT COMMENT '实验简介',
    objectives TEXT COMMENT '实验目的',
    principles TEXT COMMENT '原理说明',
    duration INT DEFAULT 30 COMMENT '预计时长(分钟)',
    difficulty ENUM('easy', 'medium', 'hard') DEFAULT 'medium',
    scene_config JSON COMMENT '场景配置（3D模型、素材路径等）',
    parameters JSON COMMENT '可调参数配置',
    guide_steps JSON COMMENT '操作步骤指南',
    knowledge_points TEXT COMMENT '关联知识点',
    cover_image VARCHAR(500),
    video_intro VARCHAR(500) COMMENT '介绍视频',
    view_count INT DEFAULT 0,
    complete_count INT DEFAULT 0 COMMENT '完成人数',
    rating DECIMAL(2, 1) DEFAULT 5.0 COMMENT '评分',
    status ENUM('draft', 'published', 'maintenance') DEFAULT 'published',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category, sub_category),
    INDEX idx_difficulty (difficulty)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='虚拟实验模板表';

-- 学生实验记录表
CREATE TABLE IF NOT EXISTS cyber_lab_records (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    template_id INT NOT NULL,
    start_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    end_time DATETIME,
    duration INT COMMENT '实际时长(秒)',
    status ENUM('ongoing', 'completed', 'abandoned') DEFAULT 'ongoing',
    completion_rate DECIMAL(5, 2) DEFAULT 0 COMMENT '完成度(%)',
    operation_data JSON COMMENT '操作数据记录',
    experiment_results JSON COMMENT '实验结果数据',
    data_charts JSON COMMENT '数据图表配置',
    report_content TEXT COMMENT '实验报告',
    score DECIMAL(5, 2) COMMENT '实验得分',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (template_id) REFERENCES cyber_lab_templates(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_template (template_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生实验记录表';

-- 实验数据快照表（记录实验过程中的数据变化）
CREATE TABLE IF NOT EXISTS cyber_lab_data_snapshots (
    id INT PRIMARY KEY AUTO_INCREMENT,
    record_id INT NOT NULL COMMENT '实验记录ID',
    timestamp INT NOT NULL COMMENT '时间戳(秒)',
    parameter_values JSON NOT NULL COMMENT '参数值',
    observation_data JSON COMMENT '观测数据',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (record_id) REFERENCES cyber_lab_records(id) ON DELETE CASCADE,
    INDEX idx_record (record_id),
    INDEX idx_timestamp (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='实验数据快照表';

-- ========================================
-- 三、情景互动（第一视角探索）
-- ========================================

-- 角色库表
CREATE TABLE IF NOT EXISTS scenario_roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL COMMENT '角色名称',
    title VARCHAR(200) COMMENT '角色称号',
    category ENUM('historical', 'scientist', 'explorer', 'professional', 'modern') 
        DEFAULT 'explorer' COMMENT '角色类型',
    description TEXT COMMENT '角色介绍',
    background_story TEXT COMMENT '背景故事',
    avatar VARCHAR(500) COMMENT '头像',
    model_path VARCHAR(500) COMMENT '3D模型路径',
    special_abilities JSON COMMENT '特殊能力',
    initial_items JSON COMMENT '初始道具',
    voice_pack VARCHAR(500) COMMENT '语音包路径',
    unlock_condition VARCHAR(200) COMMENT '解锁条件',
    is_locked BOOLEAN DEFAULT FALSE,
    popularity INT DEFAULT 0 COMMENT '人气值',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色库表';

-- 场景库表
CREATE TABLE IF NOT EXISTS scenario_scenes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL COMMENT '场景名称',
    location VARCHAR(200) COMMENT '地理位置',
    category VARCHAR(50) COMMENT '场景类型',
    climate_type VARCHAR(50) COMMENT '气候类型',
    description TEXT COMMENT '场景描述',
    geographical_features TEXT COMMENT '地理特征',
    scene_config JSON COMMENT '场景配置（模型、光照、音效等）',
    vr_support BOOLEAN DEFAULT FALSE COMMENT '是否支持VR',
    ar_support BOOLEAN DEFAULT FALSE COMMENT '是否支持AR',
    interactions JSON COMMENT '可交互物体列表',
    environment_effects JSON COMMENT '环境效果（天气、声音等）',
    mini_map VARCHAR(500) COMMENT '小地图',
    preview_image VARCHAR(500),
    download_size INT COMMENT '资源包大小(MB)',
    min_level INT DEFAULT 1 COMMENT '最低等级要求',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_location (location)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='场景库表';

-- 任务库表
CREATE TABLE IF NOT EXISTS scenario_tasks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL COMMENT '任务标题',
    scene_id INT COMMENT '所属场景ID',
    role_id INT COMMENT '推荐角色ID',
    task_type ENUM('exploration', 'collection', 'observation', 'decision', 'design') 
        DEFAULT 'exploration',
    description TEXT COMMENT '任务描述',
    objectives JSON COMMENT '任务目标列表',
    story_branches JSON COMMENT '剧情分支配置',
    interaction_points JSON COMMENT '交互点位配置',
    rewards JSON COMMENT '奖励配置',
    knowledge_points TEXT COMMENT '关联知识点',
    difficulty ENUM('easy', 'medium', 'hard') DEFAULT 'medium',
    estimated_duration INT DEFAULT 20 COMMENT '预计时长(分钟)',
    completion_criteria JSON COMMENT '完成标准',
    hint_system JSON COMMENT '提示系统配置',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (scene_id) REFERENCES scenario_scenes(id) ON DELETE SET NULL,
    FOREIGN KEY (role_id) REFERENCES scenario_roles(id) ON DELETE SET NULL,
    INDEX idx_scene (scene_id),
    INDEX idx_type (task_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='任务库表';

-- 学生任务进度表
CREATE TABLE IF NOT EXISTS scenario_user_progress (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    task_id INT NOT NULL,
    role_id INT COMMENT '使用的角色',
    start_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    end_time DATETIME,
    status ENUM('ongoing', 'completed', 'failed', 'abandoned') DEFAULT 'ongoing',
    current_step INT DEFAULT 0 COMMENT '当前步骤',
    progress_data JSON COMMENT '进度数据',
    decisions_made JSON COMMENT '已做决策记录',
    collected_items JSON COMMENT '收集的物品',
    exploration_path JSON COMMENT '探索路径数据',
    score DECIMAL(5, 2) COMMENT '评分',
    achievements JSON COMMENT '获得成就',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (task_id) REFERENCES scenario_tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES scenario_roles(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_task (task_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生任务进度表';

-- ========================================
-- 四、AI地理伴学（智能学习助手）
-- ========================================

-- AI学习会话表
CREATE TABLE IF NOT EXISTS ai_study_sessions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    session_type ENUM('qa', 'guidance', 'planning', 'review') DEFAULT 'qa' COMMENT '会话类型',
    start_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    end_time DATETIME,
    message_count INT DEFAULT 0 COMMENT '消息数量',
    topics JSON COMMENT '涉及话题标签',
    satisfaction_score INT COMMENT '满意度评分(1-5)',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_type (session_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI学习会话表';

-- AI对话消息表
CREATE TABLE IF NOT EXISTS ai_chat_messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    session_id INT NOT NULL,
    sender ENUM('user', 'ai') NOT NULL,
    content_type ENUM('text', 'image', 'audio', 'document') DEFAULT 'text',
    content TEXT NOT NULL COMMENT '消息内容',
    content_url VARCHAR(500) COMMENT '附件URL（图片、音频等）',
    metadata JSON COMMENT '元数据（OCR结果、识别标签等）',
    intent VARCHAR(100) COMMENT '意图识别结果',
    confidence DECIMAL(3, 2) COMMENT '置信度',
    related_knowledge JSON COMMENT '关联知识点',
    attachments JSON COMMENT '附件列表',
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES ai_study_sessions(id) ON DELETE CASCADE,
    INDEX idx_session (session_id),
    INDEX idx_timestamp (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI对话消息表';

-- 个性化学习计划表
CREATE TABLE IF NOT EXISTS ai_study_plans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    plan_name VARCHAR(200) COMMENT '计划名称',
    plan_type ENUM('daily', 'weekly', 'exam_prep', 'competition', 'review') DEFAULT 'weekly',
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    target_goal TEXT COMMENT '学习目标',
    target_score DECIMAL(5, 2) COMMENT '目标分数',
    weak_points JSON COMMENT '薄弱知识点列表',
    study_schedule JSON COMMENT '学习安排',
    recommended_resources JSON COMMENT '推荐学习资源',
    daily_tasks JSON COMMENT '每日任务列表',
    status ENUM('active', 'completed', 'paused', 'cancelled') DEFAULT 'active',
    completion_rate DECIMAL(5, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_status (status),
    INDEX idx_date (start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='个性化学习计划表';

-- 学习数据分析表
CREATE TABLE IF NOT EXISTS ai_study_analytics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    date DATE NOT NULL COMMENT '日期',
    study_duration INT DEFAULT 0 COMMENT '学习时长(分钟)',
    module_usage JSON COMMENT '各模块使用情况',
    knowledge_mastery JSON COMMENT '知识掌握度数据',
    practice_count INT DEFAULT 0 COMMENT '练习题数',
    correct_rate DECIMAL(5, 2) COMMENT '正确率',
    weak_knowledge JSON COMMENT '薄弱知识点',
    progress_score DECIMAL(5, 2) COMMENT '进步分数',
    achievements JSON COMMENT '当日成就',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_date (user_id, date),
    UNIQUE KEY uk_user_date (user_id, date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习数据分析表';

-- 错题本表
CREATE TABLE IF NOT EXISTS ai_error_notebook (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    question_id INT COMMENT '题目ID',
    question_source VARCHAR(100) COMMENT '题目来源',
    question_content TEXT COMMENT '题目内容',
    student_answer TEXT COMMENT '学生答案',
    correct_answer TEXT COMMENT '正确答案',
    error_type ENUM('concept', 'calculation', 'careless', 'reading') COMMENT '错误类型',
    error_analysis TEXT COMMENT '错误分析',
    knowledge_tags JSON COMMENT '知识点标签',
    weakness_tags JSON COMMENT '薄弱点标签',
    review_count INT DEFAULT 0 COMMENT '复习次数',
    mastered BOOLEAN DEFAULT FALSE COMMENT '是否已掌握',
    last_review_date DATE COMMENT '最后复习日期',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_mastered (mastered),
    INDEX idx_tags (knowledge_tags(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='错题本表';

-- 学习提醒表
CREATE TABLE IF NOT EXISTS ai_study_reminders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    reminder_type ENUM('daily_task', 'review', 'exam', 'plan_update') DEFAULT 'daily_task',
    title VARCHAR(200) NOT NULL,
    content TEXT,
    remind_time DATETIME NOT NULL,
    is_sent BOOLEAN DEFAULT FALSE,
    is_read BOOLEAN DEFAULT FALSE,
    priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
    action_url VARCHAR(500) COMMENT '行动链接',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_time (remind_time),
    INDEX idx_sent (is_sent)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习提醒表';

-- 成就勋章表
CREATE TABLE IF NOT EXISTS ai_achievements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL COMMENT '成就名称',
    description TEXT COMMENT '成就描述',
    icon VARCHAR(500) COMMENT '图标',
    badge_image VARCHAR(500) COMMENT '勋章图片',
    category VARCHAR(50) COMMENT '分类',
    unlock_condition JSON COMMENT '解锁条件',
    points INT DEFAULT 0 COMMENT '积分奖励',
    rarity ENUM('common', 'rare', 'epic', 'legendary') DEFAULT 'common',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='成就勋章表';

-- 用户成就表
CREATE TABLE IF NOT EXISTS ai_user_achievements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    achievement_id INT NOT NULL,
    unlock_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_displayed BOOLEAN DEFAULT TRUE COMMENT '是否展示',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (achievement_id) REFERENCES ai_achievements(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_achievement (user_id, achievement_id),
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户成就表';

-- 家校互通报告表
CREATE TABLE IF NOT EXISTS ai_parent_reports (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    report_type ENUM('daily', 'weekly', 'monthly', 'term') DEFAULT 'weekly',
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    study_summary TEXT COMMENT '学习总结',
    study_data JSON COMMENT '学习数据',
    progress_analysis TEXT COMMENT '进步分析',
    weak_points TEXT COMMENT '薄弱点说明',
    suggestions TEXT COMMENT '学习建议',
    teacher_comments TEXT COMMENT '教师评语',
    is_sent BOOLEAN DEFAULT FALSE,
    send_time DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_date (end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='家校互通报告表';

-- ========================================
-- 创建索引优化查询性能
-- ========================================

-- 为地理位置查询创建空间索引
ALTER TABLE geopolitics_hotspots ADD SPATIAL INDEX idx_location (latitude, longitude);

-- 为时间序列查询优化
CREATE INDEX idx_created_time ON cyber_lab_records(created_at);
CREATE INDEX idx_study_time ON ai_study_analytics(date);

COMMIT;
