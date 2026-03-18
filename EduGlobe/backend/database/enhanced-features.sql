-- ========================================
-- EduGlobe 四大功能模块增强版数据库表设计
-- 补充和优化：新增标签、评论、多媒体素材等表
-- 创建时间: 2026-03-17
-- ========================================

USE eduglobe_db;

-- ========================================
-- 一、经纬瞰政 - 补充表
-- ========================================

-- 热点标签表
CREATE TABLE IF NOT EXISTS geopolitics_tags (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE COMMENT '标签名称',
    category ENUM('region', 'theme', 'subject', 'level') DEFAULT 'theme' COMMENT '标签类型',
    description VARCHAR(200) COMMENT '标签描述',
    color VARCHAR(20) DEFAULT '#1890ff' COMMENT '标签颜色',
    icon VARCHAR(100) COMMENT '图标',
    usage_count INT DEFAULT 0 COMMENT '使用次数',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='热点标签表';

-- 热点标签关联表
CREATE TABLE IF NOT EXISTS geopolitics_hotspot_tags (
    id INT PRIMARY KEY AUTO_INCREMENT,
    hotspot_id INT NOT NULL,
    tag_id INT NOT NULL,
    FOREIGN KEY (hotspot_id) REFERENCES geopolitics_hotspots(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES geopolitics_tags(id) ON DELETE CASCADE,
    UNIQUE KEY uk_hotspot_tag (hotspot_id, tag_id),
    INDEX idx_hotspot (hotspot_id),
    INDEX idx_tag (tag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='热点标签关联表';

-- 热点多媒体素材表
CREATE TABLE IF NOT EXISTS geopolitics_media (
    id INT PRIMARY KEY AUTO_INCREMENT,
    hotspot_id INT NOT NULL,
    media_type ENUM('image', 'video', 'audio', 'document', 'infographic') NOT NULL,
    title VARCHAR(200) COMMENT '素材标题',
    url VARCHAR(500) NOT NULL COMMENT '资源URL',
    thumbnail VARCHAR(500) COMMENT '缩略图',
    file_size INT COMMENT '文件大小(KB)',
    duration INT COMMENT '时长(秒，视频/音频)',
    caption TEXT COMMENT '说明文字',
    sort_order INT DEFAULT 0 COMMENT '排序',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hotspot_id) REFERENCES geopolitics_hotspots(id) ON DELETE CASCADE,
    INDEX idx_hotspot (hotspot_id),
    INDEX idx_type (media_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='热点多媒体素材表';

-- 热点评论表
CREATE TABLE IF NOT EXISTS geopolitics_comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    hotspot_id INT NOT NULL,
    user_id INT NOT NULL,
    parent_id INT COMMENT '父评论ID（回复时使用）',
    content TEXT NOT NULL COMMENT '评论内容',
    like_count INT DEFAULT 0 COMMENT '点赞数',
    is_pinned BOOLEAN DEFAULT FALSE COMMENT '是否置顶',
    is_deleted BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (hotspot_id) REFERENCES geopolitics_hotspots(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES geopolitics_comments(id) ON DELETE CASCADE,
    INDEX idx_hotspot (hotspot_id),
    INDEX idx_user (user_id),
    INDEX idx_parent (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='热点评论表';

-- 热点收藏表
CREATE TABLE IF NOT EXISTS geopolitics_favorites (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    hotspot_id INT NOT NULL,
    notes TEXT COMMENT '收藏备注',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (hotspot_id) REFERENCES geopolitics_hotspots(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_hotspot (user_id, hotspot_id),
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='热点收藏表';

-- 热点学习轨迹表
CREATE TABLE IF NOT EXISTS geopolitics_learning_path (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    hotspot_id INT NOT NULL,
    view_duration INT DEFAULT 0 COMMENT '浏览时长(秒)',
    scroll_depth INT DEFAULT 0 COMMENT '滚动深度(%)',
    media_viewed JSON COMMENT '查看的媒体ID列表',
    knowledge_clicked JSON COMMENT '点击的知识点ID列表',
    completed BOOLEAN DEFAULT FALSE COMMENT '是否完成阅读',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (hotspot_id) REFERENCES geopolitics_hotspots(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_hotspot (hotspot_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='热点学习轨迹表';

-- ========================================
-- 二、赛博实验 - 补充表
-- ========================================

-- 实验步骤表
CREATE TABLE IF NOT EXISTS cyber_lab_steps (
    id INT PRIMARY KEY AUTO_INCREMENT,
    template_id INT NOT NULL,
    step_number INT NOT NULL COMMENT '步骤序号',
    title VARCHAR(200) NOT NULL COMMENT '步骤标题',
    description TEXT COMMENT '步骤说明',
    operation_type VARCHAR(50) COMMENT '操作类型',
    required_parameters JSON COMMENT '必需参数',
    expected_result TEXT COMMENT '预期结果',
    hints JSON COMMENT '提示信息',
    media_url VARCHAR(500) COMMENT '示范视频/图片',
    is_required BOOLEAN DEFAULT TRUE COMMENT '是否必做',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (template_id) REFERENCES cyber_lab_templates(id) ON DELETE CASCADE,
    INDEX idx_template (template_id),
    INDEX idx_step (step_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='实验步骤表';

-- 实验评价表
CREATE TABLE IF NOT EXISTS cyber_lab_reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    template_id INT NOT NULL,
    rating INT NOT NULL COMMENT '评分(1-5星)',
    difficulty_rating INT COMMENT '难度评价(1-5)',
    clarity_rating INT COMMENT '清晰度评价(1-5)',
    usefulness_rating INT COMMENT '实用性评价(1-5)',
    review_text TEXT COMMENT '评价内容',
    suggestions TEXT COMMENT '改进建议',
    is_anonymous BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (template_id) REFERENCES cyber_lab_templates(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_template (user_id, template_id),
    INDEX idx_template (template_id),
    INDEX idx_rating (rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='实验评价表';

-- 实验协作表（多人协作实验）
CREATE TABLE IF NOT EXISTS cyber_lab_collaborations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    record_id INT NOT NULL COMMENT '实验记录ID',
    room_code VARCHAR(20) UNIQUE NOT NULL COMMENT '房间代码',
    host_user_id INT NOT NULL COMMENT '主持人ID',
    max_participants INT DEFAULT 4 COMMENT '最大参与人数',
    participants JSON COMMENT '参与者ID列表',
    status ENUM('waiting', 'ongoing', 'completed') DEFAULT 'waiting',
    sync_data JSON COMMENT '同步数据',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (record_id) REFERENCES cyber_lab_records(id) ON DELETE CASCADE,
    FOREIGN KEY (host_user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_room (room_code),
    INDEX idx_host (host_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='实验协作表';

-- 实验资源库表
CREATE TABLE IF NOT EXISTS cyber_lab_resources (
    id INT PRIMARY KEY AUTO_INCREMENT,
    template_id INT,
    resource_type ENUM('model_3d', 'texture', 'sound', 'script', 'data', 'document') NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    file_path VARCHAR(500) NOT NULL,
    file_size INT COMMENT '文件大小(KB)',
    version VARCHAR(20),
    is_public BOOLEAN DEFAULT TRUE,
    download_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (template_id) REFERENCES cyber_lab_templates(id) ON DELETE SET NULL,
    INDEX idx_type (resource_type),
    INDEX idx_template (template_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='实验资源库表';

-- ========================================
-- 三、情景互动 - 补充表
-- ========================================

-- 角色装备表
CREATE TABLE IF NOT EXISTS scenario_role_equipment (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    category ENUM('tool', 'clothing', 'accessory', 'consumable') DEFAULT 'tool',
    description TEXT,
    icon VARCHAR(500),
    model_path VARCHAR(500),
    effects JSON COMMENT '效果属性',
    rarity ENUM('common', 'uncommon', 'rare', 'epic', 'legendary') DEFAULT 'common',
    acquire_method TEXT COMMENT '获取方式',
    price INT COMMENT '价格（积分）',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色装备表';

-- 用户角色背包表
CREATE TABLE IF NOT EXISTS scenario_user_inventory (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    equipment_id INT NOT NULL,
    quantity INT DEFAULT 1,
    is_equipped BOOLEAN DEFAULT FALSE,
    acquired_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES scenario_roles(id) ON DELETE CASCADE,
    FOREIGN KEY (equipment_id) REFERENCES scenario_role_equipment(id) ON DELETE CASCADE,
    INDEX idx_user_role (user_id, role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户角色背包表';

-- 场景天气系统表
CREATE TABLE IF NOT EXISTS scenario_weather_system (
    id INT PRIMARY KEY AUTO_INCREMENT,
    scene_id INT NOT NULL,
    weather_type ENUM('sunny', 'cloudy', 'rainy', 'snowy', 'foggy', 'stormy', 'extreme') NOT NULL,
    temperature_range VARCHAR(50) COMMENT '温度范围',
    humidity INT COMMENT '湿度(%)',
    wind_speed INT COMMENT '风速',
    visibility INT COMMENT '可见度',
    effects_on_gameplay JSON COMMENT '对游戏的影响',
    animation_config JSON COMMENT '天气动画配置',
    sound_effects JSON COMMENT '音效配置',
    duration INT DEFAULT 300 COMMENT '持续时间(秒)',
    probability DECIMAL(5, 2) DEFAULT 10.00 COMMENT '出现概率(%)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (scene_id) REFERENCES scenario_scenes(id) ON DELETE CASCADE,
    INDEX idx_scene (scene_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='场景天气系统表';

-- 场景NPC表
CREATE TABLE IF NOT EXISTS scenario_npcs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    scene_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    npc_type ENUM('guide', 'merchant', 'expert', 'villager', 'helper') DEFAULT 'guide',
    position_x DECIMAL(10, 3),
    position_y DECIMAL(10, 3),
    position_z DECIMAL(10, 3),
    model_path VARCHAR(500),
    avatar VARCHAR(500),
    dialogues JSON COMMENT '对话内容',
    interaction_type VARCHAR(50) COMMENT '交互类型',
    provides_services JSON COMMENT '提供的服务',
    knowledge_area VARCHAR(100) COMMENT '知识领域',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (scene_id) REFERENCES scenario_scenes(id) ON DELETE CASCADE,
    INDEX idx_scene (scene_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='场景NPC表';

-- 探索发现表（地标、知识点发现记录）
CREATE TABLE IF NOT EXISTS scenario_discoveries (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    scene_id INT NOT NULL,
    discovery_type ENUM('landmark', 'species', 'mineral', 'phenomenon', 'artifact') NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    position JSON COMMENT '发现位置',
    photo VARCHAR(500) COMMENT '拍摄的照片',
    knowledge_points JSON COMMENT '关联知识点',
    rarity ENUM('common', 'uncommon', 'rare', 'epic', 'legendary') DEFAULT 'common',
    points INT DEFAULT 0 COMMENT '获得积分',
    discovered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (scene_id) REFERENCES scenario_scenes(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_scene (scene_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='探索发现表';

-- 任务对话记录表
CREATE TABLE IF NOT EXISTS scenario_task_dialogues (
    id INT PRIMARY KEY AUTO_INCREMENT,
    progress_id INT NOT NULL,
    npc_id INT,
    dialogue_content TEXT NOT NULL,
    player_choice VARCHAR(200) COMMENT '玩家选择',
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (progress_id) REFERENCES scenario_user_progress(id) ON DELETE CASCADE,
    FOREIGN KEY (npc_id) REFERENCES scenario_npcs(id) ON DELETE SET NULL,
    INDEX idx_progress (progress_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='任务对话记录表';

-- ========================================
-- 四、AI地理伴学 - 补充表
-- ========================================

-- AI知识点掌握度评估表
CREATE TABLE IF NOT EXISTS ai_knowledge_mastery (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    knowledge_node_id INT NOT NULL,
    mastery_level ENUM('not_started', 'learning', 'familiar', 'proficient', 'mastered') DEFAULT 'not_started',
    mastery_score DECIMAL(5, 2) DEFAULT 0 COMMENT '掌握度分数(0-100)',
    practice_count INT DEFAULT 0 COMMENT '练习次数',
    correct_count INT DEFAULT 0 COMMENT '正确次数',
    last_practice_date DATE COMMENT '最后练习日期',
    review_priority INT DEFAULT 5 COMMENT '复习优先级(1-10)',
    estimated_review_date DATE COMMENT '建议复习日期',
    learning_time INT DEFAULT 0 COMMENT '学习时长(分钟)',
    notes TEXT COMMENT '学生笔记',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (knowledge_node_id) REFERENCES knowledge_nodes(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_knowledge (user_id, knowledge_node_id),
    INDEX idx_user (user_id),
    INDEX idx_mastery (mastery_level),
    INDEX idx_priority (review_priority)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI知识点掌握度评估表';

-- AI学习建议表
CREATE TABLE IF NOT EXISTS ai_study_suggestions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    suggestion_type ENUM('knowledge_review', 'practice_more', 'difficulty_adjust', 'time_management', 'method_improve') NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    related_knowledge JSON COMMENT '相关知识点',
    recommended_actions JSON COMMENT '推荐行动',
    is_read BOOLEAN DEFAULT FALSE,
    is_adopted BOOLEAN DEFAULT FALSE COMMENT '是否采纳',
    effectiveness_score INT COMMENT '有效性评分(1-5)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME COMMENT '过期时间',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_priority (priority),
    INDEX idx_read (is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI学习建议表';

-- AI智能题目推荐表
CREATE TABLE IF NOT EXISTS ai_question_recommendations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    question_id INT NOT NULL,
    reason TEXT COMMENT '推荐理由',
    recommendation_score DECIMAL(5, 2) COMMENT '推荐分数',
    target_knowledge JSON COMMENT '针对知识点',
    difficulty_match DECIMAL(3, 2) COMMENT '难度匹配度',
    is_completed BOOLEAN DEFAULT FALSE,
    recommended_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_completed (is_completed)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI智能题目推荐表';

-- OCR识别记录表
CREATE TABLE IF NOT EXISTS ai_ocr_records (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    ocr_type ENUM('map', 'chart', 'question', 'text', 'diagram') NOT NULL,
    raw_text TEXT COMMENT '识别原始文本',
    structured_data JSON COMMENT '结构化数据',
    confidence DECIMAL(5, 2) COMMENT '识别置信度',
    processing_time INT COMMENT '处理耗时(毫秒)',
    error_message TEXT COMMENT '错误信息',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_type (ocr_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='OCR识别记录表';

-- 学习资源推荐表
CREATE TABLE IF NOT EXISTS ai_resource_recommendations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    resource_type ENUM('video', 'article', 'experiment', 'scenario', 'practice') NOT NULL,
    resource_id INT NOT NULL COMMENT '资源ID',
    resource_title VARCHAR(200),
    recommendation_reason TEXT,
    relevance_score DECIMAL(5, 2) COMMENT '相关度分数',
    target_weakness JSON COMMENT '针对薄弱点',
    priority INT DEFAULT 5 COMMENT '优先级(1-10)',
    is_viewed BOOLEAN DEFAULT FALSE,
    is_completed BOOLEAN DEFAULT FALSE,
    user_feedback INT COMMENT '用户反馈(1-5)',
    recommended_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_type (resource_type),
    INDEX idx_viewed (is_viewed)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习资源推荐表';

-- 每日学习任务表
CREATE TABLE IF NOT EXISTS ai_daily_tasks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    plan_id INT COMMENT '所属学习计划ID',
    task_date DATE NOT NULL,
    task_type ENUM('review', 'practice', 'experiment', 'reading', 'exploration') NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    target_content JSON COMMENT '目标内容（知识点、资源ID等）',
    estimated_time INT DEFAULT 30 COMMENT '预计时长(分钟)',
    actual_time INT COMMENT '实际时长(分钟)',
    status ENUM('pending', 'ongoing', 'completed', 'skipped', 'overdue') DEFAULT 'pending',
    completion_quality ENUM('excellent', 'good', 'fair', 'poor') COMMENT '完成质量',
    points INT DEFAULT 0 COMMENT '获得积分',
    completed_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES ai_study_plans(id) ON DELETE CASCADE,
    INDEX idx_user_date (user_id, task_date),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='每日学习任务表';

-- 学情周报表
CREATE TABLE IF NOT EXISTS ai_weekly_reports (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    week_start_date DATE NOT NULL,
    week_end_date DATE NOT NULL,
    total_study_time INT DEFAULT 0 COMMENT '总学习时长(分钟)',
    completed_tasks INT DEFAULT 0 COMMENT '完成任务数',
    knowledge_growth DECIMAL(5, 2) COMMENT '知识增长率(%)',
    top_achievements JSON COMMENT '本周亮点',
    weak_areas JSON COMMENT '薄弱领域',
    study_consistency DECIMAL(3, 2) COMMENT '学习连贯性评分',
    comparison_with_classmates JSON COMMENT '与同班平均对比',
    next_week_goals TEXT COMMENT '下周目标',
    teacher_suggestions TEXT COMMENT '教师建议',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_week (user_id, week_start_date),
    INDEX idx_user (user_id),
    INDEX idx_date (week_start_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学情周报表';

-- ========================================
-- 跨模块共享表
-- ========================================

-- 用户积分记录表
CREATE TABLE IF NOT EXISTS user_points_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    module ENUM('geopolitics', 'cyber_lab', 'scenario', 'ai_companion', 'other') NOT NULL,
    action_type VARCHAR(100) NOT NULL COMMENT '行为类型',
    points INT NOT NULL COMMENT '积分变化',
    balance INT NOT NULL COMMENT '积分余额',
    description VARCHAR(200),
    related_id INT COMMENT '关联记录ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_module (module),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户积分记录表';

-- 用户等级表
CREATE TABLE IF NOT EXISTS user_levels (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    current_level INT DEFAULT 1 COMMENT '当前等级',
    current_exp INT DEFAULT 0 COMMENT '当前经验值',
    total_points INT DEFAULT 0 COMMENT '总积分',
    title VARCHAR(100) COMMENT '称号',
    ranking INT COMMENT '排名',
    level_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_level (current_level),
    INDEX idx_ranking (ranking)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户等级表';

-- 系统消息通知表
CREATE TABLE IF NOT EXISTS system_notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    notification_type ENUM('system', 'achievement', 'reminder', 'social', 'update') DEFAULT 'system',
    title VARCHAR(200) NOT NULL,
    content TEXT,
    link_url VARCHAR(500),
    icon VARCHAR(100),
    is_read BOOLEAN DEFAULT FALSE,
    is_important BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_read (is_read),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统消息通知表';

-- 用户反馈表
CREATE TABLE IF NOT EXISTS user_feedback (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    module VARCHAR(50) COMMENT '所属模块',
    feedback_type ENUM('bug', 'suggestion', 'praise', 'complaint', 'question') NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    attachments JSON COMMENT '附件列表',
    contact_info VARCHAR(200) COMMENT '联系方式',
    status ENUM('submitted', 'reviewing', 'processing', 'resolved', 'closed') DEFAULT 'submitted',
    admin_reply TEXT COMMENT '管理员回复',
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_status (status),
    INDEX idx_type (feedback_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户反馈表';

-- ========================================
-- 初始化基础数据
-- ========================================

-- 插入默认热点标签
INSERT INTO geopolitics_tags (name, category, description, color) VALUES
('一带一路', 'theme', '一带一路倡议相关内容', '#ff6b6b'),
('碳达峰碳中和', 'theme', '双碳目标相关政策与实践', '#4ecb73'),
('自然灾害', 'theme', '地震、洪水、台风等自然灾害', '#feca57'),
('区域发展', 'theme', '区域经济与发展战略', '#48dbfb'),
('生态保护', 'theme', '生态文明建设与环境保护', '#0abde3'),
('城市化', 'theme', '城镇化发展与城市规划', '#ee5a6f'),
('能源资源', 'theme', '能源结构与资源利用', '#f368e0'),
('国际关系', 'theme', '地缘政治与国际合作', '#341f97');

-- 插入默认成就勋章
INSERT INTO ai_achievements (name, description, icon, category, unlock_condition, points, rarity) VALUES
('初学者', '完成首次学习任务', '🌱', 'learning', '{"tasks_completed": 1}', 10, 'common'),
('勤奋之星', '连续学习7天', '⭐', 'consistency', '{"consecutive_days": 7}', 50, 'rare'),
('知识探索者', '完成10个不同模块学习', '🔍', 'exploration', '{"modules_completed": 10}', 100, 'rare'),
('实验狂人', '完成20个虚拟实验', '🧪', 'experiment', '{"experiments_completed": 20}', 150, 'epic'),
('地理达人', '知识掌握度达到90%', '🎓', 'mastery', '{"mastery_rate": 90}', 200, 'epic'),
('时政通', '完成50次热点分析', '📰', 'geopolitics', '{"hotspot_analysis": 50}', 180, 'epic'),
('探险家', '完成所有情景任务', '🗺️', 'scenario', '{"all_scenarios_completed": true}', 300, 'legendary'),
('完美主义者', '连续10次测验满分', '💯', 'achievement', '{"perfect_scores": 10}', 250, 'legendary');

COMMIT;

-- ========================================
-- 数据库优化建议
-- ========================================
-- 1. 定期清理过期数据（如超过1年的学习记录）
-- 2. 为高频查询字段创建复合索引
-- 3. 使用分区表存储海量历史数据
-- 4. 启用查询缓存和慢查询日志监控
-- 5. 定期执行 ANALYZE TABLE 优化查询计划
