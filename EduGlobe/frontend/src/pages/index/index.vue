<template>
  <div class="home-page">
    <!-- 欢迎横幅 -->
    <div class="welcome-banner">
      <div class="banner-content">
        <h1 class="welcome-title">
          <span class="greeting">{{ greeting }}</span>
          <span class="user-name">{{ userName }}</span>
        </h1>
        <p class="welcome-subtitle">让我们一起探索地理的奥秘 🌏</p>
      </div>
      <div class="banner-stats">
        <div class="stat-item">
          <span class="stat-value">{{ stats.studyDays }}</span>
          <span class="stat-label">学习天数</span>
        </div>
        <div class="stat-item">
          <span class="stat-value">{{ stats.completedTasks }}</span>
          <span class="stat-label">完成任务</span>
        </div>
        <div class="stat-item">
          <span class="stat-value">{{ stats.achievements }}</span>
          <span class="stat-label">获得成就</span>
        </div>
      </div>
    </div>

    <!-- 快捷操作区 -->
    <div class="quick-actions">
      <Card
        v-for="action in quickActions"
        :key="action.id"
        :variant="action.variant"
        :icon="action.icon"
        hoverable
        size="medium"
        class="action-card"
        @click="handleQuickAction(action.id)"
      >
        <div class="action-content">
          <h3 class="action-title">{{ action.title }}</h3>
          <p class="action-description">{{ action.description }}</p>
          <div class="action-meta">
            <span class="meta-item">
              <span class="material-icons">schedule</span>
              {{ action.duration }}
            </span>
            <span class="meta-item">
              <span class="material-icons">trending_up</span>
              {{ action.progress }}%
            </span>
          </div>
        </div>
        <template #footer>
          <Button type="text" size="small" suffix-icon="arrow_forward">
            {{ action.buttonText }}
          </Button>
        </template>
      </Card>
    </div>

    <!-- 特色功能区 -->
    <div class="feature-section">
      <div class="section-header">
        <h2 class="section-title">
          <span class="material-icons">stars</span>
          特色功能
        </h2>
        <Button type="text" size="small" @click="viewAllFeatures">
          查看全部
          <span class="material-icons">arrow_forward</span>
        </Button>
      </div>

      <div class="feature-grid">
        <!-- 经纬瞰政 -->
        <Card
          variant="ocean"
          hoverable
          shadow
          class="feature-card geopolitics-card"
          @click="openGeopolitics"
        >
          <div class="feature-icon-wrapper">
            <div class="feature-icon">🌍</div>
          </div>
          <h3 class="feature-title">经纬瞰政</h3>
          <p class="feature-desc">时政热点地理解读</p>
          <div class="feature-tags">
            <span class="tag">热点追踪</span>
            <span class="tag">知识拆解</span>
            <span class="tag">思维训练</span>
          </div>
        </Card>

        <!-- 赛博实验 -->
        <Card
          variant="forest"
          hoverable
          shadow
          class="feature-card cyberlab-card"
          @click="openCyberlab"
        >
          <div class="feature-icon-wrapper">
            <div class="feature-icon">🔬</div>
          </div>
          <h3 class="feature-title">赛博实验</h3>
          <p class="feature-desc">地理虚拟实验室</p>
          <div class="feature-tags">
            <span class="tag">实验模拟</span>
            <span class="tag">数据分析</span>
            <span class="tag">交互探索</span>
          </div>
        </Card>

        <!-- 情景互动 -->
        <Card
          variant="mountain"
          hoverable
          shadow
          class="feature-card interactive-card"
          @click="openInteractive"
        >
          <div class="feature-icon-wrapper">
            <div class="feature-icon">🎮</div>
          </div>
          <h3 class="feature-title">情景互动</h3>
          <p class="feature-desc">第一视角探索</p>
          <div class="feature-tags">
            <span class="tag">角色扮演</span>
            <span class="tag">场景融合</span>
            <span class="tag">沉浸体验</span>
          </div>
        </Card>

        <!-- AI 地理伴学 -->
        <Card
          variant="gradient"
          hoverable
          shadow
          class="feature-card companion-card"
          @click="openCompanion"
        >
          <div class="feature-icon-wrapper">
            <div class="feature-icon">🤖</div>
          </div>
          <h3 class="feature-title">AI 地理伴学</h3>
          <p class="feature-desc">智能学习助手</p>
          <div class="feature-tags">
            <span class="tag">智能答疑</span>
            <span class="tag">学习规划</span>
            <span class="tag">进度追踪</span>
          </div>
        </Card>
      </div>
    </div>

    <!-- 今日推荐 -->
    <div class="recommendation-section">
      <div class="section-header">
        <h2 class="section-title">
          <span class="material-icons">lightbulb</span>
          今日推荐
        </h2>
      </div>

      <Card variant="default" shadow class="recommendation-card">
        <div class="recommendation-content">
          <div class="recommendation-image">
            <img src="/images/knowledge-card.jpg" alt="知识卡片" />
            <div class="recommendation-badge">热门</div>
          </div>
          <div class="recommendation-info">
            <h3 class="recommendation-title">地球的自转与公转</h3>
            <p class="recommendation-desc">
              深入理解地球自转和公转的原理，掌握昼夜更替和四季变化的成因
            </p>
            <div class="recommendation-stats">
              <span class="stat">
                <span class="material-icons">visibility</span>
                1.2k 次学习
              </span>
              <span class="stat">
                <span class="material-icons">star</span>
                4.9 评分
              </span>
              <span class="stat">
                <span class="material-icons">schedule</span>
                约 20 分钟
              </span>
            </div>
          </div>
        </div>
        <template #footer>
          <Button type="primary" @click="viewRecommendation">
            开始学习
          </Button>
          <Button type="ghost" @click="skipRecommendation">
            稍后再看
          </Button>
        </template>
      </Card>
    </div>

    <!-- 学习日历 -->
    <div class="calendar-section">
      <div class="section-header">
        <h2 class="section-title">
          <span class="material-icons">calendar_today</span>
          本周学习计划
        </h2>
      </div>
      
      <div class="week-calendar">
        <div 
          v-for="day in weekDays" 
          :key="day.date"
          class="calendar-day"
          :class="{ 
            today: day.isToday, 
            completed: day.completed,
            hasTask: day.tasks > 0 
          }"
        >
          <div class="day-header">
            <span class="day-name">{{ day.name }}</span>
            <span class="day-date">{{ day.date }}</span>
          </div>
          <div class="day-content">
            <div v-if="day.tasks > 0" class="task-indicator">
              <span class="material-icons">task_alt</span>
              <span class="task-count">{{ day.tasks }}</span>
            </div>
            <div v-if="day.completed" class="completed-mark">
              <span class="material-icons">check_circle</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 最近学习 -->
    <div class="recent-section">
      <div class="section-header">
        <h2 class="section-title">
          <span class="material-icons">history</span>
          最近学习
        </h2>
        <Button type="text" size="small" @click="viewAllHistory">
          查看全部
          <span class="material-icons">arrow_forward</span>
        </Button>
      </div>

      <div class="recent-list">
        <Card
          v-for="item in recentStudies"
          :key="item.id"
          class="recent-item"
          hoverable
          @click="continueStudy(item)"
        >
          <div class="recent-icon" :class="`icon-${item.type}`">
            <span class="material-icons">{{ item.icon }}</span>
          </div>
          <div class="recent-info">
            <h4 class="recent-title">{{ item.title }}</h4>
            <p class="recent-meta">
              {{ item.subject }} · {{ item.time }}
            </p>
            <div class="recent-progress">
              <div class="progress-bar">
                <div 
                  class="progress-fill" 
                  :style="{ width: item.progress + '%' }"
                ></div>
              </div>
              <span class="progress-text">{{ item.progress }}%</span>
            </div>
          </div>
        </Card>
      </div>
    </div>

    <!-- 班级动态 -->
    <div class="class-feed-section">
      <div class="section-header">
        <h2 class="section-title">
          <span class="material-icons">groups</span>
          班级动态
        </h2>
        <Button type="text" size="small" @click="viewClassFeed">
          更多
          <span class="material-icons">arrow_forward</span>
        </Button>
      </div>

      <div class="feed-list">
        <div 
          v-for="feed in classFeeds" 
          :key="feed.id"
          class="feed-item"
        >
          <img :src="feed.avatar" :alt="feed.user" class="feed-avatar" />
          <div class="feed-content">
            <div class="feed-header">
              <span class="feed-user">{{ feed.user }}</span>
              <span class="feed-time">{{ feed.time }}</span>
            </div>
            <p class="feed-text">{{ feed.content }}</p>
            <div v-if="feed.achievement" class="feed-achievement">
              <span class="material-icons">military_tech</span>
              获得成就：{{ feed.achievement }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 知识地图进度 -->
    <div class="knowledge-progress-section">
      <div class="section-header">
        <h2 class="section-title">
          <span class="material-icons">account_tree</span>
          知识图谱进度
        </h2>
        <Button type="text" size="small" @click="viewKnowledgeMap">
          查看详情
          <span class="material-icons">arrow_forward</span>
        </Button>
      </div>

      <div class="knowledge-stats">
        <div class="knowledge-stat-item">
          <div class="stat-circle" style="--progress: 75%; --color: #4CAF50;">
            <svg viewBox="0 0 100 100">
              <circle cx="50" cy="50" r="45"></circle>
              <circle cx="50" cy="50" r="45"></circle>
            </svg>
            <span class="stat-value">75%</span>
          </div>
          <p class="stat-name">自然地理</p>
        </div>
        <div class="knowledge-stat-item">
          <div class="stat-circle" style="--progress: 60%; --color: #2196F3;">
            <svg viewBox="0 0 100 100">
              <circle cx="50" cy="50" r="45"></circle>
              <circle cx="50" cy="50" r="45"></circle>
            </svg>
            <span class="stat-value">60%</span>
          </div>
          <p class="stat-name">人文地理</p>
        </div>
        <div class="knowledge-stat-item">
          <div class="stat-circle" style="--progress: 45%; --color: #FF9800;">
            <svg viewBox="0 0 100 100">
              <circle cx="50" cy="50" r="45"></circle>
              <circle cx="50" cy="50" r="45"></circle>
            </svg>
            <span class="stat-value">45%</span>
          </div>
          <p class="stat-name">区域地理</p>
        </div>
      </div>
    </div>

    <!-- 成就展示 -->
    <div class="achievements-section">
      <div class="section-header">
        <h2 class="section-title">
          <span class="material-icons">emoji_events</span>
          最近成就
        </h2>
        <Button type="text" size="small" @click="viewAllAchievements">
          全部成就
          <span class="material-icons">arrow_forward</span>
        </Button>
      </div>

      <div class="achievements-grid">
        <div 
          v-for="achievement in recentAchievements" 
          :key="achievement.id"
          class="achievement-card"
          :class="{ locked: !achievement.unlocked }"
        >
          <div class="achievement-icon">
            <span class="material-icons">{{ achievement.icon }}</span>
          </div>
          <h4 class="achievement-title">{{ achievement.title }}</h4>
          <p class="achievement-desc">{{ achievement.description }}</p>
          <span v-if="achievement.unlocked" class="achievement-date">
            {{ achievement.date }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import Card from '@/components/common/Card.vue'
import Button from '@/components/common/Button.vue'
import { useNotification } from '@/composables/useNotification'

const router = useRouter()
const { success, info } = useNotification()

// 用户信息
const userName = ref('同学')
const greeting = computed(() => {
  const hour = new Date().getHours()
  if (hour < 6) return '深夜好'
  if (hour < 12) return '早上好'
  if (hour < 14) return '中午好'
  if (hour < 18) return '下午好'
  if (hour < 22) return '晚上好'
  return '夜深了'
})

// 统计数据
const stats = ref({
  studyDays: 45,
  completedTasks: 128,
  achievements: 23
})

// 快捷操作
const quickActions = ref([
  {
    id: 'prep',
    title: '课前预习',
    description: '今日已推送新章节',
    icon: 'menu_book',
    variant: 'forest',
    duration: '15分钟',
    progress: 65,
    buttonText: '开始预习'
  },
  {
    id: 'homework',
    title: '课后作业',
    description: '3项待完成作业',
    icon: 'assignment',
    variant: 'ocean',
    duration: '20分钟',
    progress: 40,
    buttonText: '去完成'
  },
  {
    id: 'review',
    title: '复习巩固',
    description: '错题本有5道新题',
    icon: 'psychology',
    variant: 'mountain',
    duration: '12分钟',
    progress: 80,
    buttonText: '开始复习'
  }
])

// 方法
const handleQuickAction = (actionId: string) => {
  switch (actionId) {
    case 'prep':
      router.push('/prep')
      break
    case 'homework':
      info('作业功能', '即将进入课后作业')
      break
    case 'review':
      router.push('/review')
      break
  }
}

const viewAllFeatures = () => {
  info('功能', '查看全部特色功能')
}

const openGeopolitics = () => {
  router.push('/feature/geopolitics')
}

const openCyberlab = () => {
  router.push('/feature/cyberlab')
}

const openInteractive = () => {
  router.push('/feature/interactive')
}

const openCompanion = () => {
  router.push('/feature/companion')
}

const viewRecommendation = () => {
  success('开始学习', '正在进入课程...')
  router.push('/prep/cards')
}

const skipRecommendation = () => {
  info('已收藏', '课程已添加到稍后学习列表')
}

// 本周学习计划
const weekDays = ref([
  { name: '周一', date: '12/11', isToday: false, tasks: 3, completed: true },
  { name: '周二', date: '12/12', isToday: false, tasks: 2, completed: true },
  { name: '周三', date: '12/13', isToday: false, tasks: 4, completed: true },
  { name: '周四', date: '12/14', isToday: true, tasks: 3, completed: false },
  { name: '周五', date: '12/15', isToday: false, tasks: 2, completed: false },
  { name: '周六', date: '12/16', isToday: false, tasks: 1, completed: false },
  { name: '周日', date: '12/17', isToday: false, tasks: 0, completed: false }
])

// 最近学习记录
const recentStudies = ref([
  {
    id: 1,
    title: '世界气候类型分布',
    subject: '自然地理',
    time: '2小时前',
    progress: 75,
    type: 'prep',
    icon: 'cloud'
  },
  {
    id: 2,
    title: '人口迁移与城市化',
    subject: '人文地理',
    time: '1天前',
    progress: 60,
    type: 'classroom',
    icon: 'people'
  },
  {
    id: 3,
    title: '中国地形特征',
    subject: '区域地理',
    time: '2天前',
    progress: 90,
    type: 'review',
    icon: 'terrain'
  }
])

// 班级动态
const classFeeds = ref([
  {
    id: 1,
    user: '张同学',
    avatar: '/avatars/avatar1.jpg',
    content: '完成了"世界洋流"章节的学习',
    time: '5分钟前',
    achievement: '海洋探索者'
  },
  {
    id: 2,
    user: '李同学',
    avatar: '/avatars/avatar2.jpg',
    content: '在地理知识竞赛中获得第一名',
    time: '30分钟前',
    achievement: '知识达人'
  },
  {
    id: 3,
    user: '王同学',
    avatar: '/avatars/avatar3.jpg',
    content: '连续学习7天，保持学习热情',
    time: '1小时前',
    achievement: null
  }
])

// 最近成就
const recentAchievements = ref([
  {
    id: 1,
    icon: 'emoji_events',
    title: '连续打卡7天',
    description: '坚持学习一周',
    unlocked: true,
    date: '2天前'
  },
  {
    id: 2,
    icon: 'star',
    title: '知识小能手',
    description: '完成50个知识点',
    unlocked: true,
    date: '5天前'
  },
  {
    id: 3,
    icon: 'school',
    title: '学霸之路',
    description: '连续学习30天',
    unlocked: false,
    date: ''
  },
  {
    id: 4,
    icon: 'workspace_premium',
    title: '完美答题',
    description: '测验100分',
    unlocked: false,
    date: ''
  }
])

const viewAllHistory = () => {
  router.push('/mine/history')
}

const continueStudy = (item: any) => {
  success('继续学习', `正在打开${item.title}...`)
  if (item.type === 'prep') {
    router.push('/prep')
  } else if (item.type === 'classroom') {
    router.push('/classroom')
  } else {
    router.push('/review')
  }
}

const viewClassFeed = () => {
  router.push('/review/channel-square')
}

const viewKnowledgeMap = () => {
  router.push('/prep/knowledge-map')
}

const viewAllAchievements = () => {
  router.push('/mine/achievements')
}

// 加载用户数据
onMounted(() => {
  // 从localStorage获取用户名
  const user = localStorage.getItem('user')
  if (user) {
    try {
      const userData = JSON.parse(user)
      userName.value = userData.real_name || userData.username || '同学'
    } catch (e) {
      console.error('Failed to parse user data', e)
    }
  }
})
</script>

<style scoped lang="scss">
@import './index.scss';

.topic-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-base);
  margin-bottom: var(--spacing-base);
  position: relative;
  z-index: 1;

  .material-icons {
    font-size: 24px;
    color: #ffd700;
  }

  h3 {
    margin: 0;
    font-size: 1.5em;
    font-weight: 600;
  }

  .difficulty-badge {
    background: rgba(255, 255, 255, 0.2);
    padding: 4px var(--spacing-small);
    border-radius: 12px;
    font-size: 0.8em;
    backdrop-filter: blur(10px);
  }
}

