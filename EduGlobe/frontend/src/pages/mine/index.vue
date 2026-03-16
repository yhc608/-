<template>
  <div class="mine-page">
    <!-- 用户信息卡片 -->
    <div class="user-card">
      <div class="user-avatar-wrapper">
        <img :src="userInfo.avatar" alt="用户头像" class="user-avatar" />
        <div class="level-badge">
          <span class="material-icons">grade</span>
          Lv.{{ userInfo.level }}
        </div>
      </div>
      <div class="user-info">
        <h2 class="user-name">{{ userInfo.name }}</h2>
        <p class="user-school">{{ userInfo.school }} · {{ userInfo.grade }}</p>
      </div>
      <button class="edit-profile-btn" @click="editProfile">
        <span class="material-icons">edit</span>
      </button>
    </div>

    <!-- 学习统计 -->
    <div class="stats-grid">
      <div class="stat-card" @click="viewStudyTime">
        <div class="stat-icon" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
          <span class="material-icons">schedule</span>
        </div>
        <div class="stat-content">
          <span class="stat-value">{{ stats.studyHours }}</span>
          <span class="stat-label">学习时长(h)</span>
        </div>
      </div>
      <div class="stat-card" @click="viewCompletedTasks">
        <div class="stat-icon" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
          <span class="material-icons">assignment_turned_in</span>
        </div>
        <div class="stat-content">
          <span class="stat-value">{{ stats.completedTasks }}</span>
          <span class="stat-label">完成任务</span>
        </div>
      </div>
      <div class="stat-card" @click="viewAchievements">
        <div class="stat-icon" style="background: linear-gradient(135deg, #fbc2eb 0%, #a6c1ee 100%);">
          <span class="material-icons">emoji_events</span>
        </div>
        <div class="stat-content">
          <span class="stat-value">{{ stats.achievements }}</span>
          <span class="stat-label">获得成就</span>
        </div>
      </div>
      <div class="stat-card" @click="viewRanking">
        <div class="stat-icon" style="background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);">
          <span class="material-icons">leaderboard</span>
        </div>
        <div class="stat-content">
          <span class="stat-value">{{ stats.ranking }}</span>
          <span class="stat-label">班级排名</span>
        </div>
      </div>
    </div>

    <!-- 功能菜单 -->
    <div class="menu-section">
      <h3 class="section-title">我的学习</h3>
      <div class="menu-list">
        <div class="menu-item" @click="navigateTo('/mine/history')">
          <div class="menu-icon">
            <span class="material-icons">history</span>
          </div>
          <span class="menu-text">学习历史</span>
          <span class="material-icons menu-arrow">chevron_right</span>
        </div>
        <div class="menu-item" @click="navigateTo('/mine/favorites')">
          <div class="menu-icon">
            <span class="material-icons">bookmark</span>
          </div>
          <span class="menu-text">我的收藏</span>
          <span class="material-icons menu-arrow">chevron_right</span>
        </div>
        <div class="menu-item" @click="navigateTo('/mine/notes')">
          <div class="menu-icon">
            <span class="material-icons">note</span>
          </div>
          <span class="menu-text">学习笔记</span>
          <span class="material-icons menu-arrow">chevron_right</span>
        </div>
        <div class="menu-item" @click="navigateTo('/mine/errors')">
          <div class="menu-icon">
            <span class="material-icons">error</span>
          </div>
          <span class="menu-text">错题本</span>
          <div class="menu-badge">{{ errorCount }}</div>
          <span class="material-icons menu-arrow">chevron_right</span>
        </div>
      </div>
    </div>

    <div class="menu-section">
      <h3 class="section-title">学习工具</h3>
      <div class="menu-list">
        <div class="menu-item" @click="navigateTo('/mine/calendar')">
          <div class="menu-icon">
            <span class="material-icons">calendar_month</span>
          </div>
          <span class="menu-text">学习日历</span>
          <span class="material-icons menu-arrow">chevron_right</span>
        </div>
        <div class="menu-item" @click="navigateTo('/mine/plan')">
          <div class="menu-icon">
            <span class="material-icons">event_note</span>
          </div>
          <span class="menu-text">学习计划</span>
          <span class="material-icons menu-arrow">chevron_right</span>
        </div>
        <div class="menu-item" @click="navigateTo('/mine/downloads')">
          <div class="menu-icon">
            <span class="material-icons">download</span>
          </div>
          <span class="menu-text">离线下载</span>
          <span class="material-icons menu-arrow">chevron_right</span>
        </div>
      </div>
    </div>

    <div class="menu-section">
      <h3 class="section-title">设置</h3>
      <div class="menu-list">
        <div class="menu-item" @click="navigateTo('/settings')">
          <div class="menu-icon">
            <span class="material-icons">settings</span>
          </div>
          <span class="menu-text">应用设置</span>
          <span class="material-icons menu-arrow">chevron_right</span>
        </div>
        <div class="menu-item" @click="feedbackSystem">
          <div class="menu-icon">
            <span class="material-icons">feedback</span>
          </div>
          <span class="menu-text">意见反馈</span>
          <span class="material-icons menu-arrow">chevron_right</span>
        </div>
        <div class="menu-item" @click="aboutApp">
          <div class="menu-icon">
            <span class="material-icons">info</span>
          </div>
          <span class="menu-text">关于我们</span>
          <span class="material-icons menu-arrow">chevron_right</span>
        </div>
      </div>
    </div>

    <!-- 退出登录按钮 -->
    <div class="logout-section">
      <button class="logout-btn" @click="logout">
        <span class="material-icons">logout</span>
        退出登录
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useNotification } from '@/composables/useNotification'

