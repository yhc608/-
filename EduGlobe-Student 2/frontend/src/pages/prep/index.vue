<template>
  <div class="prep-page">
    <!-- 顶部导航 -->
    <div class="nav-tabs">
      <router-link 
        v-for="tab in tabs" 
        :key="tab.path"
        :to="tab.path"
        class="nav-tab"
        :class="{ active: currentPath === tab.path }"
      >
        {{ tab.label }}
      </router-link>
    </div>

    <!-- 子路由内容或默认内容 -->
    <div class="content">
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" v-if="Component" />
          <!-- 默认页面内容（当没有子路由时） -->
          <div v-else class="prep-home">
            <!-- 预习状态卡片 -->
            <div class="status-card">
              <div class="status-header">
                <h2>本周预习进度</h2>
                <span class="progress-badge">{{ weekProgress }}%</span>
              </div>
              <div class="progress-bar-container">
                <div class="progress-bar">
                  <div class="progress-fill" :style="{ width: weekProgress + '%' }"></div>
                </div>
              </div>
              <div class="status-stats">
                <div class="stat-item">
                  <span class="stat-value">{{ completedLessons }}</span>
                  <span class="stat-label">已完成</span>
                </div>
                <div class="stat-item">
                  <span class="stat-value">{{ totalLessons }}</span>
                  <span class="stat-label">总课时</span>
                </div>
                <div class="stat-item">
                  <span class="stat-value">{{ remainingLessons }}</span>
                  <span class="stat-label">待预习</span>
                </div>
              </div>
            </div>

            <!-- 今日预习任务 -->
            <div class="section">
              <div class="section-header">
                <h3 class="section-title">
                  <span class="material-icons">today</span>
                  今日预习
                </h3>
              </div>
              <div class="task-list">
                <div 
                  v-for="task in todayTasks" 
                  :key="task.id"
                  class="task-card"
                  @click="startTask(task)"
                >
                  <div class="task-icon">
                    <span class="material-icons">{{ task.icon }}</span>
                  </div>
                  <div class="task-info">
                    <h4 class="task-title">{{ task.title }}</h4>
                    <p class="task-desc">{{ task.description }}</p>
                    <div class="task-meta">
                      <span class="meta-item">
                        <span class="material-icons">schedule</span>
                        {{ task.duration }}
                      </span>
                      <span class="meta-item" :class="'difficulty-' + task.difficulty">
                        {{ task.difficulty === 'easy' ? '简单' : task.difficulty === 'medium' ? '中等' : '困难' }}
                      </span>
                    </div>
                  </div>
                  <div class="task-action">
                    <button class="start-btn">
                      <span class="material-icons">play_arrow</span>
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- 推荐学习路径 -->
            <div class="section">
              <div class="section-header">
                <h3 class="section-title">
                  <span class="material-icons">route</span>
                  推荐学习路径
                </h3>
              </div>
              <div class="path-list">
                <div 
                  v-for="path in recommendedPaths" 
                  :key="path.id"
                  class="path-card"
                  :style="{ background: path.gradient }"
                  @click="enterPath(path)"
                >
                  <h4 class="path-title">{{ path.title }}</h4>
                  <p class="path-desc">{{ path.description }}</p>
                  <div class="path-stats">
                    <span class="path-stat">{{ path.lessons }}个知识点</span>
                    <span class="path-stat">{{ path.progress }}%完成</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- 快速入口 -->
            <div class="section">
              <div class="section-header">
                <h3 class="section-title">
                  <span class="material-icons">dashboard</span>
                  快速入口
                </h3>
              </div>
              <div class="quick-actions">
                <div class="action-item" @click="goToKnowledgeMap">
                  <div class="action-icon">
                    <span class="material-icons">account_tree</span>
                  </div>
                  <span class="action-label">知识图谱</span>
                </div>
                <div class="action-item" @click="goToCards">
                  <div class="action-icon">
                    <span class="material-icons">style</span>
                  </div>
                  <span class="action-label">概念卡片</span>
                </div>
                <div class="action-item" @click="goToQuiz">
                  <div class="action-icon">
                    <span class="material-icons">quiz</span>
                  </div>
                  <span class="action-label">预习检测</span>
                </div>
              </div>
            </div>
          </div>
        </transition>
      </router-view>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const currentPath = computed(() => route.path)

const tabs = [
  { path: '/prep/knowledge-map', label: '知识图谱' },
  { path: '/prep/cards', label: '概念卡片' },
  { path: '/prep/quiz', label: '预习检测' }
]

// 预习进度数据
const weekProgress = ref(65)
const completedLessons = ref(8)
const totalLessons = ref(12)
const remainingLessons = computed(() => totalLessons.value - completedLessons.value)

// 今日任务
const todayTasks = ref([
  {
    id: 1,
    title: '大气的组成与分层',
    description: '理解大气的垂直分层结构及其特征',
    icon: 'cloud',
    duration: '15分钟',
    difficulty: 'medium'
  },
  {
    id: 2,
    title: '大气的热力作用',
    description: '掌握地面和大气对太阳辐射的吸收和反射',
    icon: 'wb_sunny',
    duration: '20分钟',
    difficulty: 'hard'
  }
])

// 推荐路径
const recommendedPaths = ref([
  {
    id: 1,
    title: '自然地理基础',
    description: '从地球演化开始，系统学习自然地理知识',
    gradient: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    lessons: 24,
    progress: 45
  },
  {
    id: 2,
    title: '人文地理探索',
    description: '了解人类活动与地理环境的关系',
    gradient: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
    lessons: 18,
    progress: 30
  }
])