.topic-content {
  position: relative;
  z-index: 1;
  margin-bottom: var(--spacing-large);
}

.content-section {
  margin-bottom: var(--spacing-base);

  h4 {
    margin: 0 0 var(--spacing-small);
    font-size: 1.1em;
    font-weight: 600;
    color: #ffd700;
  }

  p {
    margin: 0 0 var(--spacing-small);
    line-height: 1.6;
    opacity: 0.9;
  }

  .content-points {
    margin: 0;
    padding-left: var(--spacing-base);
    opacity: 0.9;

    li {
      margin-bottom: 4px;
      line-height: 1.5;
    }
  }
}

.topic-actions {
  display: flex;
  gap: var(--spacing-base);
  position: relative;
  z-index: 1;

  .btn-primary {
    background: rgba(255, 255, 255, 0.2);
    border: 1px solid rgba(255, 255, 255, 0.3);
    color: white;
    backdrop-filter: blur(10px);

    &:hover {
      background: rgba(255, 255, 255, 0.3);
    }
  }

  .btn-text {
    color: white;
    border-color: rgba(255, 255, 255, 0.3);

    &:hover {
      background: rgba(255, 255, 255, 0.1);
    }
  }
}

// 时事热点解读样式
.news-content {
  margin-top: var(--spacing-base);
}

