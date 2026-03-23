-- EduGlobe 测试数据脚本
-- 此脚本将插入丰富的测试数据以便展示和测试平台功能

USE eduglobe_db;

-- ==================== 清空现有数据（保留结构） ====================
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE user_activity_logs;
TRUNCATE TABLE teaching_assessment;
TRUNCATE TABLE teaching_dashboard;
TRUNCATE TABLE map_recognitions;
TRUNCATE TABLE grading_records;
TRUNCATE TABLE classroom_monitoring;
TRUNCATE TABLE lesson_plans;
TRUNCATE TABLE academic_literature;
TRUNCATE TABLE channel_posts;
TRUNCATE TABLE channel_members;
TRUNCATE TABLE geo_channels;
TRUNCATE TABLE experiment_records;
TRUNCATE TABLE virtual_experiments;
TRUNCATE TABLE learning_paths;
TRUNCATE TABLE learning_reports;
TRUNCATE TABLE qa_records;
TRUNCATE TABLE error_questions;
TRUNCATE TABLE assignment_submissions;
TRUNCATE TABLE assignments;
TRUNCATE TABLE game_records;
TRUNCATE TABLE geography_games;
TRUNCATE TABLE classroom_interactions;
TRUNCATE TABLE courses;
TRUNCATE TABLE concept_cards;
TRUNCATE TABLE knowledge_relations;
TRUNCATE TABLE knowledge_nodes;
TRUNCATE TABLE class_students;
TRUNCATE TABLE classes;
TRUNCATE TABLE schools;
TRUNCATE TABLE teaching_resources;
TRUNCATE TABLE users;

SET FOREIGN_KEY_CHECKS = 1;

-- ==================== 学校数据 ====================
INSERT INTO schools (id, name, province, city, district, school_type, contact_phone, contact_email) VALUES
(1, '北京市第四中学', '北京', '北京市', '西城区', 'high_school', '010-66175566', 'bjsz@edu.cn'),
(2, '上海市格致中学', '上海', '上海市', '黄浦区', 'high_school', '021-63510228', 'shgz@edu.cn'),
(3, '杭州市学军中学', '浙江', '杭州市', '西湖区', 'high_school', '0571-88073669', 'hzxj@edu.cn'),
(4, '成都市第七中学', '四川', '成都市', '武侯区', 'high_school', '028-85442231', 'cdqz@edu.cn'),
(5, '北京大学', '北京', '北京市', '海淀区', 'university', '010-62752114', 'pku@pku.edu.cn'),
(6, '华东师范大学', '上海', '上海市', '普陀区', 'university', '021-62233333', 'ecnu@ecnu.edu.cn'),
(7, '广州市第二中学', '广东', '广州市', '越秀区', 'high_school', '020-83556666', 'gz2z@edu.cn'),
(8, '南京师范大学附属中学', '江苏', '南京市', '鼓楼区', 'high_school', '025-83238122', 'njsdfz@edu.cn');

-- ==================== 用户数据 ====================
-- 教师账号
INSERT INTO users (id, username, password_hash, email, phone, role, real_name, avatar_url, school_id, grade_level, status) VALUES
(1, 'teacher_zhang', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 'zhang@edu.cn', '13800138001', 'teacher', '张丽华', '/avatars/teacher1.jpg', 1, 'middle_school', 'active'),
(2, 'teacher_wang', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 'wang@edu.cn', '13800138002', 'teacher', '王明辉', '/avatars/teacher2.jpg', 1, 'middle_school', 'active'),
(3, 'teacher_li', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 'li@edu.cn', '13800138003', 'teacher', '李晓芳', '/avatars/teacher3.jpg', 2, 'middle_school', 'active'),
(4, 'teacher_chen', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 'chen@edu.cn', '13800138004', 'teacher', '陈建国', '/avatars/teacher4.jpg', 3, 'middle_school', 'active'),
(5, 'prof_liu', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 'liu@pku.edu.cn', '13800138005', 'teacher', '刘教授', '/avatars/prof1.jpg', 5, 'undergraduate', 'active'),
(6, 'prof_zhou', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 'zhou@ecnu.edu.cn', '13800138006', 'teacher', '周教授', '/avatars/prof2.jpg', 6, 'undergraduate', 'active');

-- 学生账号（高中生）
INSERT INTO users (id, username, password_hash, email, phone, role, real_name, avatar_url, school_id, grade_level, status) VALUES
(101, 'student_001', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 's001@student.com', '13900139001', 'student', '小明', '/avatars/boy1.jpg', 1, 'middle_school', 'active'),
(102, 'student_002', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 's002@student.com', '13900139002', 'student', '小红', '/avatars/girl1.jpg', 1, 'middle_school', 'active'),
(103, 'student_003', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 's003@student.com', '13900139003', 'student', '小刚', '/avatars/boy2.jpg', 1, 'middle_school', 'active'),
(104, 'student_004', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 's004@student.com', '13900139004', 'student', '小美', '/avatars/girl2.jpg', 1, 'middle_school', 'active'),
(105, 'student_005', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 's005@student.com', '13900139005', 'student', '小强', '/avatars/boy3.jpg', 1, 'middle_school', 'active'),
(106, 'student_006', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 's006@student.com', '13900139006', 'student', '小丽', '/avatars/girl3.jpg', 2, 'middle_school', 'active'),
(107, 'student_007', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 's007@student.com', '13900139007', 'student', '小杰', '/avatars/boy4.jpg', 2, 'middle_school', 'active'),
(108, 'student_008', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 's008@student.com', '13900139008', 'student', '小雅', '/avatars/girl4.jpg', 3, 'middle_school', 'active'),
(109, 'student_009', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 's009@student.com', '13900139009', 'student', '小凯', '/avatars/boy5.jpg', 3, 'middle_school', 'active'),
(110, 'student_010', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 's010@student.com', '13900139010', 'student', '小婷', '/avatars/girl5.jpg', 4, 'middle_school', 'active');

-- 学生账号（本科生）
INSERT INTO users (id, username, password_hash, email, phone, role, real_name, avatar_url, school_id, grade_level, status) VALUES
(201, 'undergrad_001', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 'u001@pku.edu.cn', '13910139001', 'student', '张三', '/avatars/college1.jpg', 5, 'undergraduate', 'active'),
(202, 'undergrad_002', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 'u002@pku.edu.cn', '13910139002', 'student', '李四', '/avatars/college2.jpg', 5, 'undergraduate', 'active'),
(203, 'undergrad_003', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 'u003@pku.edu.cn', '13910139003', 'student', '王五', '/avatars/college3.jpg', 5, 'undergraduate', 'active'),
(204, 'undergrad_004', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 'u004@ecnu.edu.cn', '13910139004', 'student', '赵六', '/avatars/college4.jpg', 6, 'undergraduate', 'active'),
(205, 'undergrad_005', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 'u005@ecnu.edu.cn', '13910139005', 'student', '孙七', '/avatars/college5.jpg', 6, 'undergraduate', 'active');

-- 管理员账号
INSERT INTO users (id, username, password_hash, email, phone, role, real_name, avatar_url, school_id, grade_level, status) VALUES
(999, 'admin', '$2b$10$XQVjqQx6YzYnKQYnKQYnKe.hash', 'admin@eduglobe.com', '13800000000', 'admin', '系统管理员', '/avatars/admin.jpg', NULL, 'middle_school', 'active');

-- ==================== 班级数据 ====================
INSERT INTO classes (id, name, school_id, teacher_id, grade, semester, textbook_version) VALUES
(1, '高一（1）班', 1, 1, '高一', '2024春季', '人教版'),
(2, '高一（2）班', 1, 2, '高一', '2024春季', '人教版'),
(3, '高二（1）班', 2, 3, '高二', '2024春季', '湘教版'),
(4, '高一（3）班', 3, 4, '高一', '2024春季', '中图版'),
(5, '地理科学专业2023级', 5, 5, '大一', '2024春季', '人教版'),
(6, '地理信息科学专业2023级', 6, 6, '大一', '2024春季', '人教版');

