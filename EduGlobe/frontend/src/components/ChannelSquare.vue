<template>
  <div class="channel-square">
    <!-- 顶部导航 -->
    <div class="channel-header">
      <div class="header-left">
        <button class="btn-icon" @click="goBack">
          <span class="material-icons">arrow_back</span>
        </button>
        <h1>频道广场</h1>
      </div>
      <div class="header-right">
        <button class="btn-text" @click="toggleRecommend">
          <span :class="{ active: showRecommended }">推荐</span>
        </button>
      </div>
    </div>

    <!-- 搜索栏 -->
    <div class="search-section">
      <div class="search-bar">
        <span class="material-icons search-icon">search</span>
        <input 
          type="text" 
          placeholder="搜索" 
          v-model="searchQuery"
          @input="handleSearch"
        >
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="main-content">
      <!-- 左侧分类 -->
      <div class="category-sidebar">
        <div class="category-list">
          <div 
            v-for="category in categories" 
            :key="category.id"
            class="category-item"
            :class="{ active: selectedCategory === category.id }"
            @click="selectCategory(category.id)"
          >
            <span class="category-indicator" v-if="selectedCategory === category.id"></span>
            <span class="material-icons category-arrow">keyboard_arrow_left</span>
            <span class="category-name">{{ category.name }}</span>
          </div>
        </div>
      </div>

      <!-- 右侧频道列表 -->
      <div class="channel-content">
        <div class="channel-list">
          <div 
            v-for="channel in filteredChannels" 
            :key="channel.id"
            class="channel-item"
            @click="viewChannel(channel)"
          >
            <div class="channel-icon">
              <img :src="channel.icon" :alt="channel.name">
            </div>
            <div class="channel-info">
              <h3 class="channel-name">{{ channel.name }}</h3>
              <p class="channel-stats">
                {{ channel.topics }}话题 | {{ channel.members }}人
              </p>
            </div>
            <div class="channel-action">
              <button 
                class="join-btn"
                :class="{ joined: channel.isJoined }"
                @click.stop="toggleJoin(channel)"
              >
                {{ channel.isJoined ? '已加入' : '+ 加入' }}
              </button>
            </div>
          </div>
        </div>

        <!-- 空状态 -->
        <div v-if="filteredChannels.length === 0" class="empty-state">
          <span class="material-icons">search_off</span>
          <p>没有找到相关频道</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

// 状态管理
const selectedCategory = ref('physical-geography')
const searchQuery = ref('')
const showRecommended = ref(false)

// 分类数据
const categories = [
  { id: 'physical-geography', name: '自然地理' },
  { id: 'human-geography', name: '人文地理' },
  { id: 'geographic-info', name: '地理信息' },
  { id: 'qa-square', name: '问答广场' }
]

// 频道数据
const channels = ref([
  {
    id: 'hydrology',
    name: '水文学',
    category: 'physical-geography',
    icon: '/channels/hydrology.png',
    topics: 26303,
    members: '10万+',
    isJoined: false,
    description: '研究地球上水的分布、循环和运动规律'
  },
  {
    id: 'geology',
    name: '地质学',
    category: 'physical-geography',
    icon: '/channels/geology.png',
    topics: 3263,
    members: '48029',
    isJoined: false,
    description: '研究地球的物质组成、结构和演化历史'
  },
  {
    id: 'pedology',
    name: '土壤学',
    category: 'physical-geography',
    icon: '/channels/pedology.png',
    topics: 39653,
    members: '10万+',
    isJoined: false,
    description: '研究土壤的形成、性质和分布规律'
  },
  {
    id: 'climatology',
    name: '气候学',
    category: 'physical-geography',
    icon: '/channels/climatology.png',
    topics: 18542,
    members: '75632',
    isJoined: true,
    description: '研究气候的形成、变化和分布规律'
  },
  {
    id: 'urban-planning',
    name: '城市规划',
    category: 'human-geography',
    icon: '/channels/urban-planning.png',
    topics: 12845,
    members: '52341',
    isJoined: false,
    description: '研究城市空间布局和规划管理'
  },
  {
    id: 'economic-geography',
    name: '经济地理',
    category: 'human-geography',
    icon: '/channels/economic-geography.png',
    topics: 9876,
    members: '41256',
    isJoined: false,
    description: '研究经济活动的地理分布和空间组织'
  },
  {
    id: 'gis-technology',
    name: 'GIS技术',
    category: 'geographic-info',
    icon: '/channels/gis-technology.png',
    topics: 15678,
    members: '67890',
    isJoined: true,
    description: '地理信息系统技术应用与开发'
  },
  {
    id: 'remote-sensing',
    name: '遥感技术',
    category: 'geographic-info',
    icon: '/channels/remote-sensing.png',
    topics: 11234,
    members: '45678',
    isJoined: false,
    description: '遥感技术在地理研究中的应用'
  },
  {
    id: 'geography-qa',
    name: '地理问答',
    category: 'qa-square',
    icon: '/channels/geography-qa.png',
    topics: 45678,
    members: '10万+',
    isJoined: true,
    description: '地理知识问答与讨论'
  },
  {
    id: 'study-help',
    name: '学习互助',
    category: 'qa-square',
    icon: '/channels/study-help.png',
    topics: 23456,
    members: '78901',
    isJoined: false,
    description: '地理学习经验分享与互助'
  }
])

