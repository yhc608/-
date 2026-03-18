import axios from 'axios';

// ==================== API配置 ====================
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 请求拦截器 - 添加token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// 响应拦截器 - 统一错误处理
api.interceptors.response.use(
  (response) => response.data,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error.response?.data || error);
  }
);

// ==================== 认证相关 ====================
export const authApi = {
  register: (data: any) => api.post('/auth/register', data),
  login: (data: any) => api.post('/auth/login', data),
};

// ==================== 用户相关 ====================
export const userApi = {
  getMe: () => api.get('/users/me'),
  updateMe: (data: any) => api.put('/users/me', data),
  getStats: () => api.get('/users/me/stats'),
};

// ==================== 经纬瞰政 ====================
export const geopoliticsApi = {
  // 热点
  getHotspots: (params?: any) => api.get('/geopolitics/hotspots', { params }),
  getHotspotDetail: (id: number) => api.get(`/geopolitics/hotspots/${id}`),
  getHotspotsTimeline: (params?: any) => api.get('/geopolitics/hotspots/timeline', { params }),
  getHotspotsMapData: (params?: any) => api.get('/geopolitics/hotspots/map-data', { params }),
  
  // 标签
  getTags: () => api.get('/geopolitics/tags'),
  getHotspotsByTag: (tagId: number, params?: any) => api.get(`/geopolitics/tags/${tagId}/hotspots`, { params }),
  
  // 知识点
  getHotspotKnowledge: (id: number) => api.get(`/geopolitics/hotspots/${id}/knowledge`),
  
  // 问题与答题
  getHotspotQuestions: (id: number) => api.get(`/geopolitics/hotspots/${id}/questions`),
  submitAnswer: (questionId: number, answer: string) => 
    api.post(`/geopolitics/questions/${questionId}/answer`, { answer }),
  getMyAnswers: (params?: any) => api.get('/geopolitics/my-answers', { params }),
  getAnswerFeedback: (answerId: number) => api.get(`/geopolitics/answers/${answerId}/feedback`),
  
  // 互动
  addFavorite: (id: number, notes?: string) => 
    api.post(`/geopolitics/hotspots/${id}/favorite`, { notes }),
  removeFavorite: (id: number) => api.delete(`/geopolitics/hotspots/${id}/favorite`),
  getMyFavorites: (params?: any) => api.get('/geopolitics/my-favorites', { params }),
  
  addComment: (id: number, content: string, parentId?: number) => 
    api.post(`/geopolitics/hotspots/${id}/comments`, { content, parentId }),
  getComments: (id: number, params?: any) => api.get(`/geopolitics/hotspots/${id}/comments`, { params }),
  likeHotspot: (id: number) => api.post(`/geopolitics/hotspots/${id}/like`),
  
  // 学习轨迹
  recordLearningPath: (id: number, data: any) => 
    api.post(`/geopolitics/hotspots/${id}/learning-path`, data),
  getMyLearningProgress: () => api.get('/geopolitics/my-learning-progress'),
};

// ==================== 赛博实验 ====================
export const cyberLabApi = {
  // 实验模板
  getTemplates: (params?: any) => api.get('/cyberlab/templates', { params }),
  getTemplateDetail: (id: number) => api.get(`/cyberlab/temples/${id}`),
  getTemplatesByCategory: (category: string, params?: any) => 
    api.get(`/cyberlab/categories/${category}/templates`, { params }),
  getPopularTemplates: (limit = 10) => api.get('/cyberlab/templates/popular', { params: { limit } }),
  
  // 实验执行
  startExperiment: (templateId: number) => api.post('/cyberlab/experiments/start', { templateId }),
  saveExperimentData: (id: number, data: any) => api.put(`/cyberlab/experiments/${id}/save`, data),
  submitExperiment: (id: number, reportContent: string) => 
    api.post(`/cyberlab/experiments/${id}/submit`, { reportContent }),
  getMyExperiments: (params?: any) => api.get('/cyberlab/my-experiments', { params }),
  getExperimentDetail: (id: number) => api.get(`/cyberlab/experiments/${id}`),
  deleteExperiment: (id: number) => api.delete(`/cyberlab/experiments/${id}`),
  
  // 数据快照
  saveDataSnapshot: (id: number, data: any) => api.post(`/cyberlab/experiments/${id}/snapshots`, data),
  getDataSnapshots: (id: number) => api.get(`/cyberlab/experiments/${id}/snapshots`),
  
  // 评价
  addReview: (id: number, data: any) => api.post(`/cyberlab/templates/${id}/review`, data),
  getReviews: (id: number, params?: any) => api.get(`/cyberlab/templates/${id}/reviews`, { params }),
  
  // 协作
  createCollaboration: (templateId: number, maxParticipants = 4) => 
    api.post('/cyberlab/collaborations/create', { templateId, maxParticipants }),
  joinCollaboration: (roomCode: string) => api.post(`/cyberlab/collaborations/${roomCode}/join`),
  getCollaborationInfo: (roomCode: string) => api.get(`/cyberlab/collaborations/${roomCode}`),
  syncCollaborationData: (roomCode: string, syncData: any) => 
    api.post(`/cyberlab/collaborations/${roomCode}/sync`, { syncData }),
  
  // 步骤与资源
  getExperimentSteps: (id: number) => api.get(`/cyberlab/templates/${id}/steps`),
  getExperimentResources: (id: number) => api.get(`/cyberlab/templates/${id}/resources`),
};

