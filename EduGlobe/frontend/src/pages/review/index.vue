<template>
  <div class="review-page">
    <!-- 顶部导航 -->
    <div class="nav-tabs">
      <router-link 
        v-for="tab in tabs" 
        :key="tab.path"
        :to="tab.path"
        class="nav-tab"
        :class="{ active: currentPath === tab.path }"
      >
        <span class="material-icons">{{ tab.icon }}</span>
        {{ tab.label }}
      </router-link>
    </div>

    <!-- 子路由内容 -->
    <div class="content">
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" v-if="Component" />
          <!-- 复习主页默认内容 -->
          <div v-else class="review-home">
            <!-- 复习进度卡片 -->
            <div class="review-progress-card">
              <h2>📚 本周复习概览</h2>
              <div class="progress-grid">
                <div class="progress-item">
                  <div class="progress-circle" style="--progress: 75%; --color: #10b981;">
                    <svg viewBox="0 0 100 100">
                      <circle cx="50" cy="50" r="40"></circle>
                      <circle cx="50" cy="50" r="40"></circle>
                    </svg>
                    <span class="progress-value">75%</span>
                  </div>
                  <span class="progress-label">知识巩固率</span>
                </div>
                <div class="progress-item">
                  <div class="progress-circle" style="--progress: 88%; --color: #3b82f6;">
                    <svg viewBox="0 0 100 100">
                      <circle cx="50" cy="50" r="40"></circle>
                      <circle cx="50" cy="50" r="40"></circle>
                    </svg>
                    <span class="progress-value">88%</span>
                  </div>
                  <span class="progress-label">练习准确率</span>
                </div>
                <div class="progress-item">
                  <div class="progress-circle" style="--progress: 62%; --color: #f59e0b;">
                    <svg viewBox="0 0 100 100">
                      <circle cx="50" cy="50" r="40"></circle>
                      <circle cx="50" cy="50" r="40"></circle>
                    </svg>
                    <span class="progress-value">62%</span>
                  </div>
                  <span class="progress-label">错题掌握度</span>
                </div>
              </div>
            </div>

            <!-- 复习任务列表 -->
            <div class="section">
              <h3 class="section-title">
                <span class="material-icons">task_alt</span>
                待复习内容
              </h3>
              <div class="review-tasks">
                <div 
                  v-for="task in reviewTasks" 
                  :key="task.id"
                  class="review-task-card"
                  :class="'priority-' + task.priority"
                  @click="startReview(task)"
                >
                  <div class="task-left">
                    <div class="task-priority">
                      <span class="material-icons">{{ getPriorityIcon(task.priority) }}</span>
                    </div>
                    <div class="task-content">
                      <h4 class="task-title">{{ task.title }}</h4>
                      <p class="task-subtitle">{{ task.topic }} · {{ task.questionCount }}道题</p>
                    </div>
                  </div>
                  <div class="task-right">
                    <div class="task-urgency">
                      <span class="material-icons">schedule</span>
                      <span>{{ task.daysLeft }}天后到期</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- 热门频道 -->
            <div class="section">
              <h3 class="section-title">
                <span class="material-icons">trending_up</span>
                热门学习频道
              </h3>
              <div class="channel-grid">
                <div 
                  v-for="channel in hotChannels" 
                  :key="channel.id"
                  class="channel-card"
                  @click="joinChannel(channel)"
                >
                  <div class="channel-cover" :style="{ background: channel.cover }">
                    <span class="channel-icon">{{ channel.icon }}</span>
                  </div>
                  <div class="channel-info">
                    <h4 class="channel-name">{{ channel.name }}</h4>
                    <div class="channel-meta">
                      <span class="meta-item">
                        <span class="material-icons">people</span>
                        {{ channel.members }}
                      </span>
                      <span class="meta-item">
                        <span class="material-icons">chat</span>
                        {{ channel.posts }}条动态
                      </span>
                    </div>
                  </div>
                  <button class="join-btn">加入</button>
                </div>
              </div>
            </div>

            <!-- AI答疑快捷入口 -->
            <div class="ai-qa-banner" @click="openAiQa">
              <div class="ai-icon">
                <span class="material-icons">psychology</span>
              </div>
              <div class="ai-info">
                <h3>🤖 AI智能答疑</h3>
                <p>遇到问题？AI助教24小时在线为你解答</p>
              </div>
              <span class="material-icons">arrow_forward</span>
            </div>

            <!-- 学习报告预览 -->
            <div class="section">
              <div class="section-header">
                <h3 class="section-title">
                  <span class="material-icons">assessment</span>
                  本周学习报告
                </h3>
                <button class="view-all-btn" @click="viewReport">查看详情</button>
              </div>
              <div class="report-preview">
                <div class="report-item">
                  <div class="report-icon" style="background: #dbeafe;">
                    <span class="material-icons" style="color: #3b82f6;">schedule</span>
                  </div>
                  <div class="report-data">
                    <span class="data-value">12.5</span>
                    <span class="data-label">小时</span>
                  </div>
                  <span class="report-label">总学习时长</span>
                </div>
                <div class="report-item">
                  <div class="report-icon" style="background: #dcfce7;">
                    <span class="material-icons" style="color: #10b981;">check_circle</span>
                  </div>
                  <div class="report-data">
                    <span class="data-value">156</span>
                    <span class="data-label">题</span>
                  </div>
                  <span class="report-label">完成练习</span>
                </div>
                <div class="report-item">
                  <div class="report-icon" style="background: #fef3c7;">
                    <span class="material-icons" style="color: #f59e0b;">emoji_events</span>
                  </div>
                  <div class="report-data">
                    <span class="data-value">3</span>
                    <span class="data-label">个</span>
                  </div>
                  <span class="report-label">新增成就</span>
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
  { 
    path: '/review/channel-square',
    label: '频道广场',
    icon: 'forum'
  },
  { 
    path: '/review/ai-qa',
    label: '智能答疑',
    icon: 'psychology'
  },
  {
    path: '/review/report',
    label: '学习报告',
    icon: 'assessment'
  },
  {
    path: '/review/resources',
    label: '拓展资源',
    icon: 'library_books'
  }
]