.news-item {
  background: var(--color-bg-tertiary);
  padding: var(--spacing-large);
  border-radius: var(--radius-base);
  border-left: 4px solid var(--color-primary);
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
    background: var(--color-bg-secondary);
  }
}

.news-header {
  margin-bottom: var(--spacing-base);

  .news-title {
    font-size: 1.2em;
    font-weight: 600;
    margin-bottom: var(--spacing-small);
    color: var(--color-text-primary);
  }

  .news-meta {
    display: flex;
    gap: var(--spacing-base);
    font-size: 0.9em;
    color: var(--color-text-secondary);

    .news-source {
      color: var(--color-primary);
      font-weight: 500;
    }
  }
}

.news-summary {
  margin-bottom: var(--spacing-large);
  padding: var(--spacing-base);
  background: rgba(var(--color-primary-rgb), 0.05);
  border-radius: var(--radius-small);
  border-left: 3px solid var(--color-primary);

  p {
    margin: 0;
    line-height: 1.6;
    color: var(--color-text-primary);
  }
}

.geography-analysis {
  margin-bottom: var(--spacing-large);

  h4 {
    margin: 0 0 var(--spacing-base);
    color: var(--color-primary);
    font-size: 1.1em;
    font-weight: 600;
    display: flex;
    align-items: center;
    gap: var(--spacing-small);

    &::before {
      content: '🌍';
      font-size: 1.2em;
    }
  }
}