// ==================== 情景互动 ====================
export const scenarioApi = {
  // 角色
  getRoles: () => api.get('/scenario/roles'),
  getRoleDetail: (id: number) => api.get(`/scenario/roles/${id}`),
  
  // 场景
  getScenes: () => api.get('/scenario/scenes'),
  getSceneDetail: (id: number) => api.get(`/scenario/scenes/${id}`),
  
  // 任务
  getTasks: () => api.get('/scenario/tasks'),
  getTaskDetail: (id: number) => api.get(`/scenario/tasks/${id}`),
  getTasksByScene: (sceneId: number) => api.get(`/scenario/scenes/${sceneId}/tasks`),
  
  // 进度
  startTask: (id: number) => api.post(`/scenario/tasks/${id}/start`),
  updateProgress: (id: number, data: any) => api.put(`/scenario/progress/${id}/update`, data),
  completeTask: (id: number) => api.post(`/scenario/progress/${id}/complete`),
  getMyProgress: () => api.get('/scenario/my-progress'),
  
  // 探索
  addDiscovery: (data: any) => api.post('/scenario/discoveries', data),
  getMyDiscoveries: () => api.get('/scenario/my-discoveries'),
  
  // NPC
  getSceneNPCs: (sceneId: number) => api.get(`/scenario/scenes/${sceneId}/npcs`),
  interactWithNPC: (id: number, data: any) => api.post(`/scenario/npcs/${id}/interact`, data),
  
  // 装备
  getEquipment: () => api.get('/scenario/equipment'),
  getMyInventory: () => api.get('/scenario/my-inventory'),
  acquireEquipment: (id: number, roleId: number) => 
    api.post(`/scenario/equipment/${id}/acquire`, { roleId }),
};

// ==================== AI地理伴学 ====================
export const aiCompanionApi = {
  // 对话
  startChatSession: (sessionType = 'qa') => api.post('/ai-companion/chat/start', { sessionType }),
  sendMessage: (sessionId: number, content: string, contentType = 'text') => 
    api.post(`/ai-companion/chat/${sessionId}/message`, { content, contentType }),
  getMyChatSessions: () => api.get('/ai-companion/chat/sessions'),
  getMessages: (sessionId: number) => api.get(`/ai-companion/chat/${sessionId}/messages`),
  
  // 学习计划
  createStudyPlan: (data: any) => api.post('/ai-companion/study-plans', data),
  getMyStudyPlans: () => api.get('/ai-companion/study-plans'),
  getStudyPlanDetail: (id: number) => api.get(`/ai-companion/study-plans/${id}`),
  updateStudyPlan: (id: number, data: any) => api.put(`/ai-companion/study-plans/${id}`, data),
  
  // 每日任务
  getDailyTasks: () => api.get('/ai-companion/daily-tasks'),
  completeDailyTask: (id: number) => api.post(`/ai-companion/daily-tasks/${id}/complete`),
  
  // 学习分析
  getMyAnalytics: () => api.get('/ai-companion/analytics'),
  getWeeklyReport: () => api.get('/ai-companion/analytics/weekly'),
  getKnowledgeMastery: () => api.get('/ai-companion/analytics/knowledge-mastery'),
  
  // 错题本
  addErrorQuestion: (data: any) => api.post('/ai-companion/error-notebook', data),
  getMyErrors: () => api.get('/ai-companion/error-notebook'),
  markAsMastered: (id: number) => api.put(`/ai-companion/error-notebook/${id}/master`),
  
  // 学习建议
  getMySuggestions: () => api.get('/ai-companion/suggestions'),
  adoptSuggestion: (id: number) => api.post(`/ai-companion/suggestions/${id}/adopt`),
  
  // OCR
  recognizeImage: (imageUrl: string, ocrType: string) => 
    api.post('/ai-companion/ocr/recognize', { imageUrl, ocrType }),
  
  // 推荐
  getQuestionRecommendations: () => api.get('/ai-companion/recommendations/questions'),
  getResourceRecommendations: () => api.get('/ai-companion/recommendations/resources'),
  
  // 提醒
  getMyReminders: () => api.get('/ai-companion/reminders'),
  markReminderAsRead: (id: number) => api.put(`/ai-companion/reminders/${id}/read`),
  
  // 成就
  getMyAchievements: () => api.get('/ai-companion/achievements'),
  getAllAchievements: () => api.get('/ai-companion/achievements/all'),
};

// ==================== 兼容旧代码的导出 ====================
export async function getHotspots() {
  try {
    const response = await geopoliticsApi.getHotspots();
    return response.data;
  } catch {
    // 如果API失败，回退到mock数据
    const mod = await import('../mock/hotspots.json');
    return mod.default;
  }
}

export async function getExperiments() {
  try {
    const response = await cyberLabApi.getTemplates();
    return response.data;
  } catch {
    const mod = await import('../mock/experiments.json');
    return mod.default;
  }
}

export async function getTasks() {
  try {
    const response = await scenarioApi.getTasks();
    return response.data;
  } catch {
    const mod = await import('../mock/tasks.json');
    return mod.default;
  }
}

export async function getResources() {
  const mod = await import('../mock/resources.json');
  return mod.default;
}

export async function getAvatars() {
  try {
    const response = await scenarioApi.getRoles();
    return response.data;
  } catch {
    const mod = await import('../mock/avatars.json');
    return mod.default;
  }
}

// 导出axios实例供其他地方使用
export default api;