-- ==================== 班级学生关联 ====================
INSERT INTO class_students (class_id, student_id, status) VALUES
(1, 101, 'active'), (1, 102, 'active'), (1, 103, 'active'), (1, 104, 'active'), (1, 105, 'active'),
(2, 106, 'active'), (2, 107, 'active'),
(3, 108, 'active'), (3, 109, 'active'),
(4, 110, 'active'),
(5, 201, 'active'), (5, 202, 'active'), (5, 203, 'active'),
(6, 204, 'active'), (6, 205, 'active');

-- ==================== 知识图谱节点 ====================
INSERT INTO knowledge_nodes (id, name, node_type, textbook_version, chapter, section, textbook_page, difficulty_level, description, three_dimension_analysis, common_mistakes, extension_resources) VALUES
(1, '地球的宇宙环境', 'concept', '人教版', '第一章', '第一节', 5, 2, '地球在宇宙中的位置及其宇宙环境特征', 
  '{"knowledge": "理解地球所处的宇宙环境", "ability": "分析天体系统的层次", "literacy": "树立宇宙观和尺度观念"}',
  '["容易混淆不同天体系统的层次关系", "对光年等天文单位理解不透"]',
  '["https://resources.edu/universe.mp4", "https://models.edu/solar_system_3d"]'),
  
(2, '太阳对地球的影响', 'concept', '人教版', '第一章', '第二节', 10, 3, '太阳辐射、太阳活动及其对地球的影响', 
  '{"knowledge": "掌握太阳辐射和太阳活动的基本知识", "ability": "分析太阳活动对地球的影响", "literacy": "认识人地关系协调发展"}',
  '["将太阳活动类型混淆", "对太阳黑子和耀斑的周期理解不准确"]',
  '["https://resources.edu/solar_activity.mp4"]'),
  
(3, '地球的圈层结构', 'concept', '人教版', '第一章', '第三节', 15, 3, '地球内部圈层和外部圈层的结构特征', 
  '{"knowledge": "了解地球内外部圈层结构", "ability": "读图分析地球圈层特征", "literacy": "建立地球系统观"}',
  '["对地震波速度变化与圈层划分的关系理解不深", "混淆莫霍面和古登堡面"]',
  '["https://resources.edu/earth_structure.mp4", "https://models.edu/earth_layers_3d"]'),
  
(4, '大气的组成和垂直分层', 'concept', '人教版', '第二章', '第一节', 20, 3, '大气的组成成分及垂直分层特征', 
  '{"knowledge": "掌握大气垂直分层特征", "ability": "分析不同层次大气特点", "literacy": "关注大气环境保护"}',
  '["对流层气温垂直变化规律记忆混乱", "平流层特征理解不全面"]',
  '["https://resources.edu/atmosphere.mp4"]'),
  
(5, '大气的热力作用', 'principle', '人教版', '第二章', '第二节', 25, 4, '大气对太阳辐射的削弱作用和保温作用', 
  '{"knowledge": "理解大气热力作用过程", "ability": "运用原理解释天气现象", "literacy": "认识温室效应"}',
  '["对大气逆辐射的理解不透彻", "混淆削弱作用的三种方式"]',
  '["https://resources.edu/greenhouse_effect.mp4"]'),
  
(6, '气压带和风带', 'concept', '人教版', '第二章', '第三节', 30, 5, '全球气压带风带的分布、移动及其对气候的影响', 
  '{"knowledge": "掌握三圈环流和气压带风带", "ability": "分析气压带风带对气候的影响", "literacy": "建立全球视野"}',
  '["对气压带风带的季节移动规律掌握不牢", "难以应用到具体区域气候分析"]',
  '["https://resources.edu/global_circulation.mp4", "https://models.edu/pressure_belts_3d"]'),
  
(7, '常见天气系统', 'case', '人教版', '第二章', '第四节', 35, 4, '锋面系统、低压高压系统及其对天气的影响', 
  '{"knowledge": "识别常见天气系统", "ability": "读图分析天气变化", "literacy": "关注天气预报应用"}',
  '["冷暖锋过境前中后的天气特征容易混淆", "气旋反气旋概念理解不清"]',
  '["https://resources.edu/weather_systems.mp4"]'),
  
(8, '水循环', 'principle', '人教版', '第三章', '第一节', 45, 3, '水循环的过程、类型和地理意义', 
  '{"knowledge": "理解水循环过程和意义", "ability": "绘制水循环示意图", "literacy": "树立水资源保护意识"}',
  '["对不同类型水循环的环节理解不全", "水循环意义记忆不准确"]',
  '["https://resources.edu/water_cycle.mp4", "https://models.edu/water_cycle_3d"]'),
  
(9, '洋流', 'concept', '人教版', '第三章', '第二节', 50, 4, '世界洋流的分布规律及其对地理环境的影响', 
  '{"knowledge": "掌握世界主要洋流分布", "ability": "分析洋流对地理环境的影响", "literacy": "关注海洋环境保护"}',
  '["记忆洋流名称和位置困难", "对风海流和补偿流理解不深"]',
  '["https://resources.edu/ocean_currents.mp4"]'),
  
(10, '地质作用', 'concept', '人教版', '第四章', '第一节', 60, 3, '内力作用和外力作用及其对地表形态的影响', 
  '{"knowledge": "认识地质作用类型", "ability": "分析地质作用对地貌的塑造", "literacy": "理解地表形态演化"}',
  '["对内外力作用的区别和联系理解不够", "难以判断具体地貌的成因"]',
  '["https://resources.edu/geological_process.mp4"]'),
  
(11, '板块构造学说', 'principle', '人教版', '第四章', '第二节', 65, 4, '六大板块的分布及板块运动对地表形态的影响', 
  '{"knowledge": "理解板块构造学说", "ability": "运用板块理论解释地理现象", "literacy": "建立动态地球观"}',
  '["对板块边界类型和特征混淆", "难以应用板块理论解释实际问题"]',
  '["https://resources.edu/plate_tectonics.mp4", "https://models.edu/plates_3d"]'),
  
(12, '山地的形成', 'case', '人教版', '第四章', '第三节', 70, 4, '褶皱山、断块山和火山的形成过程', 
  '{"knowledge": "了解不同类型山地的形成", "ability": "识别山地类型", "literacy": "认识地形对人类活动的影响"}',
  '["对背斜成谷、向斜成山的特殊情况理解不透", "混淆褶皱和断层"]',
  '["https://resources.edu/mountain_formation.mp4"]'),
  
(13, '河流地貌的发育', 'case', '人教版', '第四章', '第四节', 75, 3, '河流侵蚀、搬运、堆积作用形成的地貌', 
  '{"knowledge": "理解河流地貌类型", "ability": "分析河流地貌形成过程", "literacy": "关注河流开发与保护"}',
  '["对河流上中下游地貌特征区分不清", "河流阶地形成过程理解困难"]',
  '["https://resources.edu/river_landforms.mp4"]'),
  
(14, '自然地理环境的整体性', 'principle', '人教版', '第五章', '第一节', 85, 4, '地理环境各要素相互作用的整体性特征', 
  '{"knowledge": "理解地理环境整体性", "ability": "分析地理要素相互作用", "literacy": "树立系统观念"}',
  '["对牵一发而动全身的原理理解不深", "难以举例说明整体性表现"]',
  '["https://resources.edu/environment_integrity.mp4"]'),
  
(15, '自然地理环境的差异性', 'principle', '人教版', '第五章', '第二节', 90, 4, '地理环境的地域分异规律', 
  '{"knowledge": "掌握地域分异规律", "ability": "识别和解释分异现象", "literacy": "因地制宜思想"}',
  '["对三大分异规律的影响因素记忆混乱", "难以判断具体地区的分异类型"]',
  '["https://resources.edu/regional_differentiation.mp4"]'),
  
