import { query, queryOne, insert, execute } from '../config/database';

// ========== 类型定义 ==========
interface HotspotFilters {
  page: number;
  limit: number;
  category?: string;
  region?: string;
  startDate?: string;
  endDate?: string;
  keyword?: string;
}

interface Hotspot {
  id: number;
  title: string;
  summary: string;
  content: string;
  source: string;
  source_url: string;
  publish_date: string;
  category: string;
  region: string;
  latitude: number;
  longitude: number;
  cover_image: string;
  view_count: number;
  like_count: number;
  status: string;
  tags?: any[];
  media?: any[];
}

// ========== 热点列表 ==========
export async function getHotspots(filters: HotspotFilters) {
  const { page, limit, category, region, startDate, endDate, keyword } = filters;
  const offset = (page - 1) * limit;

  let sql = `
    SELECT h.*, 
           GROUP_CONCAT(DISTINCT t.name) as tags
    FROM geopolitics_hotspots h
    LEFT JOIN geopolitics_hotspot_tags ht ON h.id = ht.hotspot_id
    LEFT JOIN geopolitics_tags t ON ht.tag_id = t.id
    WHERE h.status = 'published'
  `;

  const params: any[] = [];

  if (category) {
    sql += ' AND h.category = ?';
    params.push(category);
  }

  if (region) {
    sql += ' AND h.region LIKE ?';
    params.push(`%${region}%`);
  }

  if (startDate) {
    sql += ' AND h.publish_date >= ?';
    params.push(startDate);
  }

  if (endDate) {
    sql += ' AND h.publish_date <= ?';
    params.push(endDate);
  }

  if (keyword) {
    sql += ' AND (h.title LIKE ? OR h.summary LIKE ?)';
    params.push(`%${keyword}%`, `%${keyword}%`);
  }

  sql += ' GROUP BY h.id ORDER BY h.publish_date DESC LIMIT ? OFFSET ?';
  params.push(limit, offset);

  const hotspots = await query<Hotspot>(sql, params);

  // 获取总数
  let countSql = 'SELECT COUNT(*) as total FROM geopolitics_hotspots h WHERE h.status = "published"';
  const countParams: any[] = [];

  if (category) {
    countSql += ' AND h.category = ?';
    countParams.push(category);
  }

  if (region) {
    countSql += ' AND h.region LIKE ?';
    countParams.push(`%${region}%`);
  }

  if (startDate) {
    countSql += ' AND h.publish_date >= ?';
    countParams.push(startDate);
  }

  if (endDate) {
    countSql += ' AND h.publish_date <= ?';
    countParams.push(endDate);
  }

  if (keyword) {
    countSql += ' AND (h.title LIKE ? OR h.summary LIKE ?)';
    countParams.push(`%${keyword}%`, `%${keyword}%`);
  }

  const [{ total }] = await query<{ total: number }>(countSql, countParams);

  // 处理标签为数组
  const hotspotsWithTags = hotspots.map((h: any) => ({
    ...h,
    tags: h.tags ? h.tags.split(',') : [],
  }));

  return {
    items: hotspotsWithTags,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
}

// ========== 热点详情 ==========
export async function getHotspotDetail(id: number) {
  const sql = `
    SELECT h.*
    FROM geopolitics_hotspots h
    WHERE h.id = ? AND h.status = 'published'
  `;

  const hotspot = await queryOne<Hotspot>(sql, [id]);

  if (!hotspot) {
    return null;
  }

  // 增加浏览量
  await execute('UPDATE geopolitics_hotspots SET view_count = view_count + 1 WHERE id = ?', [id]);

  // 获取标签
  const tags = await query(
    `SELECT t.* FROM geopolitics_tags t
     JOIN geopolitics_hotspot_tags ht ON t.id = ht.tag_id
     WHERE ht.hotspot_id = ?`,
    [id]
  );

  // 获取媒体
  const media = await query(
    'SELECT * FROM geopolitics_media WHERE hotspot_id = ? ORDER BY sort_order',
    [id]
  );

  return {
    ...hotspot,
    tags,
    media,
  };
}

// ========== 热点时间轴 ==========
export async function getHotspotsTimeline(filters: any) {
  const { startDate, endDate, category } = filters;

  let sql = `
    SELECT id, title, summary, publish_date, category, region, 
           latitude, longitude, cover_image
    FROM geopolitics_hotspots
    WHERE status = 'published'
  `;

  const params: any[] = [];

  if (category) {
    sql += ' AND category = ?';
    params.push(category);
  }

  if (startDate) {
    sql += ' AND publish_date >= ?';
    params.push(startDate);
  }

  if (endDate) {
    sql += ' AND publish_date <= ?';
    params.push(endDate);
  }

  sql += ' ORDER BY publish_date ASC';

  return await query(sql, params);
}

// ========== 地图点位数据 ==========
export async function getHotspotsMapData(filters: any) {
  const { bounds, category } = filters;

  let sql = `
    SELECT id, title, category, region, latitude, longitude, 
           cover_image, publish_date
    FROM geopolitics_hotspots
    WHERE status = 'published' 
      AND latitude IS NOT NULL 
      AND longitude IS NOT NULL
  `;

  const params: any[] = [];

  if (category) {
    sql += ' AND category = ?';
    params.push(category);
  }

  // TODO: 根据 bounds 过滤地理范围

  return await query(sql, params);
}

// ========== 标签 ==========
export async function getTags() {
  return await query('SELECT * FROM geopolitics_tags ORDER BY usage_count DESC');
}

export async function getHotspotsByTag(filters: any) {
  const { tagId, page, limit } = filters;
  const offset = (page - 1) * limit;

  const sql = `
    SELECT h.*
    FROM geopolitics_hotspots h
    JOIN geopolitics_hotspot_tags ht ON h.id = ht.hotspot_id
    WHERE ht.tag_id = ? AND h.status = 'published'
    ORDER BY h.publish_date DESC
    LIMIT ? OFFSET ?
  `;

  const hotspots = await query(sql, [tagId, limit, offset]);

  const countSql = `
    SELECT COUNT(*) as total
    FROM geopolitics_hotspots h
    JOIN geopolitics_hotspot_tags ht ON h.id = ht.hotspot_id
    WHERE ht.tag_id = ? AND h.status = 'published'
  `;

  const [{ total }] = await query<{ total: number }>(countSql, [tagId]);

  return {
    items: hotspots,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
}

// ========== 知识点关联 ==========
export async function getHotspotKnowledge(hotspotId: number) {
  const sql = `
    SELECT kn.*, gkl.relevance_score, gkl.analysis_content
    FROM knowledge_nodes kn
    JOIN geopolitics_knowledge_links gkl ON kn.id = gkl.knowledge_node_id
    WHERE gkl.hotspot_id = ?
    ORDER BY gkl.relevance_score DESC
  `;

  return await query(sql, [hotspotId]);
}

// ========== 思维训练 ==========
export async function getHotspotQuestions(hotspotId: number) {
  return await query(
    `SELECT id, question_text, question_type, difficulty, answer_framework
     FROM geopolitics_questions
     WHERE hotspot_id = ?
     ORDER BY id`,
    [hotspotId]
  );
}

export async function submitAnswer(data: any) {
  const { userId, questionId, answer } = data;

  // 插入答题记录
  const answerId = await insert(
    `INSERT INTO geopolitics_answer_records 
     (user_id, question_id, answer_content) 
     VALUES (?, ?, ?)`,
    [userId, questionId, answer]
  );

  // TODO: 调用 AI 批改接口，更新 ai_feedback 和 score

  return { answerId };
}

export async function getMyAnswers(data: any) {
  const { userId, page, limit } = data;
  const offset = (page - 1) * limit;

  const sql = `
    SELECT ar.*, q.question_text, q.question_type, h.title as hotspot_title
    FROM geopolitics_answer_records ar
    JOIN geopolitics_questions q ON ar.question_id = q.id
    JOIN geopolitics_hotspots h ON q.hotspot_id = h.id
    WHERE ar.user_id = ?
    ORDER BY ar.submit_time DESC
    LIMIT ? OFFSET ?
  `;

  const answers = await query(sql, [userId, limit, offset]);

  const [{ total }] = await query<{ total: number }>(
    'SELECT COUNT(*) as total FROM geopolitics_answer_records WHERE user_id = ?',
    [userId]
  );

  return {
    items: answers,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
}

export async function getAnswerFeedback(answerId: number, userId: number) {
  const sql = `
    SELECT ar.*, q.reference_answer, q.answer_framework, q.scoring_criteria
    FROM geopolitics_answer_records ar
    JOIN geopolitics_questions q ON ar.question_id = q.id
    WHERE ar.id = ? AND ar.user_id = ?
  `;

  return await queryOne(sql, [answerId, userId]);
}

// ========== 收藏 ==========
export async function addFavorite(data: any) {
  const { userId, hotspotId, notes } = data;

  return await insert(
    'INSERT INTO geopolitics_favorites (user_id, hotspot_id, notes) VALUES (?, ?, ?)',
    [userId, hotspotId, notes || '']
  );
}

export async function removeFavorite(userId: number, hotspotId: number) {
  return await execute(
    'DELETE FROM geopolitics_favorites WHERE user_id = ? AND hotspot_id = ?',
    [userId, hotspotId]
  );
}

export async function getMyFavorites(data: any) {
  const { userId, page, limit } = data;
  const offset = (page - 1) * limit;

  const sql = `
    SELECT h.*, f.notes, f.created_at as favorite_time
    FROM geopolitics_favorites f
    JOIN geopolitics_hotspots h ON f.hotspot_id = h.id
    WHERE f.user_id = ?
    ORDER BY f.created_at DESC
    LIMIT ? OFFSET ?
  `;

  const favorites = await query(sql, [userId, limit, offset]);

  const [{ total }] = await query<{ total: number }>(
    'SELECT COUNT(*) as total FROM geopolitics_favorites WHERE user_id = ?',
    [userId]
  );

  return {
    items: favorites,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
}

// ========== 评论 ==========
export async function addComment(data: any) {
  const { userId, hotspotId, content, parentId } = data;

  const commentId = await insert(
    `INSERT INTO geopolitics_comments 
     (hotspot_id, user_id, parent_id, content) 
     VALUES (?, ?, ?, ?)`,
    [hotspotId, userId, parentId || null, content]
  );

  return await queryOne(
    `SELECT c.*, u.username, u.avatar_url
     FROM geopolitics_comments c
     JOIN users u ON c.user_id = u.id
     WHERE c.id = ?`,
    [commentId]
  );
}

export async function getComments(data: any) {
  const { hotspotId, page, limit } = data;
  const offset = (page - 1) * limit;

  const sql = `
    SELECT c.*, u.username, u.avatar_url
    FROM geopolitics_comments c
    JOIN users u ON c.user_id = u.id
    WHERE c.hotspot_id = ? AND c.is_deleted = FALSE AND c.parent_id IS NULL
    ORDER BY c.is_pinned DESC, c.created_at DESC
    LIMIT ? OFFSET ?
  `;

  const comments = await query(sql, [hotspotId, limit, offset]);

  // 获取每条评论的回复
  for (const comment of comments) {
    const replies = await query(
      `SELECT c.*, u.username, u.avatar_url
       FROM geopolitics_comments c
       JOIN users u ON c.user_id = u.id
       WHERE c.parent_id = ? AND c.is_deleted = FALSE
       ORDER BY c.created_at ASC`,
      [(comment as any).id]
    );
    (comment as any).replies = replies;
  }

  const [{ total }] = await query<{ total: number }>(
    `SELECT COUNT(*) as total FROM geopolitics_comments 
     WHERE hotspot_id = ? AND is_deleted = FALSE AND parent_id IS NULL`,
    [hotspotId]
  );

  return {
    items: comments,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
}

// ========== 点赞 ==========
export async function likeHotspot(hotspotId: number) {
  return await execute(
    'UPDATE geopolitics_hotspots SET like_count = like_count + 1 WHERE id = ?',
    [hotspotId]
  );
}

// ========== 学习轨迹 ==========
export async function recordLearningPath(data: any) {
  const { userId, hotspotId, duration, scrollDepth, mediaViewed, knowledgeClicked } = data;

  const existing = await queryOne(
    'SELECT id FROM geopolitics_learning_path WHERE user_id = ? AND hotspot_id = ?',
    [userId, hotspotId]
  );

  if (existing) {
    // 更新已有记录
    return await execute(
      `UPDATE geopolitics_learning_path 
       SET view_duration = view_duration + ?, 
           scroll_depth = GREATEST(scroll_depth, ?),
           media_viewed = ?,
           knowledge_clicked = ?,
           completed = ?
       WHERE id = ?`,
      [
        duration,
        scrollDepth,
        JSON.stringify(mediaViewed),
        JSON.stringify(knowledgeClicked),
        scrollDepth >= 80 ? 1 : 0,
        (existing as any).id,
      ]
    );
  } else {
    // 创建新记录
    return await insert(
      `INSERT INTO geopolitics_learning_path 
       (user_id, hotspot_id, view_duration, scroll_depth, media_viewed, knowledge_clicked, completed)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        userId,
        hotspotId,
        duration,
        scrollDepth,
        JSON.stringify(mediaViewed),
        JSON.stringify(knowledgeClicked),
        scrollDepth >= 80 ? 1 : 0,
      ]
    );
  }
}

export async function getMyLearningProgress(userId: number) {
  const sql = `
    SELECT 
      COUNT(*) as total_viewed,
      SUM(completed) as completed_count,
      SUM(view_duration) as total_duration
    FROM geopolitics_learning_path
    WHERE user_id = ?
  `;

  const stats = await queryOne(sql, [userId]);

  // 获取最近学习的热点
  const recentHotspots = await query(
    `SELECT h.id, h.title, h.cover_image, lp.view_duration, lp.completed
     FROM geopolitics_learning_path lp
     JOIN geopolitics_hotspots h ON lp.hotspot_id = h.id
     WHERE lp.user_id = ?
     ORDER BY lp.updated_at DESC
     LIMIT 10`,
    [userId]
  );

  return {
    stats,
    recentHotspots,
  };
}
