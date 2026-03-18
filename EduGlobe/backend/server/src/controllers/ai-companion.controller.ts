import { Response } from 'express';
import { asyncHandler, AppError } from '../middleware/error.middleware';
import { query, insert } from '../config/database';

// AI对话
export const startChatSession = asyncHandler(async (req: any, res: Response) => {
  const userId = req.userId;
  const { sessionType = 'qa' } = req.body;
  
  const sessionId = await insert(
    'INSERT INTO ai_study_sessions (user_id, session_type) VALUES (?, ?)',
    [userId, sessionType]
  );
  
  res.json({ success: true, data: { sessionId } });
});

export const sendMessage = asyncHandler(async (req: any, res: Response) => {
  const { sessionId } = req.params;
  const { content, contentType = 'text' } = req.body;
  
  // 保存用户消息
  await insert(
    `INSERT INTO ai_chat_messages (session_id, sender, content_type, content) 
     VALUES (?, 'user', ?, ?)`,
    [sessionId, contentType, content]
  );
  
  // TODO: 调用AI模型生成回复
  const aiResponse = `这是AI的回复：${content}`;
  
  await insert(
    `INSERT INTO ai_chat_messages (session_id, sender, content_type, content) 
     VALUES (?, 'ai', 'text', ?)`,
    [sessionId, aiResponse]
  );
  
  res.json({ success: true, data: { response: aiResponse } });
});

export const getMyChatSessions = asyncHandler(async (req: any, res: Response) => {
  const sessions = await query(
    'SELECT * FROM ai_study_sessions WHERE user_id = ? ORDER BY start_time DESC LIMIT 20',
    [req.userId]
  );
  res.json({ success: true, data: sessions });
});

export const getMessages = asyncHandler(async (req: any, res: Response) => {
  const { sessionId } = req.params;
  const messages = await query(
    'SELECT * FROM ai_chat_messages WHERE session_id = ? ORDER BY timestamp ASC',
    [sessionId]
  );
  res.json({ success: true, data: messages });
});

// 学习计划
export const createStudyPlan = asyncHandler(async (req: any, res: Response) => {
  const { planName, planType, startDate, endDate, targetGoal } = req.body;
  
  const planId = await insert(
    `INSERT INTO ai_study_plans 
     (user_id, plan_name, plan_type, start_date, end_date, target_goal) 
     VALUES (?, ?, ?, ?, ?, ?)`,
    [req.userId, planName, planType, startDate, endDate, targetGoal]
  );
  
  res.json({ success: true, data: { planId }, message: '学习计划已创建' });
});

export const getMyStudyPlans = asyncHandler(async (req: any, res: Response) => {
  const plans = await query(
    'SELECT * FROM ai_study_plans WHERE user_id = ? ORDER BY created_at DESC',
    [req.userId]
  );
  res.json({ success: true, data: plans });
});

export const getStudyPlanDetail = asyncHandler(async (req: any, res: Response) => {
  const { id } = req.params;
  const [plan] = await query(
    'SELECT * FROM ai_study_plans WHERE id = ? AND user_id = ?',
    [id, req.userId]
  );
  if (!plan) throw new AppError('学习计划不存在', 404);
  res.json({ success: true, data: plan });
});

export const updateStudyPlan = asyncHandler(async (req: any, res: Response) => {
  const { id } = req.params;
  const { planName, targetGoal, status } = req.body;
  
  await query(
    `UPDATE ai_study_plans SET 
     plan_name = COALESCE(?, plan_name),
     target_goal = COALESCE(?, target_goal),
     status = COALESCE(?, status)
     WHERE id = ? AND user_id = ?`,
    [planName, targetGoal, status, id, req.userId]
  );
  
  res.json({ success: true, message: '计划已更新' });
});

// 每日任务
export const getDailyTasks = asyncHandler(async (req: any, res: Response) => {
  const today = new Date().toISOString().split('T')[0];
  const tasks = await query(
    'SELECT * FROM ai_daily_tasks WHERE user_id = ? AND task_date = ? ORDER BY id',
    [req.userId, today]
  );
  res.json({ success: true, data: tasks });
});

export const completeDailyTask = asyncHandler(async (req: any, res: Response) => {
  const { id } = req.params;
  await query(
    `UPDATE ai_daily_tasks SET status = 'completed', completed_at = NOW() 
     WHERE id = ? AND user_id = ?`,
    [id, req.userId]
  );
  res.json({ success: true, message: '任务已完成' });
});

// 学习分析
export const getMyAnalytics = asyncHandler(async (req: any, res: Response) => {
  const analytics = await query(
    'SELECT * FROM ai_study_analytics WHERE user_id = ? ORDER BY date DESC LIMIT 30',
    [req.userId]
  );
  res.json({ success: true, data: analytics });
});

export const getWeeklyReport = asyncHandler(async (req: any, res: Response) => {
  const reports = await query(
    'SELECT * FROM ai_weekly_reports WHERE user_id = ? ORDER BY week_start_date DESC LIMIT 5',
    [req.userId]
  );
  res.json({ success: true, data: reports });
});