(16, '人口增长模式', 'concept', '人教版', '第六章', '第一节', 100, 3, '人口增长的时空变化及其影响因素', 
  '{"knowledge": "理解人口增长模式转变", "ability": "分析人口问题", "literacy": "关注人口可持续发展"}',
  '["对不同国家人口增长模式判断失误", "人口金字塔图解读困难"]',
  '["https://resources.edu/population_growth.mp4"]'),
  
(17, '人口迁移', 'concept', '人教版', '第六章', '第二节', 105, 3, '人口迁移的原因、影响及其地区差异', 
  '{"knowledge": "了解人口迁移特点", "ability": "分析人口迁移的影响", "literacy": "理解人口流动现象"}',
  '["对人口迁移的推拉理论理解不透", "难以全面分析迁移影响"]',
  '["https://resources.edu/population_migration.mp4"]'),
  
(18, '城市空间结构', 'concept', '人教版', '第六章', '第三节', 110, 4, '城市功能分区及其形成原因', 
  '{"knowledge": "认识城市空间结构", "ability": "分析城市功能分区", "literacy": "关注城市规划"}',
  '["对不同功能区的特征和位置关系混淆", "地租理论应用困难"]',
  '["https://resources.edu/urban_structure.mp4"]'),
  
(19, '城市化', 'concept', '人教版', '第六章', '第四节', 115, 4, '城市化的进程、特点及其对地理环境的影响', 
  '{"knowledge": "理解城市化过程", "ability": "分析城市化问题", "literacy": "树立可持续城市发展观"}',
  '["对发达国家和发展中国家城市化差异认识不清", "城市化问题分析不全面"]',
  '["https://resources.edu/urbanization.mp4"]'),
  
(20, '农业区位因素', 'principle', '人教版', '第七章', '第一节', 125, 4, '影响农业区位选择的主要因素', 
  '{"knowledge": "掌握农业区位因素", "ability": "分析农业区位选择", "literacy": "关注农业可持续发展"}',
  '["对自然和社会经济因素的主导作用判断失误", "农业区位因素变化趋势理解不够"]',
  '["https://resources.edu/agriculture_location.mp4"]');

-- ==================== 知识图谱关系 ====================
INSERT INTO knowledge_relations (source_node_id, target_node_id, relation_type, strength, description) VALUES
(1, 2, 'related', 0.9, '地球宇宙环境与太阳影响密切相关'),
(2, 5, 'application', 0.8, '太阳辐射是大气热力作用的能量来源'),
(3, 10, 'prerequisite', 0.85, '了解地球圈层结构是学习地质作用的基础'),
(4, 5, 'prerequisite', 0.9, '大气组成和分层是理解热力作用的前提'),
(5, 6, 'prerequisite', 0.85, '大气热力作用影响气压带风带形成'),
(6, 7, 'application', 0.8, '气压带风带影响天气系统'),
(8, 9, 'related', 0.7, '水循环与洋流相互影响'),
(10, 11, 'related', 0.9, '地质作用与板块构造密切相关'),
(11, 12, 'application', 0.85, '板块运动导致山地形成'),
(10, 13, 'application', 0.8, '外力作用形成河流地貌'),
(14, 15, 'contrast', 0.9, '整体性与差异性是统一的两个方面'),
(16, 17, 'related', 0.8, '人口增长影响人口迁移'),
(17, 19, 'related', 0.85, '人口迁移推动城市化'),
(18, 19, 'prerequisite', 0.8, '城市空间结构在城市化过程中演变');

-- ==================== 概念卡片 ====================
INSERT INTO concept_cards (knowledge_node_id, title, anchor_page, content_text, content_media, quick_test) VALUES
(1, '地球的宇宙环境', 5, 
  '地球是太阳系中一颗既普通又特殊的行星。它位于太阳系八大行星之中，处于一个稳定而安全的宇宙环境中。\n\n天体系统层次：地月系→太阳系→银河系→总星系\n\n地球的特殊性：\n1. 稳定的光照条件\n2. 安全的宇宙环境\n3. 适宜的大气条件\n4. 液态水的存在',
  '{"images": ["/resources/universe1.jpg", "/resources/solar_system.jpg"], "videos": ["/resources/universe.mp4"]}',
  '{"questions": [{"q": "地球属于哪个行星系统？", "options": ["A.地月系", "B.太阳系", "C.银河系", "D.河外星系"], "answer": "B"}]}'),
  
(2, '太阳对地球的影响', 10,
  '太阳是离地球最近的恒星，为地球提供光和热。\n\n太阳辐射：\n- 电磁波辐射\n- 能量来源：核聚变反应\n- 对地球的影响：光热能源、生物活动、大气运动、水循环\n\n太阳活动：\n- 主要标志：太阳黑子、耀斑\n- 周期：约11年\n- 影响：干扰电离层、磁暴、极光',
  '{"images": ["/resources/sun.jpg", "/resources/solar_activity.jpg"], "videos": ["/resources/solar_flare.mp4"]}',
  '{"questions": [{"q": "太阳活动的主要标志是？", "options": ["A.黑子和耀斑", "B.日珥和日冕", "C.太阳风", "D.以上都是"], "answer": "A"}]}'),
  
(6, '气压带和风带', 30,
  '全球气压带和风带的形成与分布\n\n三圈环流：\n- 低纬环流（0°-30°）\n- 中纬环流（30°-60°）\n- 高纬环流（60°-90°）\n\n七个气压带：\n- 赤道低气压带\n- 副热带高气压带（南北各一）\n- 副极地低气压带（南北各一）\n- 极地高气压带（南北各一）\n\n六个风带：\n- 信风带（南北各一）\n- 西风带（南北各一）\n- 极地东风带（南北各一）',
  '{"images": ["/resources/pressure_belts.jpg"], "videos": ["/resources/global_circulation.mp4"], "3d_models": ["/models/pressure_belts_3d"]}',
  '{"questions": [{"q": "副热带高气压带大致位于？", "options": ["A.南北纬30°附近", "B.南北纬60°附近", "C.赤道附近", "D.两极地区"], "answer": "A"}]}');

-- ==================== 课程数据 ====================
INSERT INTO courses (id, class_id, name, chapter, section, knowledge_nodes, lesson_plan, scheduled_time, actual_time, duration, status) VALUES
(1, 1, '地球的宇宙环境', '第一章', '第一节', '[1]', '本节课介绍地球在宇宙中的位置...', '2024-03-20 08:00:00', '2024-03-20 08:00:00', 45, 'completed'),
(2, 1, '太阳对地球的影响', '第一章', '第二节', '[2]', '本节课学习太阳辐射和太阳活动...', '2024-03-21 08:00:00', '2024-03-21 08:00:00', 45, 'completed'),
(3, 1, '大气的组成和垂直分层', '第二章', '第一节', '[4]', '本节课探讨大气的结构特征...', '2024-03-22 08:00:00', '2024-03-22 08:00:00', 45, 'completed'),
(4, 1, '大气的热力作用', '第二章', '第二节', '[5]', '本节课学习大气对太阳辐射的作用...', '2024-03-25 08:00:00', NULL, 45, 'scheduled'),
(5, 2, '地球的宇宙环境', '第一章', '第一节', '[1]', '本节课介绍地球在宇宙中的位置...', '2024-03-20 09:00:00', '2024-03-20 09:00:00', 45, 'completed'),
(6, 3, '气压带和风带', '第二章', '第三节', '[6]', '本节课学习全球气压带和风带...', '2024-03-21 10:00:00', '2024-03-21 10:00:00', 45, 'completed');

-- ==================== 虚拟角色（已在schema中插入，这里补充更多） ====================
-- schema中已有基础数据

