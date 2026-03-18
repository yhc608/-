import { query, queryOne, insert, execute } from '../config/database';

// ========== 实验模板 ==========
export async function getTemplates(filters: any) {
  const { page, limit, category, difficulty, keyword } = filters;
  const offset = (page - 1) * limit;

  let sql = `
    SELECT * FROM cyber_lab_templates
    WHERE status = 'published'
  `;

  const params: any[] = [];

  if (category) {
    sql += ' AND (category = ? OR sub_category = ?)';
    params.push(category, category);
  }

  if (difficulty) {
    sql += ' AND difficulty = ?';
    params.push(difficulty);
  }

  if (keyword) {
    sql += ' AND (title LIKE ? OR description LIKE ?)';
    params.push(`%${keyword}%`, `%${keyword}%`);
  }

  sql += ' ORDER BY view_count DESC LIMIT ? OFFSET ?';
  params.push(limit, offset);

  const templates = await query(sql, params);

  // 获取总数
  let countSql = 'SELECT COUNT(*) as total FROM cyber_lab_templates WHERE status = "published"';
  const countParams: any[] = [];

  if (category) {
    countSql += ' AND (category = ? OR sub_category = ?)';
    countParams.push(category, category);
  }

  if (difficulty) {
    countSql += ' AND difficulty = ?';
    countParams.push(difficulty);
  }

  if (keyword) {
    countSql += ' AND (title LIKE ? OR description LIKE ?)';
    countParams.push(`%${keyword}%`, `%${keyword}%`);
  }

  const [{ total }] = await query<{ total: number }>(countSql, countParams);

  return {
    items: templates,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
}

export async function getTemplateDetail(id: number) {
  const template = await queryOne(
    'SELECT * FROM cyber_lab_templates WHERE id = ? AND status = "published"',
    [id]
  );

  if (!template) {
    return null;
  }

  // 增加浏览量
  await execute('UPDATE cyber_lab_templates SET view_count = view_count + 1 WHERE id = ?', [id]);

  return template;
}

export async function getTemplatesByCategory(filters: any) {
  const { category, page, limit } = filters;
  const offset = (page - 1) * limit;

  const sql = `
    SELECT * FROM cyber_lab_templates
    WHERE (category = ? OR sub_category = ?) AND status = 'published'
    ORDER BY complete_count DESC
    LIMIT ? OFFSET ?
  `;

  const templates = await query(sql, [category, category, limit, offset]);

  const [{ total }] = await query<{ total: number }>(
    `SELECT COUNT(*) as total FROM cyber_lab_templates 
     WHERE (category = ? OR sub_category = ?) AND status = 'published'`,
    [category, category]
  );

  return {
    items: templates,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
}

export async function getPopularTemplates(limit: number) {
  return await query(
    `SELECT * FROM cyber_lab_templates 
     WHERE status = 'published'
     ORDER BY view_count DESC, rating DESC
     LIMIT ?`,
    [limit]
  );
}

// ========== 实验执行 ==========
export async function startExperiment(userId: number, templateId: number) {
  const experimentId = await insert(
    `INSERT INTO cyber_lab_records (user_id, template_id, status) 
     VALUES (?, ?, 'ongoing')`,
    [userId, templateId]
  );

  return await queryOne(
    `SELECT r.*, t.title, t.description, t.scene_config, t.parameters, t.guide_steps
     FROM cyber_lab_records r
     JOIN cyber_lab_templates t ON r.template_id = t.id
     WHERE r.id = ?`,
    [experimentId]
  );
}

export async function saveExperimentData(data: any) {
  const { experimentId, userId, operationData, experimentResults, dataCharts } = data;

  // 验证权限
  const record = await queryOne(
    'SELECT id FROM cyber_lab_records WHERE id = ? AND user_id = ?',
    [experimentId, userId]
  );

  if (!record) {
    throw new Error('无权限操作此实验');
  }

  const now = new Date();
  const duration = await queryOne<{ start_time: Date }>(
    'SELECT start_time FROM cyber_lab_records WHERE id = ?',
    [experimentId]
  );

  const durationSeconds = duration
    ? Math.floor((now.getTime() - new Date(duration.start_time).getTime()) / 1000)
    : 0;

  return await execute(
    `UPDATE cyber_lab_records
     SET operation_data = ?,
         experiment_results = ?,
         data_charts = ?,
         duration = ?,
         updated_at = NOW()
     WHERE id = ?`,
    [
      JSON.stringify(operationData),
      JSON.stringify(experimentResults),
      JSON.stringify(dataCharts),
      durationSeconds,
      experimentId,
    ]
  );
}

export async function submitExperiment(data: any) {
  const { experimentId, userId, reportContent } = data;

  // 验证权限
  const record = await queryOne(
    'SELECT id, start_time FROM cyber_lab_records WHERE id = ? AND user_id = ?',
    [experimentId, userId]
  );

  if (!record) {
    throw new Error('无权限操作此实验');
  }

  // 计算完成度和分数（这里简化处理，实际应该根据实验要求计算）
  const completionRate = 100;
  const score = 85; // TODO: 根据实验数据评分

  const now = new Date();
  const durationSeconds = Math.floor(
    (now.getTime() - new Date((record as any).start_time).getTime()) / 1000
  );

  await execute(
    `UPDATE cyber_lab_records
     SET status = 'completed',
         end_time = NOW(),
         duration = ?,
         completion_rate = ?,
         report_content = ?,
         score = ?
     WHERE id = ?`,
    [durationSeconds, completionRate, reportContent, score, experimentId]
  );

  // 更新模板完成数
  await execute(
    `UPDATE cyber_lab_templates 
     SET complete_count = complete_count + 1
     WHERE id = (SELECT template_id FROM cyber_lab_records WHERE id = ?)`,
    [experimentId]
  );

  return {
    experimentId,
    score,
    completionRate,
  };
}

export async function getMyExperiments(data: any) {
  const { userId, page, limit, status } = data;
  const offset = (page - 1) * limit;

  let sql = `
    SELECT r.*, t.title, t.cover_image, t.difficulty
    FROM cyber_lab_records r
    JOIN cyber_lab_templates t ON r.template_id = t.id
    WHERE r.user_id = ?
  `;

  const params: any[] = [userId];

  if (status) {
    sql += ' AND r.status = ?';
    params.push(status);
  }

  sql += ' ORDER BY r.start_time DESC LIMIT ? OFFSET ?';
  params.push(limit, offset);

  const experiments = await query(sql, params);

  let countSql = 'SELECT COUNT(*) as total FROM cyber_lab_records WHERE user_id = ?';
  const countParams: any[] = [userId];

  if (status) {
    countSql += ' AND status = ?';
    countParams.push(status);
  }

  const [{ total }] = await query<{ total: number }>(countSql, countParams);

  return {
    items: experiments,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
}

export async function getExperimentDetail(experimentId: number, userId: number) {
  const sql = `
    SELECT r.*, t.*,
           r.id as record_id,
           t.id as template_id
    FROM cyber_lab_records r
    JOIN cyber_lab_templates t ON r.template_id = t.id
    WHERE r.id = ? AND r.user_id = ?
  `;

  return await queryOne(sql, [experimentId, userId]);
}

export async function deleteExperiment(experimentId: number, userId: number) {
  const affected = await execute(
    'DELETE FROM cyber_lab_records WHERE id = ? AND user_id = ?',
    [experimentId, userId]
  );

  if (affected === 0) {
    throw new Error('无权限删除此实验或实验不存在');
  }
}

// ========== 数据快照 ==========
export async function saveDataSnapshot(data: any) {
  const { experimentId, userId, timestamp, parameterValues, observationData } = data;

  // 验证权限
  const record = await queryOne(
    'SELECT id FROM cyber_lab_records WHERE id = ? AND user_id = ?',
    [experimentId, userId]
  );

  if (!record) {
    throw new Error('无权限操作此实验');
  }

  return await insert(
    `INSERT INTO cyber_lab_data_snapshots 
     (record_id, timestamp, parameter_values, observation_data)
     VALUES (?, ?, ?, ?)`,
    [
      experimentId,
      timestamp,
      JSON.stringify(parameterValues),
      JSON.stringify(observationData),
    ]
  );
}

export async function getDataSnapshots(experimentId: number, userId: number) {
  // 验证权限
  const record = await queryOne(
    'SELECT id FROM cyber_lab_records WHERE id = ? AND user_id = ?',
    [experimentId, userId]
  );

  if (!record) {
    throw new Error('无权限访问此实验');
  }

  return await query(
    `SELECT * FROM cyber_lab_data_snapshots
     WHERE record_id = ?
     ORDER BY timestamp ASC`,
    [experimentId]
  );
}

// ========== 实验评价 ==========
export async function addReview(data: any) {
  const {
    userId,
    templateId,
    rating,
    difficultyRating,
    clarityRating,
    usefulnessRating,
    reviewText,
    suggestions,
  } = data;

  await insert(
    `INSERT INTO cyber_lab_reviews 
     (user_id, template_id, rating, difficulty_rating, clarity_rating, 
      usefulness_rating, review_text, suggestions)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE
       rating = VALUES(rating),
       difficulty_rating = VALUES(difficulty_rating),
       clarity_rating = VALUES(clarity_rating),
       usefulness_rating = VALUES(usefulness_rating),
       review_text = VALUES(review_text),
       suggestions = VALUES(suggestions),
       created_at = NOW()`,
    [
      userId,
      templateId,
      rating,
      difficultyRating,
      clarityRating,
      usefulnessRating,
      reviewText,
      suggestions,
    ]
  );

  // 更新模板平均评分
  await execute(
    `UPDATE cyber_lab_templates
     SET rating = (
       SELECT AVG(rating) FROM cyber_lab_reviews WHERE template_id = ?
     )
     WHERE id = ?`,
    [templateId, templateId]
  );
}

export async function getReviews(data: any) {
  const { templateId, page, limit } = data;
  const offset = (page - 1) * limit;

  const sql = `
    SELECT r.*, u.username, u.avatar_url
    FROM cyber_lab_reviews r
    JOIN users u ON r.user_id = u.id
    WHERE r.template_id = ? AND r.is_anonymous = FALSE
    ORDER BY r.created_at DESC
    LIMIT ? OFFSET ?
  `;

  const reviews = await query(sql, [templateId, limit, offset]);

  const [{ total }] = await query<{ total: number }>(
    'SELECT COUNT(*) as total FROM cyber_lab_reviews WHERE template_id = ?',
    [templateId]
  );

  return {
    items: reviews,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
}

// ========== 协作实验 ==========
export async function createCollaboration(data: any) {
  const { userId, templateId, maxParticipants } = data;

  // 先创建实验记录
  const recordId = await insert(
    'INSERT INTO cyber_lab_records (user_id, template_id, status) VALUES (?, ?, "ongoing")',
    [userId, templateId]
  );

  // 生成房间代码
  const roomCode = generateRoomCode();

  await insert(
    `INSERT INTO cyber_lab_collaborations 
     (record_id, room_code, host_user_id, max_participants, participants, status)
     VALUES (?, ?, ?, ?, ?, 'waiting')`,
    [recordId, roomCode, userId, maxParticipants, JSON.stringify([userId])]
  );

  return {
    roomCode,
    recordId,
    maxParticipants,
  };
}

export async function joinCollaboration(roomCode: string, userId: number) {
  const collaboration = await queryOne(
    `SELECT * FROM cyber_lab_collaborations WHERE room_code = ?`,
    [roomCode]
  );

  if (!collaboration) {
    throw new Error('房间不存在');
  }

  const participants = JSON.parse((collaboration as any).participants || '[]');

  if (participants.includes(userId)) {
    return collaboration; // 已在房间中
  }

  if (participants.length >= (collaboration as any).max_participants) {
    throw new Error('房间已满');
  }

  participants.push(userId);

  await execute(
    'UPDATE cyber_lab_collaborations SET participants = ? WHERE room_code = ?',
    [JSON.stringify(participants), roomCode]
  );

  return await queryOne(
    'SELECT * FROM cyber_lab_collaborations WHERE room_code = ?',
    [roomCode]
  );
}

export async function getCollaborationInfo(roomCode: string) {
  return await queryOne(
    `SELECT c.*, r.template_id, t.title
     FROM cyber_lab_collaborations c
     JOIN cyber_lab_records r ON c.record_id = r.id
     JOIN cyber_lab_templates t ON r.template_id = t.id
     WHERE c.room_code = ?`,
    [roomCode]
  );
}

export async function syncCollaborationData(roomCode: string, userId: number, syncData: any) {
  await execute(
    'UPDATE cyber_lab_collaborations SET sync_data = ? WHERE room_code = ?',
    [JSON.stringify(syncData), roomCode]
  );
}

// 生成房间代码
function generateRoomCode(): string {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

// ========== 实验步骤 ==========
export async function getExperimentSteps(templateId: number) {
  return await query(
    `SELECT * FROM cyber_lab_steps 
     WHERE template_id = ? 
     ORDER BY step_number`,
    [templateId]
  );
}

// ========== 资源管理 ==========
export async function getExperimentResources(templateId: number) {
  return await query(
    `SELECT * FROM cyber_lab_resources 
     WHERE template_id = ? AND is_public = TRUE
     ORDER BY resource_type, name`,
    [templateId]
  );
}
