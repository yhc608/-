-- EduGlobe 地理教育平台数据库设计
-- 创建数据库
CREATE DATABASE IF NOT EXISTS eduglobe_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE eduglobe_db;

-- ==================== 用户系统 ====================

-- 用户表（学生+教师统一管理）
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    role ENUM('student', 'teacher', 'admin') NOT NULL,
    real_name VARCHAR(50),
    avatar_url VARCHAR(255),
    school_id BIGINT,
    grade_level ENUM('middle_school', 'undergraduate') DEFAULT 'middle_school',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    status ENUM('active', 'inactive', 'banned') DEFAULT 'active',
    INDEX idx_role (role),
    INDEX idx_school (school_id),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 学校表
CREATE TABLE schools (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    province VARCHAR(50),
    city VARCHAR(50),
    district VARCHAR(50),
    address TEXT,
    school_type ENUM('middle_school', 'high_school', 'university') NOT NULL,
    contact_phone VARCHAR(20),
    contact_email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_location (province, city)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学校表';

-- 班级表
CREATE TABLE classes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    school_id BIGINT NOT NULL,
    teacher_id BIGINT,
    grade VARCHAR(20),
    semester VARCHAR(20),
    textbook_version ENUM('人教版', '湘教版', '中图版', '鲁教版') DEFAULT '人教版',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES schools(id),
    FOREIGN KEY (teacher_id) REFERENCES users(id),
    INDEX idx_school (school_id),
    INDEX idx_teacher (teacher_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='班级表';

-- 学生-班级关联表
CREATE TABLE class_students (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    class_id BIGINT NOT NULL,
    student_id BIGINT NOT NULL,
    join_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'transferred', 'graduated') DEFAULT 'active',
    FOREIGN KEY (class_id) REFERENCES classes(id),
    FOREIGN KEY (student_id) REFERENCES users(id),
    UNIQUE KEY unique_class_student (class_id, student_id),
    INDEX idx_student (student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生班级关联表';

-- ==================== 知识体系 ====================

-- 知识图谱节点表
CREATE TABLE knowledge_nodes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    node_type ENUM('concept', 'principle', 'skill', 'case', 'exam_point') NOT NULL,
    textbook_version VARCHAR(50),
    chapter VARCHAR(100),
    section VARCHAR(100),
    textbook_page INT,
    difficulty_level TINYINT DEFAULT 3 COMMENT '1-5难度级别',
    description TEXT,
    three_dimension_analysis JSON COMMENT '三维解析：知识、能力、素养',
    common_mistakes JSON COMMENT '易错警示',
    extension_resources JSON COMMENT '拓展资源',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type (node_type),
    INDEX idx_textbook (textbook_version, chapter),
    FULLTEXT idx_name_desc (name, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识图谱节点表';

-- 知识图谱关系表
CREATE TABLE knowledge_relations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    source_node_id BIGINT NOT NULL,
    target_node_id BIGINT NOT NULL,
    relation_type ENUM('prerequisite', 'related', 'contrast', 'application', 'example') NOT NULL,
    strength FLOAT DEFAULT 1.0 COMMENT '关联强度0-1',
    description VARCHAR(255),
    FOREIGN KEY (source_node_id) REFERENCES knowledge_nodes(id),
    FOREIGN KEY (target_node_id) REFERENCES knowledge_nodes(id),
    INDEX idx_source (source_node_id),
    INDEX idx_target (target_node_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识图谱关系表';

-- 概念卡片表
CREATE TABLE concept_cards (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    knowledge_node_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    anchor_page INT COMMENT '教材锚点页码',
    content_text TEXT,
    content_media JSON COMMENT '图片、视频、3D模型等',
    quick_test JSON COMMENT '即时训练题目',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (knowledge_node_id) REFERENCES knowledge_nodes(id),
    INDEX idx_node (knowledge_node_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='概念卡片表';

-- ==================== 课程与教学 ====================

-- 课程表
CREATE TABLE courses (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    class_id BIGINT NOT NULL,
    name VARCHAR(200) NOT NULL,
    chapter VARCHAR(100),
    section VARCHAR(100),
    knowledge_nodes JSON COMMENT '关联知识点ID数组',
    lesson_plan TEXT COMMENT '教案内容',
    resources JSON COMMENT '资源包',
    scheduled_time TIMESTAMP,
    actual_time TIMESTAMP NULL,
    duration INT DEFAULT 45 COMMENT '课程时长(分钟)',
    status ENUM('scheduled', 'ongoing', 'completed', 'cancelled') DEFAULT 'scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (class_id) REFERENCES classes(id),
    INDEX idx_class (class_id),
    INDEX idx_status (status),
    INDEX idx_scheduled_time (scheduled_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课程表';

-- 虚拟角色表
CREATE TABLE virtual_characters (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    character_type ENUM('徐霞客', '魏格纳', '张衡', '竺可桢', '李四光', '其他') NOT NULL,
    description TEXT,
    avatar_url VARCHAR(255),
    voice_config JSON COMMENT '语音配置',
    animation_config JSON COMMENT '动画配置',
    knowledge_domain VARCHAR(100) COMMENT '知识领域',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='虚拟角色表';

-- 课堂互动记录表
CREATE TABLE classroom_interactions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    course_id BIGINT NOT NULL,
    student_id BIGINT NOT NULL,
    interaction_type ENUM('question', 'answer', 'game', 'vote', 'emoji') NOT NULL,
    content TEXT,
    media_url VARCHAR(255),
    ai_response TEXT,
    response_time_ms INT,
    is_correct BOOLEAN,
    score INT,
    attention_level TINYINT COMMENT '专注度1-5',
    emotion ENUM('happy', 'neutral', 'confused', 'bored') DEFAULT 'neutral',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id),
    FOREIGN KEY (student_id) REFERENCES users(id),
    INDEX idx_course (course_id),
    INDEX idx_student (student_id),
    INDEX idx_type (interaction_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课堂互动记录表';

-- 地理小游戏表
CREATE TABLE geography_games (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    game_type ENUM('climate_puzzle', 'geography_monopoly', 'riddle', 'disaster_simulation') NOT NULL,
    description TEXT,
    difficulty_level TINYINT DEFAULT 3,
    knowledge_points JSON COMMENT '关联知识点',
    config JSON COMMENT '游戏配置',
    min_players INT DEFAULT 1,
    max_players INT DEFAULT 50,
    duration_minutes INT DEFAULT 10,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_type (game_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='地理小游戏表';

-- 游戏记录表
CREATE TABLE game_records (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    game_id BIGINT NOT NULL,
    course_id BIGINT,
    student_id BIGINT NOT NULL,
    score INT,
    correct_count INT,
    total_count INT,
    duration_seconds INT,
    game_data JSON COMMENT '详细游戏数据',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (game_id) REFERENCES geography_games(id),
    FOREIGN KEY (student_id) REFERENCES users(id),
    INDEX idx_student (student_id),
    INDEX idx_game (game_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='游戏记录表';

-- ==================== 作业与练习 ====================

-- 作业表
CREATE TABLE assignments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    course_id BIGINT,
    class_id BIGINT NOT NULL,
    teacher_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    assignment_type ENUM('preview', 'practice', 'review', 'exam') NOT NULL,
    knowledge_nodes JSON,
    questions JSON COMMENT '题目内容',
    total_score INT DEFAULT 100,
    due_date TIMESTAMP,
    auto_grade BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (class_id) REFERENCES classes(id),
    FOREIGN KEY (teacher_id) REFERENCES users(id),
    INDEX idx_class (class_id),
    INDEX idx_type (assignment_type),
    INDEX idx_due_date (due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='作业表';

-- 学生作业提交表
CREATE TABLE assignment_submissions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    assignment_id BIGINT NOT NULL,
    student_id BIGINT NOT NULL,
    answers JSON COMMENT '答案内容',
    attachments JSON COMMENT '附件（手绘地图等）',
    submit_time TIMESTAMP,
    score INT,
    auto_score INT,
    teacher_score INT,
    feedback TEXT,
    ai_comment TEXT,
    status ENUM('not_started', 'in_progress', 'submitted', 'graded') DEFAULT 'not_started',
    duration_seconds INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (assignment_id) REFERENCES assignments(id),
    FOREIGN KEY (student_id) REFERENCES users(id),
    UNIQUE KEY unique_assignment_student (assignment_id, student_id),
    INDEX idx_student (student_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生作业提交表';

-- 错题本表
CREATE TABLE error_questions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    student_id BIGINT NOT NULL,
    question_type ENUM('choice', 'multi_choice', 'judge', 'blank', 'short_answer', 'essay', 'drawing') NOT NULL,
    question_content TEXT NOT NULL,
    correct_answer TEXT,
    student_answer TEXT,
    knowledge_node_id BIGINT,
    error_reason ENUM('concept_error', 'careless', 'skill_lacking', 'comprehensive') COMMENT 'AI归因',
    explanation TEXT,
    targeted_practice JSON COMMENT '靶向练习题',
    mastery_level TINYINT DEFAULT 0 COMMENT '掌握程度0-5',
    review_count INT DEFAULT 0,
    last_review_time TIMESTAMP NULL,
    source_type ENUM('assignment', 'exam', 'practice', 'qa') DEFAULT 'assignment',
    source_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (knowledge_node_id) REFERENCES knowledge_nodes(id),
    INDEX idx_student (student_id),
    INDEX idx_knowledge (knowledge_node_id),
    INDEX idx_mastery (mastery_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='错题本表';

-- ==================== 智能答疑 ====================

-- 答疑记录表
CREATE TABLE qa_records (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    student_id BIGINT NOT NULL,
    question_type ENUM('text', 'voice', 'image', 'mixed') NOT NULL,
    question_text TEXT,
    question_media JSON COMMENT '图片、语音文件URL',
    image_recognition JSON COMMENT '图像识别结果（等高线、气候图等）',
    knowledge_nodes JSON COMMENT '关联知识点',
    ai_answer TEXT,
    answer_quality TINYINT COMMENT '答案质量评分1-5',
    related_examples JSON COMMENT '关联例题',
    follow_up_questions JSON COMMENT '追问记录',
    resolution_status ENUM('pending', 'answered', 'satisfied', 'escalated') DEFAULT 'answered',
    response_time_ms INT,
    student_rating TINYINT COMMENT '学生评分1-5',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id),
    INDEX idx_student (student_id),
    INDEX idx_type (question_type),
    INDEX idx_status (resolution_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='答疑记录表';

-- ==================== 学习分析 ====================

-- 学生学习报告表
CREATE TABLE learning_reports (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    student_id BIGINT NOT NULL,
    report_type ENUM('daily', 'weekly', 'monthly', 'semester') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    study_duration_minutes INT,
    knowledge_mastery JSON COMMENT '知识掌握度分析',
    weak_points JSON COMMENT '薄弱知识点',
    ability_radar JSON COMMENT '能力雷达图数据',
    progress_trend JSON COMMENT '进步趋势',
    suggestions TEXT COMMENT 'AI个性化建议',
    statistics JSON COMMENT '详细统计数据',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id),
    UNIQUE KEY unique_student_report (student_id, report_type, start_date),
    INDEX idx_student (student_id),
    INDEX idx_type (report_type),
    INDEX idx_date (start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生学习报告表';

-- 个性化学习路径表
CREATE TABLE learning_paths (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    student_id BIGINT NOT NULL,
    current_level TINYINT DEFAULT 3,
    target_level TINYINT DEFAULT 5,
    weak_knowledge_nodes JSON COMMENT '薄弱知识点',
    recommended_sequence JSON COMMENT '推荐学习序列',
    custom_resources JSON COMMENT '定制资源包',
    difficulty_adaptation JSON COMMENT '难度自适应配置',
    progress FLOAT DEFAULT 0.0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id),
    INDEX idx_student (student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='个性化学习路径表';

-- ==================== 本科专属功能 ====================

-- 虚拟实验表
CREATE TABLE virtual_experiments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    experiment_type ENUM('field_survey', 'volcano', 'hydrology', 'meteorology', 'universe', 'disaster') NOT NULL,
    description TEXT,
    difficulty_level TINYINT DEFAULT 3,
    knowledge_points JSON,
    vr_scene_url VARCHAR(255),
    instruments JSON COMMENT '3D仪器配置',
    experiment_steps JSON COMMENT '实验步骤',
    data_processing_template JSON COMMENT '数据处理模板',
    duration_minutes INT DEFAULT 30,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_type (experiment_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='虚拟实验表';

-- 实验记录表
CREATE TABLE experiment_records (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    experiment_id BIGINT NOT NULL,
    student_id BIGINT NOT NULL,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    operation_data JSON COMMENT '操作数据',
    collected_data JSON COMMENT '采集数据',
    analysis_result JSON COMMENT '分析结果',
    report_content TEXT,
    score INT,
    ai_feedback TEXT,
    status ENUM('in_progress', 'completed', 'abandoned') DEFAULT 'in_progress',
    FOREIGN KEY (experiment_id) REFERENCES virtual_experiments(id),
    FOREIGN KEY (student_id) REFERENCES users(id),
    INDEX idx_student (student_id),
    INDEX idx_experiment (experiment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='实验记录表';

-- 地学交流频道表
CREATE TABLE geo_channels (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    creator_id BIGINT NOT NULL,
    channel_type ENUM('qa', 'discussion', 'research', 'custom') NOT NULL,
    category VARCHAR(50) COMMENT '学科分类',
    description TEXT,
    cover_image VARCHAR(255),
    member_count INT DEFAULT 0,
    post_count INT DEFAULT 0,
    is_public BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (creator_id) REFERENCES users(id),
    INDEX idx_type (channel_type),
    INDEX idx_creator (creator_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='地学交流频道表';

-- 频道成员表
CREATE TABLE channel_members (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    channel_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    role ENUM('owner', 'admin', 'member') DEFAULT 'member',
    join_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (channel_id) REFERENCES geo_channels(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY unique_channel_user (channel_id, user_id),
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='频道成员表';

-- 频道帖子表
CREATE TABLE channel_posts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    channel_id BIGINT NOT NULL,
    author_id BIGINT NOT NULL,
    title VARCHAR(200),
    content TEXT NOT NULL,
    media JSON COMMENT '图片、视频、文档等',
    tags JSON COMMENT '标签',
    view_count INT DEFAULT 0,
    like_count INT DEFAULT 0,
    reply_count INT DEFAULT 0,
    is_pinned BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (channel_id) REFERENCES geo_channels(id),
    FOREIGN KEY (author_id) REFERENCES users(id),
    INDEX idx_channel (channel_id),
    INDEX idx_author (author_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='频道帖子表';

-- 文献库表
CREATE TABLE academic_literature (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(500) NOT NULL,
    authors VARCHAR(500),
    journal VARCHAR(200),
    publish_year INT,
    doi VARCHAR(100),
    abstract TEXT,
    keywords JSON,
    pdf_url VARCHAR(255),
    citation_count INT DEFAULT 0,
    knowledge_tags JSON COMMENT '知识标签',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_year (publish_year),
    FULLTEXT idx_title_abstract (title, abstract)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文献库表';

-- ==================== 教师端功能 ====================

-- 教案库表
CREATE TABLE lesson_plans (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    teacher_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    subject VARCHAR(50) DEFAULT '地理',
    grade VARCHAR(20),
    textbook_version VARCHAR(50),
    chapter VARCHAR(100),
    section VARCHAR(100),
    content TEXT NOT NULL,
    teaching_objectives TEXT,
    key_points TEXT COMMENT '教学重点',
    difficult_points TEXT COMMENT '教学难点',
    teaching_methods TEXT,
    resources JSON COMMENT '教学资源包',
    cross_subject_elements JSON COMMENT '跨学科融合元素',
    duration_minutes INT DEFAULT 45,
    is_public BOOLEAN DEFAULT FALSE COMMENT '是否共享',
    view_count INT DEFAULT 0,
    use_count INT DEFAULT 0,
    rating FLOAT DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES users(id),
    INDEX idx_teacher (teacher_id),
    INDEX idx_textbook (textbook_version, chapter)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='教案库表';

-- 课堂监测数据表
CREATE TABLE classroom_monitoring (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    course_id BIGINT NOT NULL,
    monitoring_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    average_attention FLOAT COMMENT '平均专注度',
    emotion_distribution JSON COMMENT '情绪分布',
    interaction_stats JSON COMMENT '互动统计',
    hot_questions JSON COMMENT '提问热点',
    blind_spots JSON COMMENT '知识盲区',
    teaching_pace_suggestion TEXT COMMENT '教学节奏建议',
    FOREIGN KEY (course_id) REFERENCES courses(id),
    INDEX idx_course (course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课堂监测数据表';

-- 作业批改记录表
CREATE TABLE grading_records (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    submission_id BIGINT NOT NULL,
    teacher_id BIGINT NOT NULL,
    score INT,
    detailed_scores JSON COMMENT '分项得分',
    comments TEXT,
    grading_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    grading_duration_seconds INT,
    FOREIGN KEY (submission_id) REFERENCES assignment_submissions(id),
    FOREIGN KEY (teacher_id) REFERENCES users(id),
    INDEX idx_submission (submission_id),
    INDEX idx_teacher (teacher_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='作业批改记录表';

-- 手绘地图识别表
CREATE TABLE map_recognitions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    submission_id BIGINT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    map_type ENUM('contour', 'climate', 'terrain_profile', 'distribution', 'other') NOT NULL,
    recognition_result JSON COMMENT 'AI识别结果',
    accuracy_score FLOAT,
    element_scores JSON COMMENT '元素评分',
    suggestions TEXT COMMENT '改进建议',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (submission_id) REFERENCES assignment_submissions(id),
    INDEX idx_submission (submission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='手绘地图识别表';

-- 教学数据驾驶舱表
CREATE TABLE teaching_dashboard (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    teacher_id BIGINT NOT NULL,
    class_id BIGINT NOT NULL,
    report_date DATE NOT NULL,
    class_situation JSON COMMENT '班级学情',
    assignment_completion_rate FLOAT,
    average_score FLOAT,
    interaction_degree JSON COMMENT '互动度统计',
    knowledge_mastery JSON COMMENT '知识点掌握情况',
    weak_students JSON COMMENT '待帮扶学生',
    excellent_students JSON COMMENT '优秀学生',
    teaching_suggestions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES users(id),
    FOREIGN KEY (class_id) REFERENCES classes(id),
    UNIQUE KEY unique_teacher_class_date (teacher_id, class_id, report_date),
    INDEX idx_teacher (teacher_id),
    INDEX idx_class (class_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='教学数据驾驶舱表';

-- 课镜AI评估表（本科教师）
CREATE TABLE teaching_assessment (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    course_id BIGINT NOT NULL,
    teacher_id BIGINT NOT NULL,
    video_url VARCHAR(255),
    posture_score FLOAT COMMENT '仪态评分',
    speech_rate_score FLOAT COMMENT '语速评分',
    content_quality_score FLOAT COMMENT '内容质量评分',
    interaction_score FLOAT COMMENT '互动评分',
    overall_score FLOAT COMMENT '综合评分',
    detailed_analysis JSON COMMENT '详细分析',
    improvement_suggestions TEXT,
    assessment_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id),
    FOREIGN KEY (teacher_id) REFERENCES users(id),
    INDEX idx_teacher (teacher_id),
    INDEX idx_course (course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课镜AI评估表';

-- ==================== 系统配置与资源 ====================

-- 教学资源表
CREATE TABLE teaching_resources (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    resource_type ENUM('video', 'document', 'image', '3d_model', 'animation', 'ar_scene', 'vr_scene', 'experiment') NOT NULL,
    category VARCHAR(50) COMMENT '资源分类',
    knowledge_nodes JSON,
    file_url VARCHAR(255) NOT NULL,
    thumbnail_url VARCHAR(255),
    file_size BIGINT COMMENT '文件大小(字节)',
    duration INT COMMENT '时长(秒)',
    description TEXT,
    tags JSON,
    uploader_id BIGINT,
    download_count INT DEFAULT 0,
    view_count INT DEFAULT 0,
    rating FLOAT DEFAULT 0.0,
    is_public BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (uploader_id) REFERENCES users(id),
    INDEX idx_type (resource_type),
    INDEX idx_category (category),
    FULLTEXT idx_title_desc (title, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='教学资源表';

-- 系统配置表
CREATE TABLE system_configs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT NOT NULL,
    config_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
    description VARCHAR(255),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';

-- 用户行为日志表
CREATE TABLE user_activity_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    action_detail TEXT,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_user (user_id),
    INDEX idx_action (action_type),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户行为日志表';

-- ==================== 初始化数据 ====================

-- 插入系统配置
INSERT INTO system_configs (config_key, config_value, config_type, description) VALUES
('ai_model_endpoint', 'https://api.openai.com/v1', 'string', 'AI模型API端点'),
('max_upload_size', '104857600', 'number', '最大上传文件大小(字节)'),
('enable_vr_features', 'true', 'boolean', '是否启用VR功能'),
('textbook_versions', '["人教版", "湘教版", "中图版", "鲁教版"]', 'json', '支持的教材版本');

-- 插入虚拟角色
INSERT INTO virtual_characters (name, character_type, description, knowledge_domain) VALUES
('徐霞客', '徐霞客', '明代地理学家、旅行家，著有《徐霞客游记》', '地貌、水文、旅游地理'),
('魏格纳', '魏格纳', '德国气象学家、地球物理学家，大陆漂移说提出者', '板块构造、地质学'),
('张衡', '张衡', '东汉天文学家、数学家，发明地动仪', '天文、地震、测绘'),
('竺可桢', '竺可桢', '中国现代地理学和气象学奠基人', '气候、气象、物候'),
('李四光', '李四光', '中国地质力学创立者', '地质学、构造地质');

-- 插入地理小游戏
INSERT INTO geography_games (name, game_type, description, difficulty_level) VALUES
('气候拼图大挑战', 'climate_puzzle', '通过拼图认识世界气候类型分布', 2),
('地理大富翁', 'geography_monopoly', '环游世界学习地理知识', 3),
('地理灯谜竞猜', 'riddle', '猜地理相关的谜语和知识点', 2),
('自然灾害模拟', 'disaster_simulation', '模拟地震、台风等自然灾害的应对', 4);