-- ==================== 课堂互动记录 ====================
INSERT INTO classroom_interactions (course_id, student_id, interaction_type, content, ai_response, response_time_ms, is_correct, score, attention_level, emotion, created_at) VALUES
(1, 101, 'question', '老师，为什么地球上有生命？', '地球具备适宜生命存在的条件：稳定的太阳光照、安全的宇宙环境、适宜的温度、液态水和适合生物呼吸的大气...', 1200, NULL, NULL, 5, 'happy', '2024-03-20 08:15:00'),
(1, 102, 'answer', '因为地球有大气和水', 'AI助手：你的回答抓住了关键点！地球确实因为有大气和液态水而适宜生命存在。', 800, TRUE, 8, 4, 'happy', '2024-03-20 08:20:00'),
(1, 103, 'emoji', '👍', NULL, NULL, NULL, NULL, 4, 'happy', '2024-03-20 08:25:00'),
(2, 101, 'question', '太阳黑子是怎么形成的？', '太阳黑子是太阳光球层上的暗黑斑点，是太阳活动的重要标志。它的形成与太阳内部磁场活动有关...', 1500, NULL, NULL, 5, 'confused', '2024-03-21 08:10:00'),
(2, 104, 'answer', '太阳活动周期是11年', 'AI助手：完全正确！太阳活动的平均周期确实是11年左右。', 750, TRUE, 10, 5, 'happy', '2024-03-21 08:30:00'),
(3, 101, 'question', '对流层和平流层有什么区别？', '对流层气温随高度降低，天气现象复杂；平流层气温随高度升高，大气稳定，适合飞行...', 1100, NULL, NULL, 4, 'neutral', '2024-03-22 08:20:00'),
(3, 105, 'vote', '选项A', NULL, NULL, TRUE, 5, 4, 'neutral', '2024-03-22 08:35:00');

-- ==================== 地理小游戏（schema中已有基础数据，这里补充更多） ====================
INSERT INTO geography_games (name, game_type, description, difficulty_level, knowledge_points, duration_minutes) VALUES
('世界地理探险', 'geography_monopoly', '环游世界各大洲，学习地理知识，收集地标', 3, '[1,2,3,6,9]', 15),
('气候类型识别挑战', 'climate_puzzle', '根据气候特征识别气候类型并拼图', 3, '[4,5,6]', 10),
('板块运动模拟', 'disaster_simulation', '模拟板块碰撞和分离，理解地质作用', 4, '[10,11,12]', 20),
('地理知识竞答', 'riddle', '限时抢答地理题目，考验反应和知识储备', 2, '[14,15,16,17,18,19,20]', 8);

-- ==================== 游戏记录 ====================
INSERT INTO game_records (game_id, course_id, student_id, score, correct_count, total_count, duration_seconds, game_data, created_at) VALUES
(1, 1, 101, 85, 17, 20, 540, '{"achievements": ["地理小达人", "速度之星"], "wrong_questions": [3, 8, 15]}', '2024-03-20 08:40:00'),
(1, 1, 102, 90, 18, 20, 560, '{"achievements": ["地理小达人"], "wrong_questions": [5, 12]}', '2024-03-20 08:42:00'),
(2, 2, 103, 75, 15, 20, 600, '{"achievements": [], "wrong_questions": [2, 7, 9, 11, 18]}', '2024-03-21 08:50:00'),
(2, 2, 104, 95, 19, 20, 520, '{"achievements": ["满分王", "地理天才"], "wrong_questions": [14]}', '2024-03-21 08:48:00'),
(3, 3, 105, 80, 16, 20, 580, '{"achievements": ["进步之星"], "wrong_questions": [1, 6, 10, 16]}', '2024-03-22 09:00:00');

-- ==================== 作业数据 ====================
INSERT INTO assignments (id, course_id, class_id, teacher_id, title, description, assignment_type, knowledge_nodes, total_score, due_date, auto_grade, created_at) VALUES
(1, 1, 1, 1, '第一章第一节课后练习', '地球的宇宙环境相关练习题', 'practice', '[1]', 100, '2024-03-21 23:59:59', TRUE, '2024-03-20 09:00:00'),
(2, 2, 1, 1, '第一章第二节预习作业', '预习太阳对地球的影响', 'preview', '[2]', 50, '2024-03-21 07:00:00', TRUE, '2024-03-20 18:00:00'),
(3, 3, 1, 1, '大气层结构思维导图', '绘制大气垂直分层思维导图', 'practice', '[4]', 100, '2024-03-23 23:59:59', FALSE, '2024-03-22 09:00:00'),
(4, 5, 2, 2, '地球宇宙环境复习题', '第一节复习巩固', 'review', '[1]', 100, '2024-03-22 23:59:59', TRUE, '2024-03-20 10:00:00'),
(5, 6, 3, 3, '气压带风带分析', '分析气压带风带对气候的影响', 'practice', '[6]', 100, '2024-03-24 23:59:59', FALSE, '2024-03-21 11:00:00');

-- ==================== 学生作业提交 ====================
INSERT INTO assignment_submissions (assignment_id, student_id, answers, submit_time, score, auto_score, teacher_score, feedback, ai_comment, status, duration_seconds) VALUES
(1, 101, '{"q1": "B", "q2": "ACD", "q3": "太阳系", "q4": "液态水、适宜温度、大气层"}', '2024-03-20 20:30:00', 92, 92, NULL, '优秀！', 'AI评语：对地球宇宙环境的理解很到位，继续保持！', 'graded', 1800),
(1, 102, '{"q1": "B", "q2": "AC", "q3": "太阳系", "q4": "有水和空气"}', '2024-03-20 21:15:00', 78, 78, NULL, '不错，但第2题和第4题需要更全面', 'AI评语：基本概念掌握良好，部分答案需要更详细。', 'graded', 2100),
(1, 103, '{"q1": "B", "q2": "ABCD", "q3": "太阳系", "q4": "稳定光照、安全环境、液态水、大气层"}', '2024-03-21 19:00:00', 95, 95, NULL, '非常好！', 'AI评语：答案完整准确，对知识点掌握扎实！', 'graded', 1650),
(2, 101, '{"preview_notes": "太阳辐射是地球能量的主要来源...", "questions": ["太阳黑子是什么？", "太阳活动周期?"]}', '2024-03-21 06:30:00', 45, 45, NULL, NULL, 'AI评语：预习认真，提出的问题很有针对性。', 'graded', 900),
(3, 101, '{}', NULL, NULL, NULL, NULL, NULL, NULL, 'in_progress', 450),
(4, 106, '{"q1": "B", "q2": "ABC", "q3": "太阳系"}', '2024-03-21 22:00:00', 88, 88, NULL, '良好', 'AI评语：掌握不错，继续努力！', 'graded', 1500),
(4, 107, '{"q1": "A", "q2": "AD", "q3": "银河系"}', '2024-03-22 20:00:00', 45, 45, NULL, '需要加强复习', 'AI评语：部分概念混淆，建议重新学习教材第一节内容。', 'graded', 2400);

-- ==================== 错题本 ====================
INSERT INTO error_questions (student_id, question_type, question_content, correct_answer, student_answer, knowledge_node_id, error_reason, explanation, mastery_level, review_count, last_review_time, source_type, source_id) VALUES
(102, 'multi_choice', '地球上存在生命的条件包括（    ）\nA.稳定的太阳光照  B.安全的宇宙环境  C.适宜的温度  D.液态水的存在', 'ABCD', 'AC', 1, 'concept_error', 
  '地球上生命存在需要多个条件共同作用：\n1. 稳定的太阳光照提供能量\n2. 安全的宇宙环境（小行星撞击少）\n3. 适宜的温度条件\n4. 液态水的存在\n这四个条件缺一不可。', 
  2, 0, NULL, 'assignment', 1),
  
(102, 'short_answer', '说明地球上存在生命的主要原因', '1.稳定的太阳光照 2.安全的宇宙环境 3.适宜的温度条件 4.液态水的存在 5.适合生物呼吸的大气', '有水和空气', 1, 'comprehensive', 
  '这道题需要全面回答，不能只说一两点。地球生命存在的条件是多方面的，包括能量、环境、温度、水、大气等多个因素。答题时要注意全面性。', 
  1, 1, '2024-03-21 20:00:00', 'assignment', 1),
  
(107, 'choice', '地球所属的行星系统是（   ）\nA.地月系  B.太阳系  C.银河系  D.总星系', 'B', 'A', 1, 'concept_error',
  '需要区分不同层次的天体系统：\n- 地月系：地球和月球组成的系统\n- 太阳系：太阳和八大行星及其他天体组成的系统\n- 银河系：包含数千亿颗恒星的星系\n- 总星系：目前人类能观测到的宇宙范围\n\n地球是太阳系中的一颗行星。',
  1, 0, NULL, 'assignment', 4),
  