// 复习任务
const reviewTasks = ref([
  {
    id: 1,
    title: '地球运动错题复习',
    topic: '自然地理',
    questionCount: 12,
    priority: 'high',
    daysLeft: 2
  },
  {
    id: 2,
    title: '人口迁移知识巩固',
    topic: '人文地理',
    questionCount: 8,
    priority: 'medium',
    daysLeft: 4
  },
  {
    id: 3,
    title: '中国地形特征回顾',
    topic: '区域地理',
    questionCount: 15,
    priority: 'low',
    daysLeft: 7
  }
])

// 热门频道
const hotChannels = ref([
  {
    id: 1,
    name: '高考地理冲刺',
    icon: '🎯',
    cover: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    members: 1234,
    posts: 456
  },
  {
    id: 2,
    name: '世界地理探索',
    icon: '🌍',
    cover: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
    members: 892,
    posts: 328
  },
  {
    id: 3,
    name: '地理奥赛训练',
    icon: '🏆',
    cover: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
    members: 567,
    posts: 234
  }
])

const getPriorityIcon = (priority: string) => {
  const icons: Record<string, string> = {
    high: 'priority_high',
    medium: 'remove',
    low: 'arrow_downward'
  }
  return icons[priority] || 'remove'
}

const startReview = (task: any) => {
  router.push('/review/resources')
}

const joinChannel = (channel: any) => {
  router.push('/review/channel-square')
}

const openAiQa = () => {
  router.push('/review/ai-qa')
}

const viewReport = () => {
  router.push('/review/report')
}
</script>

<style scoped lang="scss">
.review-page {
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
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--spacing-small);
  padding: var(--spacing-base);
  color: var(--color-text-secondary);
  text-decoration: none;
  position: relative;
  min-width: 80px;
  text-align: center;

  .material-icons {
    font-size: 24px;
  }

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

// 页面切换动画
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

// 适配大字体模式
:global(.large-text) {
  .nav-tab {
    font-size: 1.1em;
  }
}

:global(.xlarge-text) {
  .nav-tab {
    font-size: 1.2em;
  }
}

// 复习主页样式
.review-home {
  padding-bottom: var(--spacing-large);
}

.review-progress-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 20px;
  padding: var(--spacing-large);
  margin-bottom: var(--spacing-large);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.25);

  h2 {
    color: white;
    font-size: 1.5rem;
    font-weight: bold;
    margin-bottom: var(--spacing-large);
    text-align: center;
  }

  .progress-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: var(--spacing-large);

    .progress-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: var(--spacing-base);

      .progress-circle {
        position: relative;
        width: 100px;
        height: 100px;

        svg {
          transform: rotate(-90deg);
          width: 100%;
          height: 100%;

          circle {
            fill: none;
            stroke-width: 8;

            &:first-child {
              stroke: rgba(255, 255, 255, 0.2);
            }

            &:last-child {
              stroke: var(--color);
              stroke-dasharray: 251.2;
              stroke-dashoffset: calc(251.2 * (1 - var(--progress) / 100%));
              stroke-linecap: round;
              transition: stroke-dashoffset 1s ease;
            }
          }
        }

        .progress-value {
          position: absolute;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          font-size: 1.5rem;
          font-weight: bold;
          color: white;
        }
      }

      .progress-label {
        color: white;
        font-size: 0.9rem;
        font-weight: 500;
      }
    }
  }
}

.section {
  margin-bottom: var(--spacing-large);

  .section-title {
    display: flex;
    align-items: center;
    gap: var(--spacing-small);
    font-size: 1.2rem;
    font-weight: bold;
    margin-bottom: var(--spacing-base);
    color: var(--color-text-primary);

    .material-icons {
      color: var(--color-primary);
    }
  }

  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--spacing-base);

    .view-all-btn {
      padding: 8px 16px;
      background: var(--color-primary);
      color: white;
      border: none;
      border-radius: 8px;
      font-size: 0.9rem;
      cursor: pointer;
      transition: background 0.2s;

      &:hover {
        background: var(--color-primary-dark);
      }
    }
  }
}