const router = useRouter()
const { success, info, warning } = useNotification()

// 用户信息
const userInfo = ref({
  name: '同学',
  avatar: '/avatars/default.jpg',
  school: '示范中学',
  grade: '初二年级',
  level: 12
})

// 统计数据
const stats = ref({
  studyHours: 45.5,
  completedTasks: 128,
  achievements: 23,
  ranking: 5
})

// 错题数量
const errorCount = ref(12)

// 方法
const editProfile = () => {
  router.push('/mine/profile')
}

const viewStudyTime = () => {
  router.push('/mine/study-time')
}

const viewCompletedTasks = () => {
  router.push('/mine/tasks')
}

const viewAchievements = () => {
  router.push('/mine/achievements')
}

const viewRanking = () => {
  router.push('/mine/ranking')
}

const navigateTo = (path: string) => {
  router.push(path)
}

const feedbackSystem = () => {
  info('意见反馈', '感谢您的反馈！')
}

const aboutApp = () => {
  info('关于我们', 'EduGlobe 地理教育平台 v1.0.0')
}

const logout = () => {
  if (confirm('确定要退出登录吗？')) {
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    success('已退出', '期待您再次回来！')
    router.push('/login')
  }
}

// 加载用户数据
onMounted(() => {
  const user = localStorage.getItem('user')
  if (user) {
    try {
      const userData = JSON.parse(user)
      userInfo.value.name = userData.real_name || userData.username || '同学'
      if (userData.avatar_url) {
        userInfo.value.avatar = userData.avatar_url
      }
    } catch (e) {
      console.error('Failed to parse user data', e)
    }
  }
})
</script>

<style scoped lang="scss">
.mine-page {
  min-height: calc(100vh - 56px);
  padding: var(--spacing-base);
  padding-bottom: 80px;
  background: #f5f7fa;
}

// 用户卡片
.user-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: var(--radius-large);
  padding: var(--spacing-xlarge);
  color: white;
  display: flex;
  align-items: center;
  gap: var(--spacing-base);
  margin-bottom: var(--spacing-large);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.3);
  position: relative;

  .user-avatar-wrapper {
    position: relative;

    .user-avatar {
      width: 80px;
      height: 80px;
      border-radius: 50%;
      border: 3px solid rgba(255, 255, 255, 0.3);
      object-fit: cover;
    }

    .level-badge {
      position: absolute;
      bottom: -4px;
      right: -4px;
      background: #fbbf24;
      color: white;
      padding: 4px 8px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: 700;
      display: flex;
      align-items: center;
      gap: 2px;
      box-shadow: 0 2px 8px rgba(251, 191, 36, 0.4);

      .material-icons {
        font-size: 14px;
      }
    }
  }

  .user-info {
    flex: 1;

    .user-name {
      margin: 0 0 var(--spacing-mini);
      font-size: 24px;
      font-weight: 700;
    }

    .user-school {
      margin: 0;
      font-size: 14px;
      opacity: 0.9;
    }
  }

  .edit-profile-btn {
    background: rgba(255, 255, 255, 0.2);
    border: none;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    color: white;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.3s ease;

    &:hover {
      background: rgba(255, 255, 255, 0.3);
      transform: scale(1.1);
    }

    .material-icons {
      font-size: 20px;
    }
  }
}

// 统计卡片
.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: var(--spacing-base);
  margin-bottom: var(--spacing-large);
}

.stat-card {
  background: white;
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  .stat-icon {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;

    .material-icons {
      font-size: 28px;
      color: white;
    }
  }

  .stat-content {
    display: flex;
    flex-direction: column;

    .stat-value {
      font-size: 24px;
      font-weight: 700;
      color: var(--color-text-primary);
      line-height: 1;
      margin-bottom: 4px;
    }

    .stat-label {
      font-size: 12px;
      color: var(--color-text-secondary);
    }
  }
}

// 菜单部分
.menu-section {
  margin-bottom: var(--spacing-large);

  .section-title {
    margin: 0 0 var(--spacing-small);
    font-size: 14px;
    font-weight: 600;
    color: var(--color-text-secondary);
    padding: 0 var(--spacing-small);
  }
}

.menu-list {
  background: white;
  border-radius: var(--radius-base);
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.menu-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-base);
  padding: var(--spacing-base);
  cursor: pointer;
  transition: background 0.2s ease;
  border-bottom: 1px solid #f3f4f6;
  position: relative;

  &:last-child {
    border-bottom: none;
  }

  &:hover {
    background: #f9fafb;
  }

  .menu-icon {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    background: #f3f4f6;
    display: flex;
    align-items: center;
    justify-content: center;

    .material-icons {
      font-size: 24px;
      color: var(--color-primary);
    }
  }

  .menu-text {
    flex: 1;
    font-size: 15px;
    color: var(--color-text-primary);
    font-weight: 500;
  }

  .menu-badge {
    background: #ef4444;
    color: white;
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 12px;
    font-weight: 600;
    min-width: 20px;
    text-align: center;
  }

  .menu-arrow {
    font-size: 20px;
    color: var(--color-text-tertiary);
  }
}

// 退出登录
.logout-section {
  margin-top: var(--spacing-xlarge);
  padding: 0 var(--spacing-small);
}

.logout-btn {
  width: 100%;
  background: white;
  border: 2px solid #ef4444;
  color: #ef4444;
  padding: var(--spacing-base);
  border-radius: var(--radius-base);
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--spacing-small);
  transition: all 0.3s ease;

  &:hover {
    background: #ef4444;
    color: white;
  }

  .material-icons {
    font-size: 20px;
  }
}
</style>