.analysis-sections {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);
}

.analysis-section {
  background: white;
  padding: var(--spacing-base);
  border-radius: var(--radius-small);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);

  h5 {
    margin: 0 0 var(--spacing-small);
    color: var(--color-primary);
    font-size: 1em;
    font-weight: 600;
  }

  p {
    margin: 0 0 var(--spacing-small);
    line-height: 1.6;
    color: var(--color-text-primary);
  }

  .analysis-points {
    margin: 0;
    padding-left: var(--spacing-base);
    color: var(--color-text-secondary);

    li {
      margin-bottom: 4px;
      line-height: 1.5;
    }
  }
}

.news-actions {
  display: flex;
  gap: var(--spacing-base);
  flex-wrap: wrap;

  .btn-primary {
    flex: 1;
    min-width: 120px;
  }

  .btn-text {
    flex: 1;
    min-width: 80px;
  }
}

// 动画
@keyframes float {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-10px) rotate(5deg); }
}

// 概念列表
.concept-list {
  margin-top: var(--spacing-base);
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);
}

.concept-item {
  background: var(--color-bg-tertiary);
  padding: var(--spacing-base);
  border-radius: var(--radius-base);
  cursor: pointer;
  transition: var(--transition-base);

  &:hover {
    background: var(--color-bg-secondary);
    transform: translateY(-2px);
    box-shadow: var(--shadow-base);
  }

  .concept-info {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 8px;
  }

  .concept-title {
    font-weight: 500;
  }

  .concept-meta {
    font-size: 0.9em;
    color: var(--color-text-secondary);
    display: flex;
    gap: var(--spacing-base);
  }

  .concept-desc {
    color: var(--color-text-secondary);
    font-size: 0.9em;
    line-height: 1.5;
  }
}

