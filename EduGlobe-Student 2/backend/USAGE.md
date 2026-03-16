# EduGlobe 功能使用指南

本指南将帮助您快速上手 EduGlobe 地理教育平台的各项功能。

## 目录
- [学生端功能](#学生端功能)
- [教师端功能](#教师端功能)
- [常见操作](#常见操作)

---

## 学生端功能

### 1. 课前预习

#### 1.1 查看知识图谱
```javascript
// 前端调用示例
import { studentAPI } from '@/services/api';

// 获取知识图谱
const knowledgeMap = await studentAPI.preview.getKnowledgeMap({
  chapter: '第一章',
  textbook_version: '人教版'
});
```

**功能说明：**
- 三维知识图谱展示章节内的所有知识点
- 点击节点查看详细的概念卡片
- 显示知识点之间的关联关系

#### 1.2 智能概念卡片
```javascript
// 获取概念卡片详情
const conceptCard = await studentAPI.preview.getConceptCard(cardId);
```

**包含内容：**
- 教材锚点（对应教材页码）
- 三维解析（知识、能力、素养）
- 易错警示
- 拓展资源
- 即时训练题

#### 1.3 预习检测
```javascript
// 获取预习测试
const test = await studentAPI.preview.getPreviewTest({
  knowledge_nodes: [1, 2, 3],
  difficulty: 3
});

// 提交测试
const result = await studentAPI.preview.submitPreviewTest({
  test_id: test.test_id,
  answers: [{ questionId: 1, answer: 'A' }],
  duration: 1200 // 秒
});
```

**功能特点：**
- AI 自动组题
- 智能诊断薄弱点
- 即时反馈和解析

### 2. 课堂互动

#### 2.1 加入课堂
```javascript
// 加入课堂
const classroom = await studentAPI.classroom.join(courseId);

// 获取虚拟角色（徐霞客、魏格纳等）
const character = classroom.virtual_character;
```

#### 2.2 实时提问
```javascript
// 提问（支持文字、语音）
const response = await studentAPI.classroom.askQuestion(
  courseId,
  '什么是等高线？',
  'text'
);

// AI 回答
console.log(response.answer);
console.log(response.response_time_ms); // 响应时间
```

#### 2.3 互动游戏
```javascript
// 开始游戏
const game = await studentAPI.classroom.playGame(gameId, courseId);

// 提交游戏结果
await studentAPI.classroom.submitGameResult({
  gameId,
  courseId,
  score: 85,
  correctCount: 17,
  totalCount: 20,
  durationSeconds: 300
});
```

**游戏类型：**
- 气候拼图
- 地理大富翁
- 地理灯谜
- 灾害模拟

### 3. 课后巩固

#### 3.1 多模态答疑
```javascript
// 文字提问
await studentAPI.qa.ask({
  questionText: '请解释季风气候的成因',
  questionType: 'text'
});

// 图片提问（拍照识图）
await studentAPI.qa.ask({
  questionText: '这个等高线图怎么分析？',
  questionType: 'image',
  mediaUrls: ['https://example.com/image.jpg'],
  imageType: 'contour'
});

// 语音提问
await studentAPI.qa.ask({
  questionText: '',
  questionType: 'voice',
  mediaUrls: ['https://example.com/audio.wav']
});
```

#### 3.2 查看学习报告
```javascript
// 获取日报
const dailyReport = await studentAPI.report.get('daily');

// 获取周报
const weeklyReport = await studentAPI.report.get('weekly');

// 获取能力雷达图
const abilityRadar = await studentAPI.report.getAbilityRadar();
/*
{
  knowledge: 85,
  skill: 78,
  thinking: 82,
  practice: 90,
  innovation: 75
}
*/
```

#### 3.3 个性化复习
```javascript
// 获取薄弱知识点
const weakPoints = await studentAPI.report.getWeakPoints();

// 获取个性化学习路径
const learningPath = await studentAPI.report.getPersonalizedPath();
```

### 4. 本科专属功能

#### 4.1 虚拟实验
```javascript
import { experimentAPI } from '@/services/api';

// 获取实验列表
const experiments = await experimentAPI.list({
  experiment_type: 'volcano'
});

// 开始实验
const session = await experimentAPI.start(experimentId);

// 提交实验报告
await experimentAPI.submit(experimentId, {
  operation_data: {},
  collected_data: {},
  report_content: '实验报告内容...'
});
```

**实验类型：**
- 野外考察
- 火山模拟
- 水文实验
- 气象观测
- 宇宙探索

#### 4.2 地学交流频道
```javascript
import { channelAPI } from '@/services/api';

// 浏览频道
const channels = await channelAPI.list();

// 创建频道
await channelAPI.create({
  name: '气候变化讨论',
  channel_type: 'discussion',
  description: '讨论气候变化相关话题'
});

// 发布帖子
await channelAPI.createPost(channelId, {
  title: '关于全球变暖的思考',
  content: '...',
  tags: ['气候变化', '全球变暖']
});
```

---

## 教师端功能

### 1. 智能备课

#### 1.1 生成教案
```javascript
import { teacherAPI } from '@/services/api';

// AI 生成教案
const lessonPlan = await teacherAPI.lesson.generate({
  title: '地球的运动',
  grade: '高一',
  textbookVersion: '人教版',
  chapter: '第一章',
  section: '第一节',
  duration: 45,
  crossSubject: true // 是否启用跨学科融合
});

// 保存教案
await teacherAPI.lesson.save({
  ...lessonPlan,
  isPublic: false // 是否公开分享
});
```

#### 1.2 教案管理
```javascript
// 获取我的教案列表
const myLessons = await teacherAPI.lesson.list({
  grade: '高一',
  textbookVersion: '人教版'
});

// 分享教案
await teacherAPI.lesson.share(lessonId, true);
```

### 2. 课堂管理

#### 2.1 实时监控
```javascript
// 获取课堂监控数据
const monitoring = await teacherAPI.monitoring.getClassroom(courseId);
/*
{
  avg_attention: 4.2,        // 平均专注度
  interaction_count: 156,    // 互动次数
  happy_count: 23,          // 愉快表情
  confused_count: 5,        // 困惑表情
  bored_count: 2            // 无聊表情
}
*/

// 获取互动统计
const stats = await teacherAPI.monitoring.getInteractionStats(courseId);

// 获取提问热点
const hotQuestions = await teacherAPI.monitoring.getHotQuestions(courseId);

// 获取教学节奏建议
const suggestion = await teacherAPI.monitoring.getTeachingPace(courseId);
```

### 3. 作业批改

#### 3.1 获取待批改作业
```javascript
// 获取待批改作业列表
const assignments = await teacherAPI.grading.getAssignments({
  status: 'submitted',
  classId: 1
});
```

#### 3.2 批改作业
```javascript
// 单个批改
await teacherAPI.grading.gradeAssignment(submissionId, {
  score: 85,
  detailedScores: {
    accuracy: 40,
    completeness: 25,
    neatness: 20
  },
  comments: '作答认真，继续保持！',
  duration: 300 // 批改用时（秒）
});

// 批量批改
await teacherAPI.grading.batchGrade([
  { submissionId: 1, score: 85, comments: '很好' },
  { submissionId: 2, score: 78, comments: '基本正确' },
  // ...
]);
```

#### 3.3 手绘地图识别
```javascript
// AI 识别手绘地图
const recognition = await teacherAPI.grading.recognizeMap({
  submissionId,
  imageUrl: 'https://example.com/map.jpg',
  mapType: 'contour' // contour, climate, terrain_profile等
});

/*
{
  accuracy_score: 0.85,
  element_scores: {
    accuracy: 85,
    completeness: 90,
    neatness: 80
  },
  suggestions: [
    '等高线间距可以更均匀',
    '标注字迹可以更清晰'
  ]
}
*/
```

### 4. 数据后台

#### 4.1 教学数据驾驶舱
```javascript
// 获取班级数据总览
const dashboard = await teacherAPI.dashboard.get(classId);

/*
{
  class_situation: {
    total_students: 45,
    active_students: 42,
    engagement_rate: 93.3
  },
  assignment_completion_rate: 87.5,
  average_score: 78.6,
  knowledge_mastery: [...],
  weak_students: [...],
  excellent_students: [...]
}
*/
```

#### 4.2 学生分析
```javascript
// 获取单个学生的详细分析
const analysis = await teacherAPI.dashboard.getStudentAnalysis(studentId);

/*
{
  student: { id, name, ... },
  learning_data: {
    assignment_count: 15,
    avg_score: 82.3,
    interaction_count: 89,
    question_count: 23
  },
  weak_points: [
    { name: '地形特征', error_count: 5 },
    ...
  ]
}
*/
```

#### 4.3 导出数据
```javascript
// 导出教学数据
const exportData = await teacherAPI.dashboard.exportData(classId);

// 可用于生成教学论文或报告
```

---

## 常见操作

### 认证流程

#### 注册
```javascript
import { authAPI } from '@/services/api';

await authAPI.register({
  username: 'student01',
  password: 'password123',
  email: 'student@example.com',
  role: 'student', // 'student' 或 'teacher'
  real_name: '张三',
  phone: '13800138000',
  school_id: 1,
  grade_level: 'middle_school'
});
```

#### 登录
```javascript
const result = await authAPI.login('student01', 'password123');

// 保存 token
localStorage.setItem('token', result.data.token);
localStorage.setItem('user', JSON.stringify(result.data.user));
```

#### 获取当前用户
```javascript
const user = await authAPI.getCurrentUser();
```

#### 更新资料
```javascript
await authAPI.updateProfile({
  real_name: '李四',
  email: 'new@example.com',
  avatar_url: 'https://example.com/avatar.jpg'
});
```

#### 修改密码
```javascript
await authAPI.changePassword('oldPassword', 'newPassword');
```

### WebSocket 实时通信

```javascript
import { io } from 'socket.io-client';

const socket = io('http://localhost:3000');

// 连接成功
socket.on('connect', () => {
  console.log('已连接到服务器');
  
  // 加入课堂房间
  socket.emit('join-classroom', courseId);
});

// 监听课堂互动更新
socket.on('interaction-update', (data) => {
  console.log('新的互动:', data);
});

// 监听新问题
socket.on('new-question', (data) => {
  console.log('有学生提问:', data);
});

// 断开连接
socket.on('disconnect', () => {
  console.log('已断开连接');
});
```

### 文件上传

```javascript
// 创建 FormData
const formData = new FormData();
formData.append('file', file);
formData.append('type', 'image');

// 上传文件
const response = await axios.post('/api/resources/upload', formData, {
  headers: {
    'Content-Type': 'multipart/form-data'
  }
});
```

---

## 最佳实践

### 1. 错误处理
```javascript
try {
  const result = await studentAPI.preview.getKnowledgeMap();
  // 处理结果
} catch (error) {
  if (error.status === 401) {
    // 未认证，跳转到登录页
    router.push('/login');
  } else if (error.status === 403) {
    // 权限不足
    alert('您没有权限访问此资源');
  } else {
    // 其他错误
    console.error('请求失败:', error.message);
  }
}
```

### 2. 加载状态
```vue
<script setup>
import { ref } from 'vue';

const loading = ref(false);
const data = ref(null);

async function fetchData() {
  loading.value = true;
  try {
    data.value = await studentAPI.preview.getKnowledgeMap();
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <div v-if="loading">加载中...</div>
  <div v-else>{{ data }}</div>
</template>
```

### 3. 分页加载
```javascript
const page = ref(1);
const pageSize = ref(20);

async function loadMore() {
  const result = await studentAPI.qa.getHistory({
    page: page.value,
    pageSize: pageSize.value
  });
  
  // 处理数据
  page.value++;
}
```

---

## 常见问题

**Q: Token 过期怎么办？**  
A: 后端会返回 401 状态码，前端拦截器会自动跳转到登录页。

**Q: 如何实现实时通信？**  
A: 使用 Socket.IO 连接到后端 WebSocket 服务。

**Q: 文件上传大小限制是多少？**  
A: 默认 100MB，可在后端配置中修改。

**Q: 如何调试 API？**  
A: 使用浏览器开发者工具的 Network 面板查看请求和响应。

---

更多详细信息，请参考：
- [README.md](README.md) - 项目总览
- [DEPLOYMENT.md](DEPLOYMENT.md) - 部署指南
- [QUICKSTART.md](QUICKSTART.md) - 快速开始

有问题？提交 Issue 或联系技术支持。
