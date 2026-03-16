<template>
  <div class="cards-page">
    <!-- 搜索栏 -->
    <div class="search-bar">
      <div class="search-input">
        <span class="material-icons">search</span>
        <input 
          type="text" 
          v-model="searchQuery"
          placeholder="搜索概念（如：等高线）"
          @input="handleSearch"
        >
      </div>
      <button class="btn-text" @click="showFilter = true">
        <span class="material-icons">filter_list</span>
        筛选
      </button>
    </div>

    <!-- 章节选择器 -->
    <div class="chapter-selector" v-if="showFilter">
      <div class="selector-header">
        <h3>按章节筛选</h3>
        <button class="btn-text" @click="showFilter = false">
          <span class="material-icons">close</span>
        </button>
      </div>
      <div class="chapter-list">
        <button 
          v-for="chapter in chapters" 
          :key="chapter.id"
          class="chapter-btn"
          :class="{ active: selectedChapter === chapter.id }"
          @click="selectChapter(chapter.id)"
        >
          {{ chapter.title }}
        </button>
      </div>
    </div>

    <!-- 卡片列表 -->
    <div class="cards-container">
      <div 
        v-for="card in filteredCards" 
        :key="card.id"
        class="concept-card"
        :class="{ 'favorite': card.isFavorite }"
        @click="showCardDetail(card)"
      >
        <div class="card-header">
          <h3>{{ card.title }}</h3>
          <button 
            class="btn-icon favorite-btn"
            @click.stop="toggleFavorite(card)"
          >
            <span class="material-icons">
              {{ card.isFavorite ? 'star' : 'star_border' }}
            </span>
          </button>
        </div>
        <div class="card-tags">
          <span class="tag">{{ card.category }}</span>
          <span class="tag">P{{ card.page }}</span>
        </div>
        <p class="card-preview">{{ card.definition }}</p>
      </div>
    </div>

    <!-- 卡片详情弹窗 -->
    <div v-if="selectedCard" class="card-modal" @click.self="selectedCard = null">
      <div class="card-detail">
        <div class="detail-header">
          <h2>{{ selectedCard.title }}</h2>
          <button class="btn-icon" @click="selectedCard = null">
            <span class="material-icons">close</span>
          </button>
        </div>
        
        <div class="detail-content">
          <section>
            <h3>概念定义</h3>
            <p>{{ selectedCard.definition }}</p>
          </section>

          <section>
            <h3>教材对应</h3>
            <div class="textbook-ref">
              <span class="tag">{{ selectedCard.textbook }}</span>
              <span class="tag">P{{ selectedCard.page }}</span>
            </div>
          </section>

          <section>
            <h3>关联概念</h3>
            <div class="related-concepts">
              <button 
                v-for="concept in selectedCard.relatedConcepts"
                :key="concept.id"
                class="concept-btn"
                @click="showCardDetail(concept)"
              >
                {{ concept.title }}
              </button>
            </div>
          </section>

          <section>
            <h3>应用示例</h3>
            <div class="examples">
              <div 
                v-for="(example, index) in selectedCard.examples"
                :key="index"
                class="example-item"
              >
                <h4>示例 {{ index + 1 }}</h4>
                <p>{{ example.content }}</p>
                <div class="example-image" v-if="example.image">
                  <img :src="example.image" :alt="example.title">
                </div>
              </div>
            </div>
          </section>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

// 状态
const searchQuery = ref('')
const showFilter = ref(false)
const selectedChapter = ref('')
const selectedCard = ref<any>(null)

// 模拟数据
const chapters = [
  { id: 'c1', title: '第一章 地球与地图' },
  { id: 'c2', title: '第二章 大气环流' },
  { id: 'c3', title: '第三章 自然地理环境' }
]

const cards = ref([
  {
    id: 'card1',
    title: '等高线',
    category: '地图',
    textbook: '人教版必修一',
    page: 15,
    definition: '在地形图上表示地面上所有等高点的连线，用于表示地形起伏的变化。',
    isFavorite: false,
    relatedConcepts: [
      { id: 'card2', title: '地形剖面图' },
      { id: 'card3', title: '地形图' }
    ],
    examples: [
      {
        title: '等高线判读',
        content: '等高线越密集，地形坡度越大；等高线越稀疏，地形坡度越小。',
        image: '/examples/contour-line.png'
      }
    ],
    chapterId: 'c1'
  },
  {
    id: 'card2',
    title: '季风',
    category: '气候',
    textbook: '人教版必修一',
    page: 42,
    definition: '随季节变化而改变方向的风，主要由海陆温差造成。',
    isFavorite: true,
    relatedConcepts: [
      { id: 'card4', title: '气压带' },
      { id: 'card5', title: '风带' }
    ],
    examples: [
      {
        title: '东亚季风',
        content: '夏季风从海洋吹向陆地，带来温暖潮湿的天气；冬季风从陆地吹向海洋，带来寒冷干燥的天气。'
      }
    ],
    chapterId: 'c2'
  }
])

