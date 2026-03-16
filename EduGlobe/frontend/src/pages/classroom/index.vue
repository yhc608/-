<template>
  <div class="classroom-page">
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
          <!-- 课堂主页默认内容 -->
          <div v-else class="classroom-home">
            <!-- 课堂状态横幅 -->
            <div class="classroom-banner">
              <div class="banner-info">
                <h2>🎓 欢迎来到智慧课堂</h2>
                <p>让学习变得更有趣、更高效</p>
              </div>
              <div class="class-status">
                <div class="status-indicator active">
                  <span class="material-icons">circle</span>
                  <span>课堂进行中</span>
                </div>
              </div>
            </div>

            <!-- 课堂互动统计 -->
            <div class="interaction-stats">
              <div class="stat-card" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                <div class="stat-icon">
                  <span class="material-icons">forum</span>
                </div>
                <div class="stat-info">
                  <span class="stat-value">{{ interactions.questions }}</span>
                  <span class="stat-label">提问次数</span>
                </div>
              </div>
              <div class="stat-card" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                <div class="stat-icon">
                  <span class="material-icons">emoji_events</span>
                </div>
                <div class="stat-info">
                  <span class="stat-value">{{ interactions.points }}</span>
                  <span class="stat-label">积分</span>
                </div>
              </div>
              <div class="stat-card" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
                <div class="stat-icon">
                  <span class="material-icons">videogame_asset</span>
                </div>
                <div class="stat-info">
                  <span class="stat-value">{{ interactions.games }}</span>
                  <span class="stat-label">游戏闯关</span>
                </div>
              </div>
            </div>

            <!-- 虚拟角色推荐 -->
            <div class="section">
              <h3 class="section-title">
                <span class="material-icons">face</span>
                虚拟学习伙伴
              </h3>
              <div class="tutor-grid">
                <div 
                  v-for="tutor in tutors" 
                  :key="tutor.id"
                  class="tutor-card"
                  @click="selectTutor(tutor)"
                >
                  <div class="tutor-avatar" :style="{ background: tutor.color }">
                    <span class="tutor-emoji">{{ tutor.emoji }}</span>
                  </div>
                  <h4 class="tutor-name">{{ tutor.name }}</h4>
                  <p class="tutor-desc">{{ tutor.specialty }}</p>
                  <button class="tutor-btn">立即互动</button>
                </div>
              </div>
            </div>

            <!-- 热门游戏 -->
            <div class="section">
              <h3 class="section-title">
                <span class="material-icons">sports_esports</span>
                热门地理游戏
              </h3>
              <div class="game-list">
                <div 
                  v-for="game in games" 
                  :key="game.id"
                  class="game-card"
                  @click="playGame(game)"
                >
                  <div class="game-thumbnail" :style="{ background: game.gradient }">
                    <span class="game-icon">{{ game.icon }}</span>
                  </div>
                  <div class="game-info">
                    <h4 class="game-title">{{ game.title }}</h4>
                    <p class="game-desc">{{ game.description }}</p>
                    <div class="game-meta">
                      <span class="meta-item">
                        <span class="material-icons">person</span>
                        {{ game.players }}人在玩
                      </span>
                      <span class="meta-item score">
                        <span class="material-icons">star</span>
                        {{ game.rating }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- 课堂问答榜单 -->
            <div class="section">
              <h3 class="section-title">
                <span class="material-icons">leaderboard</span>
                本周问答榜
              </h3>
              <div class="ranking-list">
                <div 
                  v-for="(student, index) in ranking" 
                  :key="student.id"
                  class="ranking-item"
                  :class="'rank-' + (index + 1)"
                >
                  <div class="rank-badge">
                    <span v-if="index < 3" class="material-icons">{{ ['emoji_events', 'workspace_premium', 'military_tech'][index] }}</span>
                    <span v-else class="rank-number">{{ index + 1 }}</span>
                  </div>
                  <img :src="student.avatar" :alt="student.name" class="student-avatar" />
                  <div class="student-info">
                    <span class="student-name">{{ student.name }}</span>
                    <span class="student-answers">回答了 {{ student.answers }} 个问题</span>
                  </div>
                  <div class="student-points">{{ student.points }}分</div>
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
    path: '/classroom/virtual-tutor',
    label: '虚拟角色',
    icon: 'face'
  },
  {
    path: '/classroom/games',
    label: '地理小游戏',
    icon: 'sports_esports'
  },
  {
    path: '/classroom/qa',
    label: '课堂问答',
    icon: 'question_answer'
  }
]