// 计算属性
const filteredChannels = computed(() => {
  let result = channels.value.filter(channel => 
    channel.category === selectedCategory.value
  )

  if (searchQuery.value) {
    result = result.filter(channel => 
      channel.name.includes(searchQuery.value) ||
      channel.description.includes(searchQuery.value)
    )
  }

  if (showRecommended.value) {
    // 推荐逻辑：按话题数和成员数排序
    result = result.sort((a, b) => {
      const aTopics = typeof a.topics === 'number' ? a.topics : parseInt(a.topics.toString().replace(/[^\d]/g, ''))
      const bTopics = typeof b.topics === 'number' ? b.topics : parseInt(b.topics.toString().replace(/[^\d]/g, ''))
      return bTopics - aTopics
    })
  }

  return result
})

// 方法
function selectCategory(categoryId: string) {
  selectedCategory.value = categoryId
  searchQuery.value = ''
}

function handleSearch() {
  // 搜索逻辑已在计算属性中处理
}

function toggleRecommend() {
  showRecommended.value = !showRecommended.value
}

function toggleJoin(channel: any) {
  channel.isJoined = !channel.isJoined
  
  // 保存到本地存储
  const joinedChannels = JSON.parse(localStorage.getItem('joinedChannels') || '[]')
  if (channel.isJoined) {
    if (!joinedChannels.includes(channel.id)) {
      joinedChannels.push(channel.id)
    }
  } else {
    const index = joinedChannels.indexOf(channel.id)
    if (index > -1) {
      joinedChannels.splice(index, 1)
    }
  }
  localStorage.setItem('joinedChannels', JSON.stringify(joinedChannels))
  
  // 显示提示
  const message = channel.isJoined ? `已加入${channel.name}频道` : `已退出${channel.name}频道`
  console.log(message) // 可以替换为实际的提示组件
}

function viewChannel(channel: any) {
  // 跳转到频道详情页面
  console.log('查看频道:', channel.name)
  // 这里可以添加路由跳转逻辑
}

function goBack() {
  // 返回上一页
  window.history.back()
}

// 初始化
onMounted(() => {
  // 加载已加入的频道
  const joinedChannels = JSON.parse(localStorage.getItem('joinedChannels') || '[]')
  channels.value.forEach(channel => {
    channel.isJoined = joinedChannels.includes(channel.id)
  })
})
</script>

<style scoped lang="scss">
.channel-square {
  min-height: 100vh;
  background: white;
}

// 顶部导航
.channel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-base);
  border-bottom: 1px solid var(--color-border);
  background: white;
  position: sticky;
  top: 0;
  z-index: 100;

  .header-left {
    display: flex;
    align-items: center;
    gap: var(--spacing-base);

    h1 {
      font-size: 1.5rem;
      font-weight: 600;
      color: var(--color-text-primary);
      margin: 0;
    }
  }

  .header-right {
    .btn-text {
      color: var(--color-primary);
      font-weight: 500;

      span.active {
        color: var(--color-primary);
        font-weight: 600;
      }
    }
  }
}

// 搜索栏
.search-section {
  padding: var(--spacing-base);
  background: white;
  border-bottom: 1px solid var(--color-border);
}