export const getKnowledgeMastery = asyncHandler(async (req: any, res: Response) => {
  const mastery = await query(
    `SELECT k.*, n.name as knowledge_name FROM ai_knowledge_mastery k 
     JOIN knowledge_nodes n ON k.knowledge_node_id = n.id 
     WHERE k.user_id = ? ORDER BY k.mastery_score ASC LIMIT 50`,
    [req.userId]
  );
  res.json({ success: true, data: mastery });
});

// 错题本
export const addErrorQuestion = asyncHandler(async (req: any, res: Response) => {
  const { questionId, questionContent, studentAnswer, correctAnswer, errorType } = req.body;
  
  await insert(
    `INSERT INTO ai_error_notebook 
     (user_id, question_id, question_content, student_answer, correct_answer, error_type) 
     VALUES (?, ?, ?, ?, ?, ?)`,
    [req.userId, questionId, questionContent, studentAnswer, correctAnswer, errorType]
  );
  
  res.json({ success: true, message: '已加入错题本' });
});

export const getMyErrors = asyncHandler(async (req: any, res: Response) => {
  const errors = await query(
    'SELECT * FROM ai_error_notebook WHERE user_id = ? AND mastered = FALSE ORDER BY created_at DESC',
    [req.userId]
  );
  res.json({ success: true, data: errors });
});

export const markAsMastered = asyncHandler(async (req: any, res: Response) => {
  const { id } = req.params;
  await query(
    'UPDATE ai_error_notebook SET mastered = TRUE WHERE id = ? AND user_id = ?',
    [id, req.userId]
  );
  res.json({ success: true, message: '已标记为掌握' });
});

// 学习建议
export const getMySuggestions = asyncHandler(async (req: any, res: Response) => {
  const suggestions = await query(
    'SELECT * FROM ai_study_suggestions WHERE user_id = ? AND is_read = FALSE ORDER BY priority DESC, created_at DESC',
    [req.userId]
  );
  res.json({ success: true, data: suggestions });
});

export const adoptSuggestion = asyncHandler(async (req: any, res: Response) => {
  const { id } = req.params;
  await query(
    'UPDATE ai_study_suggestions SET is_adopted = TRUE WHERE id = ? AND user_id = ?',
    [id, req.userId]
  );
  res.json({ success: true, message: '已采纳建议' });
});

// OCR识别
export const recognizeImage = asyncHandler(async (req: any, res: Response) => {
  const { imageUrl, ocrType } = req.body;
  
  // TODO: 调用OCR服务
  const mockResult = { text: '识别的文本内容', confidence: 0.95 };
  
  await insert(
    'INSERT INTO ai_ocr_records (user_id, image_url, ocr_type, raw_text, confidence) VALUES (?, ?, ?, ?, ?)',
    [req.userId, imageUrl, ocrType, mockResult.text, mockResult.confidence]
  );
  
  res.json({ success: true, data: mockResult });
});

// 智能推荐
export const getQuestionRecommendations = asyncHandler(async (req: any, res: Response) => {
  const recommendations = await query(
    'SELECT * FROM ai_question_recommendations WHERE user_id = ? AND is_completed = FALSE ORDER BY recommendation_score DESC LIMIT 10',
    [req.userId]
  );
  res.json({ success: true, data: recommendations });
});

export const getResourceRecommendations = asyncHandler(async (req: any, res: Response) => {
  const recommendations = await query(
    'SELECT * FROM ai_resource_recommendations WHERE user_id = ? AND is_viewed = FALSE ORDER BY priority DESC LIMIT 10',
    [req.userId]
  );
  res.json({ success: true, data: recommendations });
});

// 提醒
export const getMyReminders = asyncHandler(async (req: any, res: Response) => {
  const reminders = await query(
    'SELECT * FROM ai_study_reminders WHERE user_id = ? AND is_sent = TRUE AND is_read = FALSE ORDER BY remind_time DESC',
    [req.userId]
  );
  res.json({ success: true, data: reminders });
});

export const markReminderAsRead = asyncHandler(async (req: any, res: Response) => {
  const { id } = req.params;
  await query(
    'UPDATE ai_study_reminders SET is_read = TRUE WHERE id = ? AND user_id = ?',
    [id, req.userId]
  );
  res.json({ success: true, message: '已读' });
});

// 成就
export const getMyAchievements = asyncHandler(async (req: any, res: Response) => {
  const achievements = await query(
    `SELECT a.*, ua.unlock_time FROM ai_user_achievements ua 
     JOIN ai_achievements a ON ua.achievement_id = a.id 
     WHERE ua.user_id = ? ORDER BY ua.unlock_time DESC`,
    [req.userId]
  );
  res.json({ success: true, data: achievements });
});

export const getAllAchievements = asyncHandler(async (req: any, res: Response) => {
  const achievements = await query('SELECT * FROM ai_achievements ORDER BY rarity, category');
  res.json({ success: true, data: achievements });
});