// 课堂互动数据
const interactions = ref({
  questions: 23,
  points: 456,
  games: 8
})

// 虚拟角色
const tutors = ref([
  {
    id: 1,
    name: '地理小博士',
    emoji: '🎓',
    specialty: '擅长自然地理知识',
    color: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)'
  },
  {
    id: 2,
    name: '探险家',
    emoji: '🧭',
    specialty: '带你探索世界奇观',
    color: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)'
  },
  {
    id: 3,
    name: '气象专家',
    emoji: '⛅',
    specialty: '解读天气与气候',
    color: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)'
  }
])

// 热门游戏
const games = ref([
  {
    id: 1,
    title: '地图大挑战',
    description: '在地图上找到正确的地理位置',
    icon: '🗺️',
    gradient: 'linear-gradient(135deg, #a8e6cf 0%, #56ab2f 100%)',
    players: 328,
    rating: 4.8
  },
  {
    id: 2,
    title: '气候猜猜猜',
    description: '根据特征判断气候类型',
    icon: '🌦️',
    gradient: 'linear-gradient(135deg, #84fab0 0%, #8fd3f4 100%)',
    players: 245,
    rating: 4.6
  },
  {
    id: 3,
    title: '地形识别王',
    description: '识别各种地形地貌特征',
    icon: '⛰️',
    gradient: 'linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%)',
    players: 189,
    rating: 4.7
  }
])

// 问答榜单
const ranking = ref([
  { id: 1, name: '王小明', avatar: '/avatars/avatar1.jpg', answers: 45, points: 890 },
  { id: 2, name: '李小红', avatar: '/avatars/avatar2.jpg', answers: 38, points: 760 },
  { id: 3, name: '张伟', avatar: '/avatars/avatar3.jpg', answers: 32, points: 640 },
  { id: 4, name: '刘芳', avatar: '/avatars/avatar4.jpg', answers: 28, points: 560 },
  { id: 5, name: '陈军', avatar: '/avatars/avatar5.jpg', answers: 25, points: 500 }
])

const selectTutor = (tutor: any) => {
  router.push('/classroom/virtual-tutor')
}

const playGame = (game: any) => {
  router.push('/classroom/games')
}
</script>

