import { Request, Response, NextFunction } from 'express';
import { asyncHandler, AppError } from '../middleware/error.middleware';
import { AuthRequest } from '../middleware/auth.middleware';
import * as geopoliticsService from '../services/geopolitics.service';

// 获取热点列表
export const getHotspots = asyncHandler(
  async (req: Request, res: Response) => {
    const {
      page = 1,
      limit = 20,
      category,
      region,
      startDate,
      endDate,
      keyword,
    } = req.query;

    const result = await geopoliticsService.getHotspots({
      page: Number(page),
      limit: Number(limit),
      category: category as string,
      region: region as string,
      startDate: startDate as string,
      endDate: endDate as string,
      keyword: keyword as string,
    });

    res.json({
      success: true,
      data: result,
    });
  }
);

// 获取热点详情
export const getHotspotDetail = asyncHandler(
  async (req: Request, res: Response) => {
    const { id } = req.params;
    const hotspot = await geopoliticsService.getHotspotDetail(Number(id));

    if (!hotspot) {
      throw new AppError('热点不存在', 404);
    }

    res.json({
      success: true,
      data: hotspot,
    });
  }
);

// 获取热点时间轴
export const getHotspotsTimeline = asyncHandler(
  async (req: Request, res: Response) => {
    const { startDate, endDate, category } = req.query;

    const timeline = await geopoliticsService.getHotspotsTimeline({
      startDate: startDate as string,
      endDate: endDate as string,
      category: category as string,
    });

    res.json({
      success: true,
      data: timeline,
    });
  }
);

// 获取地图点位数据
export const getHotspotsMapData = asyncHandler(
  async (req: Request, res: Response) => {
    const { bounds, category } = req.query;

    const mapData = await geopoliticsService.getHotspotsMapData({
      bounds: bounds as string,
      category: category as string,
    });

    res.json({
      success: true,
      data: mapData,
    });
  }
);

// 获取标签
export const getTags = asyncHandler(async (req: Request, res: Response) => {
  const tags = await geopoliticsService.getTags();

  res.json({
    success: true,
    data: tags,
  });
});

// 按标签筛选热点
export const getHotspotsByTag = asyncHandler(
  async (req: Request, res: Response) => {
    const { tagId } = req.params;
    const { page = 1, limit = 20 } = req.query;

    const result = await geopoliticsService.getHotspotsByTag({
      tagId: Number(tagId),
      page: Number(page),
      limit: Number(limit),
    });

    res.json({
      success: true,
      data: result,
    });
  }
);

// 获取热点关联知识点
export const getHotspotKnowledge = asyncHandler(
  async (req: Request, res: Response) => {
    const { id } = req.params;

    const knowledge = await geopoliticsService.getHotspotKnowledge(Number(id));

    res.json({
      success: true,
      data: knowledge,
    });
  }
);

// 获取热点相关问题
export const getHotspotQuestions = asyncHandler(
  async (req: Request, res: Response) => {
    const { id } = req.params;

    const questions = await geopoliticsService.getHotspotQuestions(Number(id));

    res.json({
      success: true,
      data: questions,
    });
  }
);

// 提交答案
export const submitAnswer = asyncHandler(
  async (req: AuthRequest, res: Response) => {
    const { id: questionId } = req.params;
    const { answer } = req.body;
    const userId = req.userId!;

    if (!answer) {
      throw new AppError('请提供答案内容', 400);
    }

    const result = await geopoliticsService.submitAnswer({
      userId,
      questionId: Number(questionId),
      answer,
    });

    res.json({
      success: true,
      message: 'AI批改中...',
      data: result,
    });
  }
);

// 获取我的答题记录
export const getMyAnswers = asyncHandler(
  async (req: AuthRequest, res: Response) => {
    const userId = req.userId!;
    const { page = 1, limit = 20 } = req.query;

    const result = await geopoliticsService.getMyAnswers({
      userId,
      page: Number(page),
      limit: Number(limit),
    });

    res.json({
      success: true,
      data: result,
    });
  }
);

// 获取答题反馈
export const getAnswerFeedback = asyncHandler(
  async (req: AuthRequest, res: Response) => {
    const { id } = req.params;
    const userId = req.userId!;

    const feedback = await geopoliticsService.getAnswerFeedback(
      Number(id),
      userId
    );

    if (!feedback) {
      throw new AppError('答题记录不存在', 404);
    }

    res.json({
      success: true,
      data: feedback,
    });
  }
);

// 添加收藏
export const addFavorite = asyncHandler(
  async (req: AuthRequest, res: Response) => {
    const { id } = req.params;
    const { notes } = req.body;
    const userId = req.userId!;

    await geopoliticsService.addFavorite({
      userId,
      hotspotId: Number(id),
      notes,
    });

    res.json({
      success: true,
      message: '收藏成功',
    });
  }
);

// 取消收藏
export const removeFavorite = asyncHandler(
  async (req: AuthRequest, res: Response) => {
    const { id } = req.params;
    const userId = req.userId!;

    await geopoliticsService.removeFavorite(userId, Number(id));

    res.json({
      success: true,
      message: '已取消收藏',
    });
  }
);

// 获取我的收藏
export const getMyFavorites = asyncHandler(
  async (req: AuthRequest, res: Response) => {
    const userId = req.userId!;
    const { page = 1, limit = 20 } = req.query;

    const result = await geopoliticsService.getMyFavorites({
      userId,
      page: Number(page),
      limit: Number(limit),
    });

    res.json({
      success: true,
      data: result,
    });
  }
);

// 添加评论
export const addComment = asyncHandler(
  async (req: AuthRequest, res: Response) => {
    const { id } = req.params;
    const { content, parentId } = req.body;
    const userId = req.userId!;

    if (!content || content.trim().length === 0) {
      throw new AppError('评论内容不能为空', 400);
    }

    const comment = await geopoliticsService.addComment({
      userId,
      hotspotId: Number(id),
      content,
      parentId,
    });

    res.json({
      success: true,
      message: '评论成功',
      data: comment,
    });
  }
);

// 获取评论列表
export const getComments = asyncHandler(
  async (req: Request, res: Response) => {
    const { id } = req.params;
    const { page = 1, limit = 20 } = req.query;

    const result = await geopoliticsService.getComments({
      hotspotId: Number(id),
      page: Number(page),
      limit: Number(limit),
    });

    res.json({
      success: true,
      data: result,
    });
  }
);

// 点赞热点
export const likeHotspot = asyncHandler(
  async (req: AuthRequest, res: Response) => {
    const { id } = req.params;

    await geopoliticsService.likeHotspot(Number(id));

    res.json({
      success: true,
      message: '点赞成功',
    });
  }
);

// 记录学习轨迹
export const recordLearningPath = asyncHandler(
  async (req: AuthRequest, res: Response) => {
    const { id } = req.params;
    const { duration, scrollDepth, mediaViewed, knowledgeClicked } = req.body;
    const userId = req.userId!;

    await geopoliticsService.recordLearningPath({
      userId,
      hotspotId: Number(id),
      duration,
      scrollDepth,
      mediaViewed,
      knowledgeClicked,
    });

    res.json({
      success: true,
      message: '学习轨迹已记录',
    });
  }
);

// 获取我的学习进度
export const getMyLearningProgress = asyncHandler(
  async (req: AuthRequest, res: Response) => {
    const userId = req.userId!;

    const progress = await geopoliticsService.getMyLearningProgress(userId);

    res.json({
      success: true,
      data: progress,
    });
  }
);