// 计算属性
const filteredCards = computed(() => {
  let result = cards.value

  // 章节筛选
  if (selectedChapter.value) {
    result = result.filter(card => card.chapterId === selectedChapter.value)
  }

  // 搜索筛选
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    result = result.filter(card => 
      card.title.toLowerCase().includes(query) ||
      card.definition.toLowerCase().includes(query)
    )
  }

  return result
})

// 方法
function handleSearch() {
  // 可以添加防抖逻辑
}

function selectChapter(chapterId: string) {
  selectedChapter.value = selectedChapter.value === chapterId ? '' : chapterId
}

function showCardDetail(card: any) {
  selectedCard.value = card
}

function toggleFavorite(card: any) {
  card.isFavorite = !card.isFavorite
  // TODO: 同步到本地存储
}
</script>

<style scoped lang="scss">
.cards-page {
  padding: var(--spacing-base);
  padding-bottom: 60px;
}

.search-bar {
  display: flex;
  gap: var(--spacing-base);
  margin-bottom: var(--spacing-base);
}

.search-input {
  flex: 1;
  display: flex;
  align-items: center;
  background: white;
  border-radius: var(--radius-base);
  padding: 0 var(--spacing-base);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

  input {
    flex: 1;
    border: none;
    padding: var(--spacing-base);
    font-size: inherit;
    
    &:focus {
      outline: none;
    }
  }

  .material-icons {
    color: var(--color-text-secondary);
  }
}

.chapter-selector {
  background: white;
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  margin-bottom: var(--spacing-base);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

  .selector-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--spacing-base);

    h3 {
      margin: 0;
      font-size: 1.1em;
    }
  }
}

.chapter-list {
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-small);
}

.chapter-btn {
  padding: var(--spacing-small) var(--spacing-base);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  background: white;
  cursor: pointer;
  transition: all 0.3s ease;

  &.active {
    background: var(--color-primary);
    color: white;
    border-color: var(--color-primary);
  }
}

.cards-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: var(--spacing-base);
}

.concept-card {
  background: white;
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  &.favorite {
    border: 2px solid var(--color-primary);
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: var(--spacing-small);

  h3 {
    margin: 0;
    font-size: 1.2em;
  }
}

.card-tags {
  display: flex;
  gap: var(--spacing-small);
  margin-bottom: var(--spacing-small);
}

.card-preview {
  color: var(--color-text-secondary);
  margin: 0;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.favorite-btn {
  color: #f8c51d;
}

.card-modal {
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
}

.card-detail {
  background: white;
  border-radius: var(--radius-large);
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
}

.detail-header {
  padding: var(--spacing-base);
  border-bottom: 1px solid var(--color-border);
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: sticky;
  top: 0;
  background: white;
  z-index: 1;

  h2 {
    margin: 0;
    font-size: 1.4em;
  }
}

.detail-content {
  padding: var(--spacing-base);

  section {
    margin-bottom: var(--spacing-large);

    h3 {
      color: var(--color-text-secondary);
      font-size: 1.1em;
      margin-bottom: var(--spacing-small);
    }
  }
}

.related-concepts {
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-small);
}

.concept-btn {
  padding: var(--spacing-small) var(--spacing-base);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  background: white;
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    background: var(--color-primary);
    color: white;
    border-color: var(--color-primary);
  }
}

.examples {
  .example-item {
    background: #f9f9f9;
    border-radius: var(--radius-base);
    padding: var(--spacing-base);
    margin-bottom: var(--spacing-base);

    h4 {
      margin: 0 0 var(--spacing-small);
      color: var(--color-text);
    }

    p {
      margin: 0;
    }
  }

  .example-image {
    margin-top: var(--spacing-base);
    
    img {
      max-width: 100%;
      border-radius: var(--radius-small);
    }
  }
}

// 适配大字体模式
:global(.large-text) {
  .concept-card h3 {
    font-size: 1.3em;
  }

  .card-preview {
    font-size: 1.1em;
  }
}

:global(.xlarge-text) {
  .concept-card h3 {
    font-size: 1.4em;
  }

  .card-preview {
    font-size: 1.2em;
  }
}
</style>