// 方法
const startTask = (task: any) => {
  router.push('/prep/cards')
}

const enterPath = (path: any) => {
  router.push('/prep/knowledge-map')
}

const goToKnowledgeMap = () => {
  router.push('/prep/knowledge-map')
}

const goToCards = () => {
  router.push('/prep/cards')
}

const goToQuiz = () => {
  router.push('/prep/quiz')
}
</script>

<style scoped lang="scss">
.prep-page {
  padding-top: var(--spacing-base);
  padding-bottom: 60px;
}

.nav-tabs {
  display: flex;
  justify-content: space-around;
  background: white;
  padding: var(--spacing-base);
  margin-bottom: var(--spacing-base);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  position: sticky;
  top: 0;
  z-index: 10;
}

.nav-tab {
  padding: var(--spacing-base);
  color: var(--color-text-secondary);
  text-decoration: none;
  position: relative;
  font-weight: 500;
  min-width: 80px;
  text-align: center;

  &::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 50%;
    transform: translateX(-50%);
    width: 0;
    height: 2px;
    background: var(--color-primary);
    transition: width 0.3s ease;
  }

  &.active {
    color: var(--color-primary);

    &::after {
      width: 24px;
    }
  }
}

.content {
  padding: 0 var(--spacing-base);
}

// 预习主页样式
.prep-home {
  padding-bottom: var(--spacing-xlarge);
}

// 状态卡片
.status-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: var(--radius-large);
  padding: var(--spacing-large);
  color: white;
  margin-bottom: var(--spacing-large);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.3);

  .status-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--spacing-base);

    h2 {
      margin: 0;
      font-size: 20px;
      font-weight: 700;
    }

    .progress-badge {
      background: rgba(255, 255, 255, 0.2);
      padding: 6px 16px;
      border-radius: 20px;
      font-size: 18px;
      font-weight: 700;
    }
  }

  .progress-bar-container {
    margin-bottom: var(--spacing-large);

    .progress-bar {
      height: 10px;
      background: rgba(255, 255, 255, 0.2);
      border-radius: 5px;
      overflow: hidden;

      .progress-fill {
        height: 100%;
        background: white;
        border-radius: 5px;
        transition: width 0.5s ease;
      }
    }
  }

  .status-stats {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: var(--spacing-base);

    .stat-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 4px;

      .stat-value {
        font-size: 28px;
        font-weight: 700;
      }

      .stat-label {
        font-size: 13px;
        opacity: 0.9;
      }
    }
  }
}

// 通用section样式
.section {
  margin-bottom: var(--spacing-xlarge);

  .section-header {
    margin-bottom: var(--spacing-base);

    .section-title {
      margin: 0;
      font-size: 18px;
      font-weight: 700;
      color: var(--color-text-primary);
      display: flex;
      align-items: center;
      gap: var(--spacing-small);

      .material-icons {
        color: var(--color-primary);
        font-size: 24px;
      }
    }
  }
}

// 任务列表
.task-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);
}

.task-card {
  background: white;
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  display: flex;
  gap: var(--spacing-base);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  .task-icon {
    width: 48px;
    height: 48px;
    border-radius: var(--radius-base);
    background: linear-gradient(135deg, #a8e6cf 0%, #56ab2f 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;

    .material-icons {
      font-size: 28px;
      color: white;
    }
  }

  .task-info {
    flex: 1;

    .task-title {
      margin: 0 0 4px;
      font-size: 16px;
      font-weight: 600;
      color: var(--color-text-primary);
    }

    .task-desc {
      margin: 0 0 var(--spacing-small);
      font-size: 13px;
      color: var(--color-text-secondary);
      line-height: 1.4;
    }

    .task-meta {
      display: flex;
      gap: var(--spacing-base);

      .meta-item {
        display: flex;
        align-items: center;
        gap: 4px;
        font-size: 12px;
        color: var(--color-text-tertiary);

        .material-icons {
          font-size: 16px;
        }

        &.difficulty-easy {
          color: #10b981;
        }

        &.difficulty-medium {
          color: #f59e0b;
        }

        &.difficulty-hard {
          color: #ef4444;
        }
      }
    }
  }

  .task-action {
    .start-btn {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      background: var(--color-primary);
      border: none;
      color: white;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: all 0.3s ease;

      &:hover {
        background: var(--color-primary-dark);
        transform: scale(1.1);
      }

      .material-icons {
        font-size: 24px;
      }
    }
  }
}

// 学习路径
.path-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);
}

.path-card {
  border-radius: var(--radius-base);
  padding: var(--spacing-large);
  color: white;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.25);
  }

  .path-title {
    margin: 0 0 var(--spacing-small);
    font-size: 18px;
    font-weight: 700;
  }

  .path-desc {
    margin: 0 0 var(--spacing-base);
    font-size: 14px;
    opacity: 0.95;
    line-height: 1.5;
  }

  .path-stats {
    display: flex;
    gap: var(--spacing-base);

    .path-stat {
      font-size: 13px;
      opacity: 0.9;
    }
  }
}

// 快速入口
.quick-actions {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--spacing-base);
}

.action-item {
  background: white;
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--spacing-small);
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);

    .action-icon {
      transform: scale(1.1);
    }
  }

  .action-icon {
    width: 56px;
    height: 56px;
    border-radius: 50%;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    transition: transform 0.3s ease;

    .material-icons {
      font-size: 32px;
      color: white;
    }
  }

  .action-label {
    font-size: 13px;
    font-weight: 500;
    color: var(--color-text-primary);
    text-align: center;
  }
}

// 页面切换动画
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