.review-tasks {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);

  .review-task-card {
    background: white;
    border-radius: 16px;
    padding: var(--spacing-base) var(--spacing-large);
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    cursor: pointer;
    transition: all 0.3s;
    border-left: 4px solid transparent;

    &.priority-high {
      border-left-color: #ef4444;

      .task-priority {
        background: #fee2e2;

        .material-icons {
          color: #ef4444;
        }
      }
    }

    &.priority-medium {
      border-left-color: #f59e0b;

      .task-priority {
        background: #fef3c7;

        .material-icons {
          color: #f59e0b;
        }
      }
    }

    &.priority-low {
      border-left-color: #10b981;

      .task-priority {
        background: #dcfce7;

        .material-icons {
          color: #10b981;
        }
      }
    }

    &:hover {
      transform: translateX(4px);
      box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
    }

    .task-left {
      display: flex;
      align-items: center;
      gap: var(--spacing-base);

      .task-priority {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;

        .material-icons {
          font-size: 20px;
        }
      }

      .task-content {
        .task-title {
          font-size: 1rem;
          font-weight: 600;
          color: var(--color-text-primary);
          margin-bottom: 4px;
        }

        .task-subtitle {
          font-size: 0.85rem;
          color: var(--color-text-secondary);
        }
      }
    }

    .task-right {
      .task-urgency {
        display: flex;
        align-items: center;
        gap: 4px;
        padding: 6px 12px;
        background: #f3f4f6;
        border-radius: 8px;
        font-size: 0.85rem;
        color: var(--color-text-secondary);

        .material-icons {
          font-size: 16px;
        }
      }
    }
  }
}

.channel-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: var(--spacing-base);

  .channel-card {
    background: white;
    border-radius: 16px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    cursor: pointer;
    transition: all 0.3s;

    &:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
    }

    .channel-cover {
      height: 120px;
      display: flex;
      align-items: center;
      justify-content: center;

      .channel-icon {
        font-size: 3rem;
      }
    }

    .channel-info {
      padding: var(--spacing-base);

      .channel-name {
        font-size: 1.1rem;
        font-weight: bold;
        color: var(--color-text-primary);
        margin-bottom: var(--spacing-small);
      }

      .channel-meta {
        display: flex;
        gap: var(--spacing-base);

        .meta-item {
          display: flex;
          align-items: center;
          gap: 4px;
          font-size: 0.85rem;
          color: var(--color-text-secondary);

          .material-icons {
            font-size: 16px;
          }
        }
      }
    }

    .join-btn {
      width: calc(100% - 2 * var(--spacing-base));
      margin: 0 var(--spacing-base) var(--spacing-base);
      padding: 10px;
      background: var(--color-primary);
      color: white;
      border: none;
      border-radius: 8px;
      font-size: 0.9rem;
      font-weight: 500;
      cursor: pointer;
      transition: background 0.2s;

      &:hover {
        background: var(--color-primary-dark);
      }
    }
  }
}

.ai-qa-banner {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  border-radius: 16px;
  padding: var(--spacing-large);
  margin-bottom: var(--spacing-large);
  display: flex;
  align-items: center;
  gap: var(--spacing-base);
  box-shadow: 0 4px 16px rgba(79, 172, 254, 0.3);
  cursor: pointer;
  transition: all 0.3s;

  &:hover {
    transform: translateX(4px);
    box-shadow: 0 8px 24px rgba(79, 172, 254, 0.4);
  }

  .ai-icon {
    width: 60px;
    height: 60px;
    background: rgba(255, 255, 255, 0.2);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    backdrop-filter: blur(10px);

    .material-icons {
      font-size: 2rem;
      color: white;
    }
  }

  .ai-info {
    flex: 1;
    color: white;

    h3 {
      font-size: 1.2rem;
      font-weight: bold;
      margin-bottom: 4px;
    }

    p {
      font-size: 0.9rem;
      opacity: 0.95;
    }
  }

  > .material-icons {
    color: white;
    font-size: 2rem;
  }
}

.report-preview {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--spacing-base);

  .report-item {
    background: white;
    border-radius: 16px;
    padding: var(--spacing-large);
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: var(--spacing-small);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    transition: transform 0.2s;

    &:hover {
      transform: translateY(-4px);
    }

    .report-icon {
      width: 56px;
      height: 56px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;

      .material-icons {
        font-size: 28px;
      }
    }

    .report-data {
      display: flex;
      align-items: baseline;
      gap: 4px;

      .data-value {
        font-size: 2rem;
        font-weight: bold;
        color: var(--color-text-primary);
      }

      .data-label {
        font-size: 0.9rem;
        color: var(--color-text-secondary);
      }
    }

    .report-label {
      font-size: 0.9rem;
      color: var(--color-text-secondary);
      text-align: center;
    }
  }
}
</style>
