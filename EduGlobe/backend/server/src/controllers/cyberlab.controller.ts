import { Request, Response } from 'express';
import { asyncHandler, AppError } from '../middleware/error.middleware';
import { AuthRequest } from '../middleware/auth.middleware';
import * as cyberLabService from '../services/cyberlab.service';

// ========== 实验模板 ==========
export const getTemplates = asyncHandler(async (req: Request, res: Response) => {
  const { page = 1, limit = 20, category, difficulty, keyword } = req.query;

  const result = await cyberLabService.getTemplates({
    page: Number(page),
    limit: Number(limit),
    category: category as string,
    difficulty: difficulty as string,
    keyword: keyword as string,
  });

  res.json({
    success: true,
    data: result,
  });
});

export const getTemplateDetail = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;

  const template = await cyberLabService.getTemplateDetail(Number(id));

  if (!template) {
    throw new AppError('实验不存在', 404);
  }

  res.json({
    success: true,
    data: template,
  });
});

export const getTemplatesByCategory = asyncHandler(async (req: Request, res: Response) => {
  const { category } = req.params;
  const { page = 1, limit = 20 } = req.query;

  const result = await cyberLabService.getTemplatesByCategory({
    category,
    page: Number(page),
    limit: Number(limit),
  });

  res.json({
    success: true,
    data: result,
  });
});

export const getPopularTemplates = asyncHandler(async (req: Request, res: Response) => {
  const { limit = 10 } = req.query;

  const templates = await cyberLabService.getPopularTemplates(Number(limit));

  res.json({
    success: true,
    data: templates,
  });
});

// ========== 实验执行 ==========
export const startExperiment = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { templateId } = req.body;
  const userId = req.userId!;

  if (!templateId) {
    throw new AppError('请提供实验模板ID', 400);
  }

  const experiment = await cyberLabService.startExperiment(userId, templateId);

  res.json({
    success: true,
    message: '实验已开始',
    data: experiment,
  });
});

export const saveExperimentData = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const { operationData, experimentResults, dataCharts } = req.body;
  const userId = req.userId!;

  await cyberLabService.saveExperimentData({
    experimentId: Number(id),
    userId,
    operationData,
    experimentResults,
    dataCharts,
  });

  res.json({
    success: true,
    message: '数据已保存',
  });
});

export const submitExperiment = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const { reportContent } = req.body;
  const userId = req.userId!;

  const result = await cyberLabService.submitExperiment({
    experimentId: Number(id),
    userId,
    reportContent,
  });

  res.json({
    success: true,
    message: '实验已提交',
    data: result,
  });
});

export const getMyExperiments = asyncHandler(async (req: AuthRequest, res: Response) => {
  const userId = req.userId!;
  const { page = 1, limit = 20, status } = req.query;

  const result = await cyberLabService.getMyExperiments({
    userId,
    page: Number(page),
    limit: Number(limit),
    status: status as string,
  });

  res.json({
    success: true,
    data: result,
  });
});

export const getExperimentDetail = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const userId = req.userId!;

  const experiment = await cyberLabService.getExperimentDetail(Number(id), userId);

  if (!experiment) {
    throw new AppError('实验记录不存在', 404);
  }

  res.json({
    success: true,
    data: experiment,
  });
});

export const deleteExperiment = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const userId = req.userId!;

  await cyberLabService.deleteExperiment(Number(id), userId);

  res.json({
    success: true,
    message: '实验记录已删除',
  });
});

// ========== 数据快照 ==========
export const saveDataSnapshot = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const { timestamp, parameterValues, observationData } = req.body;
  const userId = req.userId!;

  await cyberLabService.saveDataSnapshot({
    experimentId: Number(id),
    userId,
    timestamp,
    parameterValues,
    observationData,
  });

  res.json({
    success: true,
    message: '快照已保存',
  });
});

export const getDataSnapshots = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const userId = req.userId!;

  const snapshots = await cyberLabService.getDataSnapshots(Number(id), userId);

  res.json({
    success: true,
    data: snapshots,
  });
});

// ========== 实验评价 ==========
export const addReview = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const { rating, difficultyRating, clarityRating, usefulnessRating, reviewText, suggestions } = req.body;
  const userId = req.userId!;

  if (!rating || rating < 1 || rating > 5) {
    throw new AppError('请提供有效的评分(1-5)', 400);
  }

  await cyberLabService.addReview({
    userId,
    templateId: Number(id),
    rating,
    difficultyRating,
    clarityRating,
    usefulnessRating,
    reviewText,
    suggestions,
  });

  res.json({
    success: true,
    message: '评价已提交',
  });
});

export const getReviews = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const { page = 1, limit = 20 } = req.query;

  const result = await cyberLabService.getReviews({
    templateId: Number(id),
    page: Number(page),
    limit: Number(limit),
  });

  res.json({
    success: true,
    data: result,
  });
});

// ========== 协作实验 ==========
export const createCollaboration = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { templateId, maxParticipants = 4 } = req.body;
  const userId = req.userId!;

  if (!templateId) {
    throw new AppError('请提供实验模板ID', 400);
  }

  const collaboration = await cyberLabService.createCollaboration({
    userId,
    templateId,
    maxParticipants,
  });

  res.json({
    success: true,
    message: '协作房间已创建',
    data: collaboration,
  });
});

export const joinCollaboration = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { roomCode } = req.params;
  const userId = req.userId!;

  const collaboration = await cyberLabService.joinCollaboration(roomCode, userId);

  res.json({
    success: true,
    message: '已加入协作房间',
    data: collaboration,
  });
});

export const getCollaborationInfo = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { roomCode } = req.params;

  const collaboration = await cyberLabService.getCollaborationInfo(roomCode);

  if (!collaboration) {
    throw new AppError('协作房间不存在', 404);
  }

  res.json({
    success: true,
    data: collaboration,
  });
});

export const syncCollaborationData = asyncHandler(async (req: AuthRequest, res: Response) => {
  const { roomCode } = req.params;
  const { syncData } = req.body;
  const userId = req.userId!;

  await cyberLabService.syncCollaborationData(roomCode, userId, syncData);

  res.json({
    success: true,
    message: '数据已同步',
  });
});

// ========== 实验步骤 ==========
export const getExperimentSteps = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;

  const steps = await cyberLabService.getExperimentSteps(Number(id));

  res.json({
    success: true,
    data: steps,
  });
});

// ========== 资源管理 ==========
export const getExperimentResources = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;

  const resources = await cyberLabService.getExperimentResources(Number(id));

  res.json({
    success: true,
    data: resources,
  });
});