.search-bar {
  position: relative;
  display: flex;
  align-items: center;
  background: #f5f5f5;
  border-radius: 20px;
  padding: var(--spacing-small) var(--spacing-base);

  .search-icon {
    color: var(--color-text-secondary);
    margin-right: var(--spacing-small);
  }

  input {
    flex: 1;
    border: none;
    background: transparent;
    outline: none;
    font-size: 1rem;
    color: var(--color-text-primary);

    &::placeholder {
      color: var(--color-text-secondary);
    }
  }
}

// 主要内容区域
.main-content {
  display: flex;
  min-height: calc(100vh - 140px);
}

// 左侧分类
.category-sidebar {
  width: 120px;
  background: #f8f9fa;
  border-right: 1px solid var(--color-border);
  flex-shrink: 0;
}

.category-list {
  padding: var(--spacing-base) 0;
}

.category-item {
  display: flex;
  align-items: center;
  padding: var(--spacing-base);
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;

  &:hover {
    background: rgba(102, 126, 234, 0.1);
  }

  &.active {
    background: rgba(102, 126, 234, 0.1);
    font-weight: 600;

    .category-name {
      color: var(--color-primary);
    }
  }

  .category-indicator {
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    width: 3px;
    background: var(--color-primary);
  }

  .category-arrow {
    font-size: 1rem;
    color: var(--color-text-secondary);
    margin-right: var(--spacing-small);
  }

  .category-name {
    font-size: 0.9rem;
    color: var(--color-text-primary);
    white-space: nowrap;
  }
}

// 右侧频道内容
.channel-content {
  flex: 1;
  padding: var(--spacing-base);
  background: white;
}

.channel-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);
}

.channel-item {
  display: flex;
  align-items: center;
  padding: var(--spacing-base);
  border-radius: var(--radius-base);
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    background: #f8f9fa;
  }
}

.channel-icon {
  width: 50px;
  height: 50px;
  margin-right: var(--spacing-base);
  flex-shrink: 0;

  img {
    width: 100%;
    height: 100%;
    border-radius: 50%;
    object-fit: cover;
    background: #f0f0f0;
  }
}

.channel-info {
  flex: 1;
  min-width: 0;

  .channel-name {
    font-size: 1.1rem;
    font-weight: 500;
    color: var(--color-text-primary);
    margin: 0 0 var(--spacing-small);
  }

  .channel-stats {
    font-size: 0.9rem;
    color: var(--color-text-secondary);
    margin: 0;
  }
}

.channel-action {
  flex-shrink: 0;
}

.join-btn {
  padding: var(--spacing-small) var(--spacing-base);
  border: 1px solid var(--color-border);
  border-radius: 16px;
  background: white;
  color: var(--color-text-secondary);
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    border-color: var(--color-primary);
    color: var(--color-primary);
  }

  &.joined {
    background: var(--color-primary);
    color: white;
    border-color: var(--color-primary);

    &:hover {
      background: var(--color-primary-dark);
    }
  }
}

// 空状态
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: var(--spacing-large);
  color: var(--color-text-secondary);

  .material-icons {
    font-size: 3rem;
    margin-bottom: var(--spacing-base);
    opacity: 0.5;
  }

  p {
    margin: 0;
    font-size: 1.1rem;
  }
}

// 响应式设计
@media (max-width: 768px) {
  .main-content {
    flex-direction: column;
  }

  .category-sidebar {
    width: 100%;
    border-right: none;
    border-bottom: 1px solid var(--color-border);
  }

  .category-list {
    display: flex;
    overflow-x: auto;
    padding: var(--spacing-small) 0;

    .category-item {
      flex-shrink: 0;
      padding: var(--spacing-small) var(--spacing-base);
      white-space: nowrap;
    }
  }

  .channel-content {
    padding: var(--spacing-small);
  }

  .channel-item {
    padding: var(--spacing-small);
  }

  .channel-icon {
    width: 40px;
    height: 40px;
  }
}

// 适配大字体模式
:global(.large-text) {
  .channel-header h1 {
    font-size: 1.6rem;
  }

  .channel-name {
    font-size: 1.2rem;
  }

  .channel-stats {
    font-size: 1rem;
  }
}

:global(.xlarge-text) {
  .channel-header h1 {
    font-size: 1.7rem;
  }

  .channel-name {
    font-size: 1.3rem;
  }

  .channel-stats {
    font-size: 1.1rem;
  }
}
</style>