(103, 'choice', '太阳活动的主要标志是（   ）\nA.太阳黑子和耀斑  B.日珥  C.太阳风  D.日冕', 'A', 'D', 2, 'concept_error',
  '太阳活动的主要标志是太阳黑子（光球层）和耀斑（色球层）。\n- 太阳黑子：光球层上的暗黑斑点，是太阳活动强弱的标志\n- 耀斑：色球层上的亮斑，是太阳活动最激烈的显示\n- 日珥、太阳风、日冕也是太阳活动的表现，但不是主要标志',
  2, 1, '2024-03-22 19:00:00', 'game', 2);

-- ==================== 答疑记录 ====================
INSERT INTO qa_records (student_id, question_type, question_text, knowledge_nodes, ai_answer, answer_quality, resolution_status, response_time_ms, student_rating, created_at) VALUES
(101, 'text', '为什么地球上有生命而火星上没有？', '[1]', 
  '这是一个很好的问题！地球和火星的主要区别在于：\n\n1. **大气条件**：地球有浓密的大气层，可以保温和保护；火星大气稀薄，无法保存热量\n2. **液态水**：地球表面有丰富的液态水；火星表面极度干燥，水主要以冰的形式存在于两极\n3. **温度**：地球平均温度15℃左右，适宜生命生存；火星平均温度-55℃，过于寒冷\n4. **磁场**：地球有强磁场保护，阻挡太阳风；火星磁场很弱，无法有效保护\n5. **距离太阳**：地球处于太阳系宜居带，接收适量太阳辐射；火星距离太阳较远，接收能量少\n\n这些条件的综合作用使地球成为太阳系中唯一已知存在生命的星球。', 
  5, 'satisfied', 1800, 5, '2024-03-20 19:00:00'),

(102, 'text', '平流层为什么气温会随高度升高？', '[4]', 
  '平流层（约10-50km）气温随高度升高的原因是**臭氧吸收紫外线**。\n\n具体过程：\n1. 平流层中存在臭氧层（主要在20-25km）\n2. 臭氧（O₃）强烈吸收太阳紫外线\n3. 吸收紫外线后臭氧分解为氧气，释放热量\n4. 越往上臭氧越多，吸收紫外线越多，温度越高\n\n这种气温递增的特点使平流层大气稳定，对流运动弱，适合飞机飞行。', 
  5, 'satisfied', 1200, 5, '2024-03-22 20:30:00'),

(103, 'voice', '气压带和风带是怎么形成的？', '[6]',
  '气压带和风带的形成是三圈环流的结果，让我为你详细解释：\n\n**形成过程：**\n1. **热力原因**：赤道受热多，空气上升形成低压；极地受热少，空气下沉形成高压\n2. **动力原因**：高空气流从赤道流向极地，在30°附近堆积下沉，形成副热带高压\n3. **地转偏向力**：南北气流运动过程中受地转偏向力影响，形成东西向的风带\n\n**三圈环流：**\n- 低纬环流（0°-30°）：信风带\n- 中纬环流（30°-60°）：西风带\n- 高纬环流（60°-90°）：极地东风带\n\n**气压带分布：**\n- 赤道低气压带、副热带高气压带、副极地低气压带、极地高气压带\n\n这些气压带和风带控制着全球的气候分布。',
  5, 'satisfied', 2400, 5, '2024-03-21 21:00:00'),

(104, 'image', '这张等高线地形图怎么判断地形类型？', '[13]',
  '根据你上传的等高线地形图，我来教你判断方法：\n\n**基本原则：**\n1. **等高线数值**：从中心向外数值增大→山顶；数值减小→盆地\n2. **等高线形状**：\n   - 向高处凸出→山谷\n   - 向低处凸出→山脊\n   - 闭合向内升高→山顶\n   - 闭合向内降低→盆地或洼地\n3. **等高线密集程度**：密集→坡度陡；稀疏→坡度缓\n\n**你的图片分析：**\n观察图中等高线从500m递增到800m，中心区域形成闭合曲线，判断为**山顶**地形。西侧等高线密集，东侧稀疏，说明西坡较陡，东坡较缓。\n\n建议多练习等高线地形图的判读，这是地理学习的重要技能！',
  5, 'satisfied', 3000, 5, '2024-03-22 21:30:00'),

(105, 'text', '冷锋和暖锋有什么区别？', '[7]',
  '冷锋和暖锋是两种重要的锋面系统，主要区别如下：\n\n**冷锋（冷气团主动向暖气团移动）：**\n- 符号：▲▲▲（三角朝向移动方向）\n- 坡度：较陡\n- 降水位置：锋后\n- 降水特点：强度大、时间短\n- 天气变化：气温降低、气压升高、天气转晴\n- 举例：我国北方冬季爆发的寒潮\n\n**暖锋（暖气团主动向冷气团移动）：**\n- 符号：●●●（半圆朝向移动方向）\n- 坡度：较缓\n- 降水位置：锋前\n- 降水特点：强度小、时间长\n- 天气变化：气温升高、气压降低、连续性降水\n- 举例：我国江淮地区春季\n\n**记忆技巧：**\n"冷快暖慢"——冷锋移动快、暖锋移动慢\n"冷后暖前"——冷锋降水在锋后、暖锋降水在锋前',
  5, 'satisfied', 1500, 5, '2024-03-23 19:00:00');

-- ==================== 学习报告 ====================
INSERT INTO learning_reports (student_id, report_type, start_date, end_date, study_duration_minutes, knowledge_mastery, weak_points, ability_radar, progress_trend, suggestions, statistics) VALUES
(101, 'weekly', '2024-03-18', '2024-03-24', 420, 
  '{"chapter1": 0.92, "chapter2": 0.75, "chapter3": 0.68}',
  '[{"node_id": 5, "name": "大气的热力作用", "mastery": 0.65}, {"node_id": 8, "name": "水循环", "mastery": 0.70}]',
  '{"knowledge": 85, "ability": 78, "practice": 82, "thinking": 75, "expression": 80}',
  '{"dates": ["3-18", "3-19", "3-20", "3-21", "3-22", "3-23", "3-24"], "scores": [75, 78, 82, 85, 83, 88, 90]}',
  '本周学习表现优秀！建议：\n1. 加强"大气的热力作用"相关知识点的理解，可以观看配套视频\n2. 多做水循环相关的综合题\n3. 保持当前良好的学习节奏',
  '{"assignment_completed": 3, "assignment_total": 3, "average_score": 88.3, "study_days": 6, "qa_count": 2, "game_count": 1}'),

(102, 'weekly', '2024-03-18', '2024-03-24', 380,
  '{"chapter1": 0.82, "chapter2": 0.70, "chapter3": 0.65}',
  '[{"node_id": 1, "name": "地球的宇宙环境", "mastery": 0.75}, {"node_id": 4, "name": "大气的组成和垂直分层", "mastery": 0.68}]',
  '{"knowledge": 78, "ability": 72, "practice": 75, "thinking": 70, "expression": 73}',
  '{"dates": ["3-18", "3-19", "3-20", "3-21", "3-22", "3-23", "3-24"], "scores": [70, 72, 75, 78, 76, 75, 78]}',
  '本周学习较为稳定。建议：\n1. 对知识点的理解需要更深入，不要停留在表面记忆\n2. 针对错题本中的错题进行专项复习\n3. 增加与老师和同学的互动交流',
  '{"assignment_completed": 2, "assignment_total": 3, "average_score": 78.0, "study_days": 5, "qa_count": 1, "game_count": 1}'),