// 下载列表
.download-list {
  margin-top: var(--spacing-base);
  display: flex;
  flex-direction: column;
  gap: var(--spacing-small);
}

.download-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-base);
  padding: var(--spacing-base);
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
  transition: var(--transition-base);

  &:hover {
    background: var(--color-bg-secondary);
  }

  .resource-icon {
    width: 40px;
    height: 40px;
    border-radius: var(--radius-base);
    background: var(--color-primary);
    display: flex;
    align-items: center;
    justify-content: center;

    .material-icons {
      color: white;
    }
  }

  .resource-info {
    flex: 1;
  }

  .resource-name {
    margin-bottom: 4px;
  }

  .resource-meta {
    font-size: 0.9em;
    color: var(--color-text-secondary);
    display: flex;
    gap: var(--spacing-base);
  }
}

// 模态框样式
.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: var(--spacing-base);
}

.modal-content {
  width: 100%;
  max-width: 480px;
  max-height: 80vh;
  background: white;
  border-radius: var(--radius-base);
  overflow: hidden;
  display: flex;
  flex-direction: column;

  &.large {
    max-width: 600px;
  }

  .modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: var(--spacing-base);
    border-bottom: 1px solid var(--color-border);

    h3 {
      margin: 0;
      font-size: 1.1em;
    }
  }

  .modal-body {
    flex: 1;
    padding: var(--spacing-base);
    overflow-y: auto;
  }

  .modal-footer {
    padding: var(--spacing-base);
    border-top: 1px solid var(--color-border);
    display: flex;
    justify-content: flex-end;
    gap: var(--spacing-base);
  }
}

// 详情内容样式
.highlight-detail, .news-detail {
  .content-section {
    margin-bottom: var(--spacing-large);

    h4 {
      margin: 0 0 var(--spacing-base);
      color: var(--color-primary);
      font-size: 1.1em;
      font-weight: 600;
    }

    p {
      margin: 0;
      line-height: 1.6;
      color: var(--color-text-primary);
    }
  }
}

// 今日重点推送按钮样式
.btn-highlight {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  color: white;
  padding: var(--spacing-base) var(--spacing-large);
  border-radius: var(--radius-base);
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
    background: linear-gradient(135deg, #5a6fd8 0%, #6a4190 100%);
  }

  &:active {
    transform: translateY(0);
  }

  .material-icons {
    font-size: 20px;
  }
}

// 时事热点解读按钮样式
.btn-news {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  border: none;
  color: white;
  padding: var(--spacing-base) var(--spacing-large);
  border-radius: var(--radius-base);
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  box-shadow: 0 4px 15px rgba(240, 147, 251, 0.3);

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(240, 147, 251, 0.4);
    background: linear-gradient(135deg, #e881f9 0%, #f3455a 100%);
  }

  &:active {
    transform: translateY(0);
  }

  .material-icons {
    font-size: 20px;
  }
}

</style>