<style scoped lang="scss">
.classroom-page {
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

// 课堂主页样式
.classroom-home {
  padding-bottom: var(--spacing-large);
}

.classroom-banner {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  padding: var(--spacing-large);
  margin-bottom: var(--spacing-large);
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.25);

  .banner-info {
    color: white;

    h2 {
      font-size: 1.5rem;
      font-weight: bold;
      margin-bottom: var(--spacing-small);
    }

    p {
      font-size: 0.95rem;
      opacity: 0.95;
    }
  }

  .class-status {
    .status-indicator {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 8px 16px;
      background: rgba(255, 255, 255, 0.2);
      border-radius: 20px;
      backdrop-filter: blur(10px);
      color: white;
      font-size: 0.9rem;

      &.active {
        .material-icons {
          color: #4ade80;
          animation: pulse 2s ease-in-out infinite;
        }
      }
    }
  }
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.interaction-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--spacing-base);
  margin-bottom: var(--spacing-large);

  .stat-card {
    padding: var(--spacing-large);
    border-radius: 16px;
    display: flex;
    align-items: center;
    gap: var(--spacing-base);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    transition: transform 0.2s;

    &:hover {
      transform: translateY(-4px);
    }

    .stat-icon {
      .material-icons {
        font-size: 2rem;
        color: white;
      }
    }

    .stat-info {
      display: flex;
      flex-direction: column;
      color: white;

      .stat-value {
        font-size: 1.8rem;
        font-weight: bold;
      }

      .stat-label {
        font-size: 0.85rem;
        opacity: 0.9;
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
}

.tutor-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--spacing-base);

  .tutor-card {
    background: white;
    border-radius: 16px;
    padding: var(--spacing-large);
    text-align: center;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    transition: all 0.3s;
    cursor: pointer;

    &:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
    }

    .tutor-avatar {
      width: 80px;
      height: 80px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto var(--spacing-base);

      .tutor-emoji {
        font-size: 2.5rem;
      }
    }

    .tutor-name {
      font-size: 1.1rem;
      font-weight: bold;
      margin-bottom: var(--spacing-small);
      color: var(--color-text-primary);
    }

    .tutor-desc {
      font-size: 0.85rem;
      color: var(--color-text-secondary);
      margin-bottom: var(--spacing-base);
    }

    .tutor-btn {
      width: 100%;
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

.game-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);

  .game-card {
    background: white;
    border-radius: 16px;
    padding: var(--spacing-base);
    display: flex;
    gap: var(--spacing-base);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    cursor: pointer;
    transition: all 0.3s;

    &:hover {
      transform: translateX(4px);
      box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
    }

    .game-thumbnail {
      width: 100px;
      height: 100px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;

      .game-icon {
        font-size: 3rem;
      }
    }

    .game-info {
      flex: 1;
      display: flex;
      flex-direction: column;
      justify-content: space-between;

      .game-title {
        font-size: 1.1rem;
        font-weight: bold;
        color: var(--color-text-primary);
        margin-bottom: 4px;
      }

      .game-desc {
        font-size: 0.9rem;
        color: var(--color-text-secondary);
        margin-bottom: var(--spacing-small);
      }

      .game-meta {
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

          &.score {
            color: #f59e0b;

            .material-icons {
              color: #f59e0b;
            }
          }
        }
      }
    }
  }
}

.ranking-list {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);

  .ranking-item {
    display: flex;
    align-items: center;
    gap: var(--spacing-base);
    padding: var(--spacing-base);
    border-bottom: 1px solid #f3f4f6;
    transition: background 0.2s;

    &:last-child {
      border-bottom: none;
    }

    &:hover {
      background: #f9fafb;
    }

    &.rank-1, &.rank-2, &.rank-3 {
      background: linear-gradient(90deg, rgba(255, 215, 0, 0.1) 0%, transparent 100%);
    }

    .rank-badge {
      width: 36px;
      height: 36px;
      display: flex;
      align-items: center;
      justify-content: center;

      .material-icons {
        font-size: 24px;
      }

      .rank-number {
        font-weight: bold;
        color: var(--color-text-secondary);
      }
    }

    &.rank-1 .rank-badge .material-icons {
      color: #ffd700;
    }

    &.rank-2 .rank-badge .material-icons {
      color: #c0c0c0;
    }

    &.rank-3 .rank-badge .material-icons {
      color: #cd7f32;
    }

    .student-avatar {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      object-fit: cover;
    }

    .student-info {
      flex: 1;
      display: flex;
      flex-direction: column;

      .student-name {
        font-weight: 500;
        color: var(--color-text-primary);
        margin-bottom: 2px;
      }

      .student-answers {
        font-size: 0.85rem;
        color: var(--color-text-secondary);
      }
    }

    .student-points {
      font-weight: bold;
      font-size: 1.1rem;
      color: var(--color-primary);
    }
  }
}
</style>