(103, 'weekly', '2024-03-18', '2024-03-24', 450,
  '{"chapter1": 0.95, "chapter2": 0.88, "chapter3": 0.82}',
  '[{"node_id": 6, "name": "气压带和风带", "mastery": 0.85}]',
  '{"knowledge": 92, "ability": 88, "practice": 90, "thinking": 85, "expression": 87}',
  '{"dates": ["3-18", "3-19", "3-20", "3-21", "3-22", "3-23", "3-24"], "scores": [85, 88, 90, 92, 90, 93, 95]}',
  '非常优秀的学习表现！建议：\n1. 继续保持当前的学习状态\n2. 可以尝试一些拓展性的学习内容\n3. 帮助其他同学，在教学相长中进一步提升',
  '{"assignment_completed": 3, "assignment_total": 3, "average_score": 95.0, "study_days": 7, "qa_count": 0, "game_count": 1}');

-- ==================== 个性化学习路径 ====================
INSERT INTO learning_paths (student_id, current_level, target_level, weak_knowledge_nodes, recommended_sequence, custom_resources, difficulty_adaptation, progress) VALUES
(101, 4, 5, 
  '[5, 8]',
  '[{"step": 1, "content": "复习大气组成和分层", "node_id": 4, "resources": ["/video/atmosphere.mp4"]}, 
    {"step": 2, "content": "深入学习大气热力作用", "node_id": 5, "resources": ["/video/heat.mp4", "/practice/heat_10q.pdf"]},
    {"step": 3, "content": "理解水循环过程", "node_id": 8, "resources": ["/video/water_cycle.mp4"]}]',
  '["/resources/heat_advanced.pdf", "/practice/comprehensive_01.pdf"]',
  '{"current_difficulty": 4, "recommend_difficulty": 4, "adjustment": "maintain"}',
  0.35),

(102, 3, 4,
  '[1, 4, 5]',
  '[{"step": 1, "content": "重新学习地球的宇宙环境", "node_id": 1, "resources": ["/video/universe.mp4", "/reading/earth_basic.pdf"]},
    {"step": 2, "content": "巩固大气基础知识", "node_id": 4, "resources": ["/video/atmosphere_basic.mp4"]},
    {"step": 3, "content": "理解大气热力作用", "node_id": 5, "resources": ["/video/heat_simple.mp4"]}]',
  '["/resources/basic_practice.pdf", "/practice/foundation_20q.pdf"]',
  '{"current_difficulty": 3, "recommend_difficulty": 3, "adjustment": "simplify"}',
  0.15),

(103, 5, 5,
  '[6]',
  '[{"step": 1, "content": "挑战气压带风带难题", "node_id": 6, "resources": ["/practice/pressure_hard.pdf", "/video/global_circulation_deep.mp4"]}]',
  '["/resources/advanced_analysis.pdf", "/practice/comprehensive_hard.pdf"]',
  '{"current_difficulty": 5, "recommend_difficulty": 5, "adjustment": "challenge"}',
  0.80);

-- ==================== 虚拟实验（本科） ====================
INSERT INTO virtual_experiments (id, name, experiment_type, description, difficulty_level, knowledge_points, vr_scene_url, duration_minutes) VALUES
(1, '野外地质考察模拟', 'field_survey', '模拟野外地质考察，识别岩石类型、地质构造', 4, '[10,11,12]', '/vr/field_survey', 45),
(2, '火山喷发模拟', 'volcano', '模拟火山喷发过程，观察岩浆活动和火山地貌形成', 4, '[11,12]', '/vr/volcano', 30),
(3, '河流水文观测', 'hydrology', '模拟河流流量、流速、含沙量等水文要素观测', 3, '[8,13]', '/vr/river_hydrology', 40),
(4, '气象观测实验', 'meteorology', '使用虚拟气象仪器观测温度、湿度、气压、风速等', 3, '[4,5,7]', '/vr/meteorology', 35),
(5, '太阳系探索', 'universe', '探索太阳系八大行星，理解天体运动规律', 3, '[1,2]', '/vr/solar_system', 30);

-- ==================== 实验记录（本科） ====================
INSERT INTO experiment_records (experiment_id, student_id, start_time, end_time, operation_data, collected_data, analysis_result, score, ai_feedback, status) VALUES
(1, 201, '2024-03-20 14:00:00', '2024-03-20 14:45:00',
  '{"tools_used": ["地质锤", "放大镜", "罗盘"], "locations": ["A点", "B点", "C点"]}',
  '{"rock_samples": [{"location": "A", "type": "花岗岩"}, {"location": "B", "type": "砂岩"}, {"location": "C", "type": "板岩"}], "structures": ["断层", "褶皱"]}',
  '{"rock_identification_accuracy": 0.9, "structure_analysis": "正确识别了断层和褶皱", "report_quality": "详细"}',
  88, 'AI反馈：野外考察技能良好，岩石鉴定准确，建议进一步学习地质构造分析方法。', 'completed'),

(3, 202, '2024-03-21 10:00:00', '2024-03-21 10:40:00',
  '{"instruments": ["流速仪", "测深仪", "采样器"], "measurement_points": 5}',
  '{"flow_rate": [1.2, 1.5, 1.8, 1.6, 1.3], "depth": [2.5, 3.2, 3.8, 3.5, 2.8], "sediment_concentration": [0.5, 0.8, 1.2, 0.9, 0.6]}',
  '{"average_flow_rate": 1.48, "average_depth": 3.16, "sediment_load": "中等"}',
  85, 'AI反馈：数据采集规范，分析合理，建议增加测量断面以提高结果准确性。', 'completed'),

(4, 203, '2024-03-22 15:00:00', '2024-03-22 15:32:00',
  '{"instruments": ["温度计", "湿度计", "气压计", "风速风向仪"], "observation_interval": "5分钟"}',
  '{"temperature": [18.5, 19.2, 19.8, 20.1, 20.3, 20.5], "humidity": [65, 63, 62, 60, 59, 58], "pressure": [1013, 1013, 1014, 1014, 1015, 1015], "wind_speed": [3.2, 3.5, 3.8, 4.0, 4.2, 4.5]}',
  '{"temperature_trend": "上升", "humidity_trend": "下降", "pressure_trend": "稳中有升", "weather_forecast": "晴朗"}',
  90, 'AI反馈：观测数据完整，趋势分析正确，天气预测合理，实验操作熟练。', 'completed');

-- ==================== 地学交流频道（本科） ====================
INSERT INTO geo_channels (id, name, creator_id, channel_type, category, description, cover_image, member_count, post_count, is_public) VALUES
(1, '地球科学前沿', 201, 'research', '综合地学', '讨论地球科学领域的最新研究成果和前沿动态', '/channels/earth_science.jpg', 15, 28, TRUE),
(2, '地理信息系统技术', 202, 'qa', 'GIS技术', 'GIS软件使用、数据处理、空间分析等技术交流', '/channels/gis.jpg', 23, 45, TRUE),
(3, '自然地理爱好者', 203, 'discussion', '自然地理', '分享自然景观、地貌特征、气候现象', '/channels/nature.jpg', 18, 32, TRUE),
(4, '人文地理研究', 204, 'research', '人文地理', '城市地理、人口地理、经济地理研究讨论', '/channels/human.jpg', 12, 19, TRUE);

-- ==================== 频道成员 ====================
INSERT INTO channel_members (channel_id, user_id, role) VALUES
(1, 201, 'owner'), (1, 202, 'member'), (1, 203, 'member'), (1, 204, 'member'), (1, 205, 'member'),
(2, 202, 'owner'), (2, 201, 'member'), (2, 203, 'admin'), (2, 205, 'member'),
(3, 203, 'owner'), (3, 201, 'member'), (3, 202, 'member'), (3, 204, 'member'),
(4, 204, 'owner'), (4, 201, 'member'), (4, 205, 'admin');

-- ==================== 频道帖子 ====================
INSERT INTO channel_posts (channel_id, author_id, title, content, media, tags, view_count, like_count, reply_count, is_pinned, created_at) VALUES
(1, 201, '最新Nature论文：板块构造新理论', '刚看到Nature上发表的一篇关于板块构造的新研究，对传统的板块边界理论提出了新的见解...\n\n主要观点：\n1. 板块边界并非完全固定\n2. 地幔柱对板块运动的影响被低估\n3. 新的模型更好地解释了某些地质现象\n\n大家怎么看？', 
  '{"images": ["/posts/nature_paper.jpg"], "pdfs": ["/posts/paper_abstract.pdf"]}', '["板块构造", "Nature", "地质学"]', 45, 12, 5, TRUE, '2024-03-20 10:00:00'),

(1, 202, '气候变化对冰川消融的影响', '最近研究了青藏高原冰川的变化数据，发现近20年来冰川面积减少了15%...\n\n数据来源：\n- 遥感影像分析\n- 实地考察记录\n- 气象站数据\n\n这对下游水资源会产生重大影响，值得关注。', 
  '{"images": ["/posts/glacier1.jpg", "/posts/glacier2.jpg"], "charts": ["/posts/glacier_data.png"]}', '["气候变化", "冰川", "遥感"]', 38, 9, 3, FALSE, '2024-03-21 14:30:00'),

(2, 203, 'ArcGIS空间分析常见问题汇总', '整理了一些ArcGIS空间分析中常见的问题和解决方法：\n\n1. 投影坐标系统不匹配\n2. 拓扑错误处理\n3. 栅格数据重采样\n4. 缓冲区分析技巧\n5. 叠加分析注意事项\n\n详细内容见附件...',
  '{"pdfs": ["/posts/arcgis_tips.pdf"], "videos": ["/posts/arcgis_demo.mp4"]}', '["ArcGIS", "空间分析", "技巧"]', 67, 23, 12, TRUE, '2024-03-19 16:00:00'),

(3, 203, '我国喀斯特地貌分布与特征', '整理了我国主要喀斯特地貌区的分布和特征：\n\n1. **桂林漓江**：峰林地貌，世界级景观\n2. **云南石林**：石林地貌，溶蚀作用典型\n3. **贵州织金洞**：地下洞穴系统，钟乳石发育完善\n\n附上实地拍摄的照片，欢迎讨论！',
  '{"images": ["/posts/karst1.jpg", "/posts/karst2.jpg", "/posts/karst3.jpg"]}', '["喀斯特", "地貌", "中国"]', 52, 15, 7, FALSE, '2024-03-22 11:00:00'),

(4, 204, '城市化进程中的土地利用变化研究', '以北京市为例，分析了近30年的土地利用变化：\n\n研究方法：\n- 遥感影像解译\n- 土地利用转移矩阵\n- 景观格局指数\n\n主要发现：\n1. 建设用地面积增加200%\n2. 耕地减少35%\n3. 城市扩展主要向东南方向\n\n',
  '{"images": ["/posts/landuse_map.jpg"], "excel": ["/posts/landuse_data.xlsx"]}', '["城市化", "土地利用", "北京"]', 41, 11, 4, FALSE, '2024-03-23 09:30:00');

-- ==================== 学术文献 ====================
INSERT INTO academic_literature (title, authors, journal, publish_year, doi, abstract, keywords, pdf_url, citation_count, knowledge_tags) VALUES
('中国气候变化的区域响应研究', '李明, 王华, 张强', '地理学报', 2023, '10.11821/dlxb202301001', 
  '本研究基于1980-2020年气象站数据，分析了中国不同区域对全球气候变化的响应特征。研究发现：东部地区气温上升幅度大于西部，降水变化呈现明显的地区差异...', 
  '["气候变化", "区域响应", "中国", "气温", "降水"]', '/literature/climate_2023.pdf', 15, '[4,5,6,7]'),

('The Impact of Climate Change on Global Water Resources', 'Smith, J., Johnson, M.', 'Nature Climate Change', 2023, '10.1038/ncc.2023.001',
  'This study examines the effects of climate change on global water resources using integrated assessment models...', 
  '["climate change", "water resources", "global", "sustainability"]', '/literature/water_2023.pdf', 28, '[8]'),

('城市热岛效应的遥感监测与分析', '刘涛, 陈晨, 赵敏', '遥感学报', 2022, '10.11834/jrs.20221234',
  '利用Landsat系列卫星数据，对上海市2000-2020年城市热岛效应进行了监测和分析...', 
  '["城市热岛", "遥感", "上海", "温度反演"]', '/literature/uhi_2022.pdf', 12, '[5,19]'),

('Plate Tectonics and Mountain Building', 'Wilson, R., Brown, A.', 'Geology', 2023, '10.1130/G50123.1',
  'New evidence supporting the relationship between plate tectonics and mountain formation...', 
  '["plate tectonics", "mountain building", "orogeny"]', '/literature/plate_2023.pdf', 22, '[11,12]');

-- ==================== 教案库 ====================
INSERT INTO lesson_plans (id, teacher_id, title, subject, grade, textbook_version, chapter, section, content, teaching_objectives, key_points, difficult_points, teaching_methods, resources, duration_minutes, is_public, view_count, use_count, rating) VALUES
(1, 1, '地球的宇宙环境', '地理', '高一', '人教版', '第一章', '第一节',
  '一、导入新课（5分钟）\n播放宇宙纪录片片段，激发学生兴趣\n提问：地球在宇宙中是什么位置？\n\n二、新课讲解（25分钟）\n1. 天体与天体系统\n2. 太阳系的八大行星\n3. 地球的普通性与特殊性\n4. 地球上生命存在的条件\n\n三、互动探究（10分钟）\n小组讨论：为什么火星上没有生命？\n学生展示讨论结果\n\n四、课堂小结（5分钟）\n梳理知识框架\n布置课后作业',
  '1. 知识目标：理解地球在宇宙中的位置，掌握天体系统的层次\n2. 能力目标：培养读图分析能力，学会比较分析方法\n3. 情感目标：树立科学宇宙观，激发探索精神',
  '1. 天体系统的层次关系\n2. 地球上存在生命的条件',
  '1. 宇宙中地球的特殊性理解\n2. 不同条件对生命存在的综合影响',
  '1. 问题引导法\n2. 多媒体演示法\n3. 小组讨论法\n4. 比较分析法',
  '{"videos": ["/resources/universe.mp4"], "ppt": "/resources/chapter1_section1.pptx", "3d_models": ["/models/solar_system_3d"], "worksheets": "/worksheets/earth_environment.pdf"}',
  45, TRUE, 23, 5, 4.5),

(2, 1, '太阳对地球的影响', '地理', '高一', '人教版', '第一章', '第二节',
  '一、复习导入（5分钟）\n回顾上节课内容\n提问：太阳对地球有哪些影响？\n\n二、新课讲解（28分钟）\n1. 太阳辐射\n   - 太阳辐射的概念\n   - 太阳辐射对地球的影响\n2. 太阳活动\n   - 太阳活动的主要类型\n   - 太阳活动的周期\n   - 太阳活动对地球的影响\n\n三、案例分析（8分钟）\n分析历史上的太阳风暴事件\n\n四、课堂总结（4分钟）',
  '1. 理解太阳辐射的意义\n2. 掌握太阳活动的类型和周期\n3. 分析太阳活动对地球的影响',
  '1. 太阳辐射对地球的影响\n2. 太阳活动的表现形式',
  '1. 太阳活动对地球的多方面影响\n2. 太阳黑子和耀斑的关系',
  '1. 讲授法\n2. 案例分析法\n3. 视频演示法',
  '{"videos": ["/resources/solar_activity.mp4"], "ppt": "/resources/chapter1_section2.pptx", "images": ["/images/sunspot.jpg", "/images/aurora.jpg"]}',
  45, TRUE, 18, 3, 4.3),

(3, 3, '气压带和风带', '地理', '高二', '湘教版', '第二章', '第三节',
  '一、导入（5分钟）\n播放全球大气环流动画\n\n二、新课（30分钟）\n1. 大气环流的形成\n2. 气压带和风带的分布\n3. 气压带和风带的季节移动\n4. 对气候的影响\n\n三、练习（8分钟）\n判读气压带风带分布图\n\n四、总结（2分钟）',
  '1. 理解三圈环流形成过程\n2. 掌握气压带风带的分布规律\n3. 分析气压带风带对气候的影响',
  '1. 气压带风带的分布\n2. 对气候的影响',
  '1. 三圈环流的形成机制\n2. 气压带风带的季节移动',
  '1. 动画演示法\n2. 读图分析法\n3. 讲练结合法',
  '{"videos": ["/resources/global_circulation.mp4"], "3d_models": ["/models/pressure_belts_3d"], "ppt": "/resources/pressure_wind.pptx"}',
  45, TRUE, 31, 8, 4.7);

-- ==================== 课堂监测数据 ====================
INSERT INTO classroom_monitoring (course_id, monitoring_time, average_attention, emotion_distribution, interaction_stats, hot_questions, blind_spots, teaching_pace_suggestion) VALUES
(1, '2024-03-20 08:45:00', 4.2, 
  '{"happy": 0.65, "neutral": 0.25, "confused": 0.08, "bored": 0.02}',
  '{"total_interactions": 15, "questions": 5, "answers": 6, "games": 1, "votes": 3}',
  '["为什么地球上有生命？", "火星上为什么没有水？", "地球的年龄是多少？"]',
  '["光年的概念理解不够", "天体系统层次关系混淆"]',
  '整体教学节奏适中，学生专注度较高。建议对光年等天文单位多举例说明，增加理解度。'),

(2, '2024-03-21 08:45:00', 4.0,
  '{"happy": 0.55, "neutral": 0.30, "confused": 0.12, "bored": 0.03}',
  '{"total_interactions": 12, "questions": 4, "answers": 5, "games": 0, "votes": 3}',
  '["太阳黑子是怎么形成的？", "太阳活动为什么有周期？", "极光出现在哪些地区？"]',
  '["太阳活动类型容易混淆", "太阳活动对地球影响的理解不全面"]',
  '学生对太阳活动的兴趣较高，但理解有一定困难。建议增加视频演示，放慢讲解速度。'),

(3, '2024-03-22 08:45:00', 3.8,
  '{"happy": 0.50, "neutral": 0.32, "confused": 0.15, "bored": 0.03}',
  '{"total_interactions": 10, "questions": 3, "answers": 4, "games": 0, "votes": 3}',
  '["对流层和平流层有什么区别？", "为什么会有臭氧层？"]',
  '["大气分层的判断依据不清楚", "各层大气特征记忆混乱"]',
  '内容难度较大，部分学生跟不上。建议增加更多图示和动画，分步讲解。');

-- ==================== 教学资源 ====================
INSERT INTO teaching_resources (title, resource_type, category, knowledge_nodes, file_url, thumbnail_url, file_size, duration, description, tags, uploader_id, download_count, view_count, rating, is_public) VALUES
('地球宇宙环境3D演示', '3d_model', '自然地理', '[1]', '/resources/earth_universe_3d.glb', '/thumbs/earth_3d.jpg', 15728640, NULL, 
  '可交互的地球宇宙环境3D模型，展示天体系统层次', '["地球", "宇宙", "3D模型"]', 1, 45, 128, 4.8, TRUE),

('太阳活动周期动画', 'animation', '自然地理', '[2]', '/resources/solar_cycle.mp4', '/thumbs/solar.jpg', 52428800, 180,
  '太阳黑子变化的11年周期动画演示', '["太阳", "太阳活动", "动画"]', 1, 38, 95, 4.6, TRUE),

('大气垂直分层示意图', 'image', '自然地理', '[4]', '/resources/atmosphere_layers.svg', '/thumbs/atmosphere.jpg', 524288, NULL,
  '高清大气垂直分层结构示意图', '["大气", "分层", "示意图"]', 1, 67, 156, 4.7, TRUE),

('气压带风带分布3D模型', '3d_model', '自然地理', '[6]', '/resources/pressure_belts_3d.glb', '/thumbs/pressure_3d.jpg', 18874368, NULL,
  '可旋转的全球气压带风带分布3D模型，支持季节切换', '["气压带", "风带", "3D", "全球气候"]', 3, 52, 142, 4.9, TRUE),

('水循环过程虚拟实验', 'ar_scene', '自然地理', '[8]', '/resources/water_cycle_ar.zip', '/thumbs/water_ar.jpg', 41943040, NULL,
  'AR增强现实水循环演示，可在手机上查看', '["水循环", "AR", "虚拟实验"]', 1, 29, 73, 4.5, TRUE),

('板块构造学说视频课程', 'video', '自然地理', '[11]', '/resources/plate_tectonics.mp4', '/thumbs/plate.jpg', 104857600, 900,
  '详细讲解板块构造学说的形成和发展', '["板块构造", "视频课程", "地质学"]', 5, 83, 245, 4.8, TRUE),

('人口金字塔图绘制教程', 'document', '人文地理', '[16]', '/resources/population_pyramid.pdf', '/thumbs/population.jpg', 2097152, NULL,
  'Excel绘制人口金字塔图的详细教程', '["人口", "金字塔图", "Excel", "教程"]', 2, 56, 134, 4.4, TRUE),

('城市空间结构案例分析', 'document', '人文地理', '[18]', '/resources/urban_structure_cases.pdf', '/thumbs/urban.jpg', 5242880, NULL,
  '北京、上海、深圳等城市空间结构对比分析', '["城市", "空间结构", "案例"]', 2, 41, 98, 4.6, TRUE);

-- ==================== 用户行为日志（最近一周） ====================
INSERT INTO user_activity_logs (user_id, action_type, action_detail, ip_address, created_at) VALUES
(101, 'login', '用户登录系统', '192.168.1.100', '2024-03-20 07:55:00'),
(101, 'view_course', '查看课程：地球的宇宙环境', '192.168.1.100', '2024-03-20 08:00:00'),
(101, 'submit_assignment', '提交作业：第一章第一节课后练习', '192.168.1.100', '2024-03-20 20:30:00'),
(101, 'play_game', '参与游戏：气候拼图大挑战', '192.168.1.100', '2024-03-20 08:40:00'),
(101, 'ask_question', '提问：为什么地球上有生命而火星上没有？', '192.168.1.100', '2024-03-20 19:00:00'),
(102, 'login', '用户登录系统', '192.168.1.101', '2024-03-20 08:10:00'),
(102, 'view_course', '查看课程：地球的宇宙环境', '192.168.1.101', '2024-03-20 08:12:00'),
(102, 'submit_assignment', '提交作业：第一章第一节课后练习', '192.168.1.101', '2024-03-20 21:15:00'),
(103, 'login', '用户登录系统', '192.168.1.102', '2024-03-20 08:05:00'),
(201, 'login', '用户登录系统', '10.0.1.50', '2024-03-20 14:00:00'),
(201, 'start_experiment', '开始实验：野外地质考察模拟', '10.0.1.50', '2024-03-20 14:00:00'),
(201, 'complete_experiment', '完成实验：野外地质考察模拟', '10.0.1.50', '2024-03-20 14:45:00'),
(201, 'post_to_channel', '在频道发帖：最新Nature论文：板块构造新理论', '10.0.1.50', '2024-03-20 10:00:00');

-- ==================== 系统统计数据更新 ====================
-- 更新学校的课程数量等统计信息
-- 这些可以通过定时任务或触发器自动维护，这里手动设置初始值

-- 设置结束
SET FOREIGN_KEY_CHECKS = 1;

SELECT '✓ 测试数据导入完成！' as message;
SELECT '共插入:' as '', 
  (SELECT COUNT(*) FROM users) as '用户数',
  (SELECT COUNT(*) FROM schools) as '学校数',
  (SELECT COUNT(*) FROM classes) as '班级数',
  (SELECT COUNT(*) FROM knowledge_nodes) as '知识点数',
  (SELECT COUNT(*) FROM courses) as '课程数',
  (SELECT COUNT(*) FROM assignments) as '作业数',
  (SELECT COUNT(*) FROM qa_records) as '答疑数',
  (SELECT COUNT(*) FROM channel_posts) as '帖子数',
  (SELECT COUNT(*) FROM teaching_resources) as '资源数';
