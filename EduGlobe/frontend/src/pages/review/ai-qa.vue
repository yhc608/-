<template>
  <div class="ai-qa">
    <!-- 错题拍照识别 -->
    <div class="photo-recognition card">
      <div class="section-header">
        <h3>错题拍照识别</h3>
        <div class="actions">
          <button class="btn-text" @click="openCamera">
            <span class="material-icons">camera_alt</span>
            拍照
          </button>
          <button class="btn-text" @click="openGallery">
            <span class="material-icons">photo_library</span>
            相册
          </button>
        </div>
      </div>

      <!-- 图片预览 -->
      <div v-if="imagePreview" class="image-preview">
        <img :src="imagePreview" alt="错题图片">
        <div class="preview-overlay">
          <div v-if="isAnalyzing" class="analyzing">
            <div class="spinner"></div>
            <p>正在分析...</p>
          </div>
          <div v-else class="preview-actions">
            <button class="btn-text" @click="retakePhoto">
              <span class="material-icons">refresh</span>
              重新拍照
            </button>
            <button class="btn-primary" @click="analyzeImage">
              <span class="material-icons">auto_fix_high</span>
              开始分析
            </button>
          </div>
        </div>
      </div>

      <!-- 上传提示 -->
      <div v-else class="upload-hint">
        <span class="material-icons">add_a_photo</span>
        <p>拍摄或上传错题图片</p>
        <p class="sub-hint">支持教材习题、试卷、笔记本等</p>
      </div>
    </div>

    <!-- 分析结果 -->
    <div v-if="analysisResult" class="analysis-result card">
      <div class="section-header">
        <h3>分析结果</h3>
        <button class="btn-text" @click="saveToHistory">
          <span class="material-icons">bookmark</span>
          保存到错题本
        </button>
      </div>

      <!-- 题目内容 -->
      <div class="question-content">
        <h4>题目内容</h4>
        <p>{{ analysisResult.question }}</p>
        <div class="tags">
          <span class="tag">{{ analysisResult.subject }}</span>
          <span class="tag">{{ analysisResult.chapter }}</span>
        </div>
      </div>

      <!-- 错误分析 -->
      <div class="error-analysis">
        <h4>错误分析</h4>
        <div class="analysis-points">
          <div 
            v-for="point in analysisResult.errorPoints" 
            :key="point.id"
            class="analysis-point"
          >
            <div class="point-header">
              <span class="point-type">{{ point.type }}</span>
              <span class="point-level" :class="point.level">{{ point.level }}</span>
            </div>
            <p class="point-desc">{{ point.description }}</p>
          </div>
        </div>
      </div>

      <!-- 知识点关联 -->
      <div class="knowledge-points">
        <h4>相关知识点</h4>
        <div class="points">
          <button 
            v-for="point in analysisResult.knowledgePoints" 
            :key="point.id"
            class="point-btn"
            @click="showKnowledgePoint(point)"
          >
            {{ point.name }}
            <span class="page-ref">P{{ point.page }}</span>
          </button>
        </div>
      </div>

      <!-- 推荐练习 -->
      <div class="recommended-practice">
        <h4>推荐练习</h4>
        <div class="practice-list">
          <div 
            v-for="practice in analysisResult.recommendedPractice" 
            :key="practice.id"
            class="practice-item"
            @click="startPractice(practice)"
          >
            <div class="practice-info">
              <div class="practice-title">{{ practice.title }}</div>
              <div class="practice-meta">
                <span class="count">{{ practice.questionCount }}题</span>
                <span class="time">约{{ practice.estimatedTime }}分钟</span>
              </div>
            </div>
            <span class="material-icons">chevron_right</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 错题本管理 -->
    <div class="wrong-questions-notebook card">
      <div class="section-header">
        <h3>错题本</h3>
        <div class="actions">
          <button class="btn-text" @click="showReviewReminder = true">
            <span class="material-icons">alarm</span>
            提醒
          </button>
          <button class="btn-text" @click="showFilterModal = true">
            <span class="material-icons">filter_list</span>
            筛选
          </button>
          <button class="btn-text" @click="showSortModal = true">
            <span class="material-icons">sort</span>
            排序
          </button>
        </div>
      </div>

      <!-- 筛选和排序栏 -->
      <div class="filter-bar">
        <div class="filter-chips">
          <button 
            v-for="chapter in chapters" 
            :key="chapter.id"
            class="filter-chip"
            :class="{ active: selectedChapter === chapter.id }"
            @click="filterByChapter(chapter.id)"
          >
            {{ chapter.name }}
          </button>
        </div>
        <div class="difficulty-filter">
          <span class="filter-label">难度：</span>
          <div class="star-filter">
            <button 
              v-for="level in [1,2,3,4,5]" 
              :key="level"
              class="star-btn"
              :class="{ active: selectedDifficulty >= level }"
              @click="filterByDifficulty(level)"
            >
              <span class="material-icons">star</span>
            </button>
          </div>
        </div>
      </div>

      <!-- 错题列表 -->
      <div class="wrong-questions-list">
        <div 
          v-for="item in filteredHistory" 
          :key="item.id"
          class="wrong-question-item"
          @click="showQuestionDetail(item)"
        >
          <div class="question-preview">
            <img :src="item.image" alt="错题图片">
            <div class="difficulty-stars">
              <span 
                v-for="star in 5" 
                :key="star"
                class="star"
                :class="{ filled: star <= item.difficulty }"
              >
                ★
              </span>
            </div>
          </div>
          <div class="question-info">
            <div class="question-title">{{ item.question }}</div>
            <div class="question-meta">
              <span class="chapter-tag">{{ item.chapter }}</span>
              <span class="time">{{ formatTime(item.time) }}</span>
            </div>
            <div class="review-stats">
              <div class="stat-item">
                <span class="material-icons">schedule</span>
                <span>复习{{ item.reviewCount }}次</span>
              </div>
              <div class="stat-item">
                <span class="material-icons">trending_up</span>
                <span>正确率{{ item.accuracy }}%</span>
              </div>
              <div class="stat-item" v-if="item.nextReviewTime">
                <span class="material-icons">alarm</span>
                <span>{{ formatNextReview(item.nextReviewTime) }}</span>
              </div>
            </div>
          </div>
          <div class="question-actions">
            <button class="action-btn" @click.stop="startReview(item)">
              <span class="material-icons">refresh</span>
            </button>
            <button class="action-btn" @click.stop="findSimilarQuestions(item)">
              <span class="material-icons">find_in_page</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 筛选模态框 -->
    <div v-if="showFilterModal" class="modal" @click.self="showFilterModal = false">
      <div class="modal-content">
        <div class="modal-header">
          <h3>筛选错题</h3>
          <button class="btn-icon" @click="showFilterModal = false">
            <span class="material-icons">close</span>
          </button>
        </div>
        <div class="modal-body">
          <div class="filter-section">
            <h4>章节筛选</h4>
            <div class="chapter-list">
              <label v-for="chapter in chapters" :key="chapter.id" class="checkbox-item">
                <input 
                  type="checkbox" 
                  :value="chapter.id" 
                  v-model="filterChapters"
                >
                <span>{{ chapter.name }}</span>
              </label>
            </div>
          </div>
          <div class="filter-section">
            <h4>难度筛选</h4>
            <div class="difficulty-range">
              <label>难度范围：{{ difficultyRange[0] }} - {{ difficultyRange[1] }}</label>
              <input 
                type="range" 
                min="1" 
                max="5" 
                step="1" 
                v-model="difficultyRange[0]"
                class="range-input"
              >
              <input 
                type="range" 
                min="1" 
                max="5" 
                step="1" 
                v-model="difficultyRange[1]"
                class="range-input"
              >
            </div>
          </div>
          <div class="filter-section">
            <h4>复习状态</h4>
            <div class="review-status">
              <label class="checkbox-item">
                <input type="checkbox" v-model="filterOptions.needReview">
                <span>需要复习</span>
              </label>
              <label class="checkbox-item">
                <input type="checkbox" v-model="filterOptions.reviewed">
                <span>已复习</span>
              </label>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-text" @click="resetFilters">重置</button>
          <button class="btn-primary" @click="applyFilters">应用筛选</button>
        </div>
      </div>
    </div>

    <!-- 排序模态框 -->
    <div v-if="showSortModal" class="modal" @click.self="showSortModal = false">
      <div class="modal-content">
        <div class="modal-header">
          <h3>排序方式</h3>
          <button class="btn-icon" @click="showSortModal = false">
            <span class="material-icons">close</span>
          </button>
        </div>
        <div class="modal-body">
          <div class="sort-options">
            <label v-for="option in sortOptions" :key="option.value" class="radio-item">
              <input 
                type="radio" 
                :value="option.value" 
                v-model="currentSort"
                name="sort"
              >
              <span>{{ option.label }}</span>
            </label>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-primary" @click="applySort">应用排序</button>
        </div>
      </div>
    </div>

    <!-- 同类题练习模态框 -->
    <div v-if="showSimilarPractice" class="modal" @click.self="showSimilarPractice = false">
      <div class="modal-content large">
        <div class="modal-header">
          <h3>同类题练习</h3>
          <button class="btn-icon" @click="showSimilarPractice = false">
            <span class="material-icons">close</span>
          </button>
        </div>
        <div class="modal-body">
          <div class="practice-info">
            <h4>基于题目：{{ currentPracticeQuestion?.question }}</h4>
            <div class="practice-meta">
              <span class="tag">{{ currentPracticeQuestion?.chapter }}</span>
              <span class="difficulty">难度：{{ currentPracticeQuestion?.difficulty }}星</span>
            </div>
          </div>
          <div class="similar-questions">
            <h4>相似题目</h4>
            <div class="question-list">
              <div 
                v-for="(question, index) in similarQuestions" 
                :key="question.id"
                class="practice-question-item"
              >
                <div class="question-number">{{ index + 1 }}</div>
                <div class="question-content">
                  <p>{{ question.content }}</p>
                  <div class="question-options" v-if="question.type === 'choice'">
                    <label v-for="option in question.options" :key="option.key" class="option-item">
                      <input 
                        type="radio" 
                        :name="`question_${question.id}`" 
                        :value="option.key"
                        v-model="questionAnswers[question.id]"
                      >
                      <span>{{ option.key }}. {{ option.text }}</span>
                    </label>
                  </div>
                  <div class="question-answer" v-if="question.type === 'text'">
                    <textarea 
                      v-model="questionAnswers[question.id]"
                      placeholder="请输入答案"
                      rows="3"
                    ></textarea>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-text" @click="showSimilarPractice = false">取消</button>
          <button class="btn-primary" @click="submitPractice">提交答案</button>
        </div>
      </div>
    </div>

    <!-- 复习提醒设置 -->
    <div v-if="showReviewReminder" class="modal" @click.self="showReviewReminder = false">
      <div class="modal-content">
        <div class="modal-header">
          <h3>复习提醒设置</h3>
          <button class="btn-icon" @click="showReviewReminder = false">
            <span class="material-icons">close</span>
          </button>
        </div>
        <div class="modal-body">
          <div class="reminder-settings">
            <div class="setting-item">
              <label>提醒频率</label>
              <select v-model="reminderSettings.frequency">
                <option value="daily">每天</option>
                <option value="weekly">每周</option>
                <option value="custom">自定义</option>
              </select>
            </div>
            <div class="setting-item" v-if="reminderSettings.frequency === 'custom'">
              <label>间隔天数</label>
              <input type="number" v-model="reminderSettings.interval" min="1" max="30">
            </div>
            <div class="setting-item">
              <label>提醒时间</label>
              <input type="time" v-model="reminderSettings.time">
            </div>
            <div class="setting-item">
              <label>
                <input type="checkbox" v-model="reminderSettings.enabled">
                启用复习提醒
              </label>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-primary" @click="saveReminderSettings">保存设置</button>
        </div>
      </div>
    </div>

    <!-- 知识点详情弹窗 -->
    <div v-if="selectedPoint" class="knowledge-modal" @click.self="selectedPoint = null">
      <div class="knowledge-card card">
        <div class="card-header">
          <h3>{{ selectedPoint.name }}</h3>
          <button class="btn-icon" @click="selectedPoint = null">
            <span class="material-icons">close</span>
          </button>
        </div>
        <div class="card-content">
          <p>{{ selectedPoint.description }}</p>
          <div class="textbook-ref">
            <span>教材对应：</span>
            <span class="tag">P{{ selectedPoint.page }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

// 状态
const imagePreview = ref('')
const isAnalyzing = ref(false)
const analysisResult = ref<any>(null)
const selectedPoint = ref<any>(null)

// 模态框状态
const showFilterModal = ref(false)
const showSortModal = ref(false)
const showSimilarPractice = ref(false)
const showReviewReminder = ref(false)

// 筛选和排序状态
const selectedChapter = ref('')
const selectedDifficulty = ref(0)
const filterChapters = ref<string[]>([])
const difficultyRange = ref([1, 5])
const filterOptions = ref({
  needReview: false,
  reviewed: false
})
const currentSort = ref('time')
const sortOptions = ref([
  { value: 'time', label: '按时间排序' },
  { value: 'difficulty', label: '按难度排序' },
  { value: 'chapter', label: '按章节排序' },
  { value: 'reviewCount', label: '按复习次数排序' },
  { value: 'accuracy', label: '按正确率排序' }
])

// 同类题练习状态
const currentPracticeQuestion = ref<any>(null)
const similarQuestions = ref<any[]>([])
const questionAnswers = ref<Record<string, string>>({})

// 复习提醒设置
const reminderSettings = ref({
  frequency: 'daily',
  interval: 1,
  time: '20:00',
  enabled: true
})

// 章节数据
const chapters = ref([
  { id: 'ch1', name: '地球运动' },
  { id: 'ch2', name: '大气环境' },
  { id: 'ch3', name: '水循环' },
  { id: 'ch4', name: '地质构造' },
  { id: 'ch5', name: '人口地理' },
  { id: 'ch6', name: '城市地理' },
  { id: 'ch7', name: '农业地理' },
  { id: 'ch8', name: '工业地理' }
])

// 错题历史数据（增强版）
const history = ref([
  {
    id: 'h1',
    image: '/demo/wrong-question.jpg',
    question: '计算地球上某点的太阳高度角，已知该地北纬35°，当日太阳直射北纬15°，求该地的太阳高度角。',
    subject: '自然地理',
    chapter: '地球运动',
    chapterId: 'ch1',
    difficulty: 4,
    time: Date.now() - 3600000,
    reviewCount: 2,
    accuracy: 75,
    nextReviewTime: Date.now() + 86400000, // 明天
    lastReviewTime: Date.now() - 172800000, // 2天前
    errorPoints: ['计算错误', '公式应用'],
    knowledgePoints: ['太阳高度角', '地球自转']
  },
  {
    id: 'h2',
    image: '/demo/wrong-question2.jpg',
    question: '分析季风环流的形成原因及其对气候的影响。',
    subject: '自然地理',
    chapter: '大气环境',
    chapterId: 'ch2',
    difficulty: 3,
    time: Date.now() - 7200000,
    reviewCount: 1,
    accuracy: 60,
    nextReviewTime: Date.now() + 259200000, // 3天后
    lastReviewTime: Date.now() - 259200000, // 3天前
    errorPoints: ['概念理解', '影响因素分析'],
    knowledgePoints: ['季风环流', '海陆热力差异']
  }
])

// 计算属性 - 筛选后的历史记录
const filteredHistory = computed(() => {
  let filtered = history.value

  // 按章节筛选
  if (selectedChapter.value) {
    filtered = filtered.filter(item => item.chapterId === selectedChapter.value)
  }

  // 按难度筛选
  if (selectedDifficulty.value > 0) {
    filtered = filtered.filter(item => item.difficulty >= selectedDifficulty.value)
  }

  // 按复习状态筛选
  if (filterOptions.value.needReview) {
    filtered = filtered.filter(item => item.nextReviewTime && item.nextReviewTime <= Date.now())
  }
  if (filterOptions.value.reviewed) {
    filtered = filtered.filter(item => item.reviewCount > 0)
  }

  // 排序
  filtered.sort((a, b) => {
    switch (currentSort.value) {
      case 'time':
        return b.time - a.time
      case 'difficulty':
        return b.difficulty - a.difficulty
      case 'chapter':
        return a.chapter.localeCompare(b.chapter)
      case 'reviewCount':
        return b.reviewCount - a.reviewCount
      case 'accuracy':
        return b.accuracy - a.accuracy
      default:
        return 0
    }
  })

  return filtered
})

// 模拟分析结果
const mockAnalysisResult = {
  question: '计算地球上某点的太阳高度角，已知该地北纬35°，当日太阳直射北纬15°，求该地的太阳高度角。',
  subject: '自然地理',
  chapter: '地球运动',
  difficulty: 4,
  errorPoints: [
    {
      id: 'e1',
      type: '计算错误',
      level: '严重',
      description: '没有正确使用太阳高度角计算公式：h = 90° - |纬度 - 太阳直射纬度|'
    }
  ],
  knowledgePoints: [
    {
      id: 'k1',
      name: '太阳高度角',
      description: '太阳光线与地面的夹角，是表示太阳位置高低的重要指标。',
      page: 25
    }
  ],
  recommendedPractice: [
    {
      id: 'p1',
      title: '太阳高度角计算专项练习',
      questionCount: 5,
      estimatedTime: 15
    }
  ]
}

// 方法
function openCamera() {
  // TODO: 实现相机功能
  imagePreview.value = '/demo/wrong-question.jpg'
}

function openGallery() {
  // TODO: 实现相册选择
  imagePreview.value = '/demo/wrong-question.jpg'
}

function retakePhoto() {
  imagePreview.value = ''
  analysisResult.value = null
}

function analyzeImage() {
  isAnalyzing.value = true
  setTimeout(() => {
    isAnalyzing.value = false
    analysisResult.value = mockAnalysisResult
  }, 1500)
}

function saveToHistory() {
  if (!analysisResult.value) return
  
  const newItem = {
    id: `h${Date.now()}`,
    image: imagePreview.value,
    question: analysisResult.value.question,
    subject: analysisResult.value.subject,
    chapter: analysisResult.value.chapter,
    chapterId: chapters.value.find(c => c.name === analysisResult.value.chapter)?.id || 'ch1',
    difficulty: analysisResult.value.difficulty || 3,
    time: Date.now(),
    reviewCount: 0,
    accuracy: 0,
    nextReviewTime: Date.now() + 86400000, // 明天
    lastReviewTime: null,
    errorPoints: analysisResult.value.errorPoints?.map((p: any) => p.type) || [],
    knowledgePoints: analysisResult.value.knowledgePoints?.map((p: any) => p.name) || []
  }
  
  history.value.unshift(newItem)
}

function showQuestionDetail(item: any) {
  imagePreview.value = item.image
  analysisResult.value = {
    ...mockAnalysisResult,
    question: item.question,
    chapter: item.chapter,
    difficulty: item.difficulty
  }
}

function clearHistory() {
  history.value = []
}

function showKnowledgePoint(point: any) {
  selectedPoint.value = point
}

function startPractice(practice: any) {
  router.push(`/review/practice/${practice.id}`)
}

// 筛选和排序方法
function filterByChapter(chapterId: string) {
  selectedChapter.value = selectedChapter.value === chapterId ? '' : chapterId
}

function filterByDifficulty(level: number) {
  selectedDifficulty.value = selectedDifficulty.value === level ? 0 : level
}

function resetFilters() {
  selectedChapter.value = ''
  selectedDifficulty.value = 0
  filterChapters.value = []
  difficultyRange.value = [1, 5]
  filterOptions.value = {
    needReview: false,
    reviewed: false
  }
}

function applyFilters() {
  showFilterModal.value = false
}

function applySort() {
  showSortModal.value = false
}

// 复习相关方法
function startReview(item: any) {
  // 更新复习次数和正确率
  item.reviewCount++
  item.lastReviewTime = Date.now()
  
  // 根据复习效果调整下次复习时间
  const baseInterval = 24 * 60 * 60 * 1000 // 1天
  const multiplier = Math.pow(2, item.reviewCount - 1) // 间隔递增
  item.nextReviewTime = Date.now() + (baseInterval * multiplier)
  
  // 模拟正确率提升
  item.accuracy = Math.min(100, item.accuracy + Math.floor(Math.random() * 20))
}

function formatNextReview(timestamp: number) {
  const now = Date.now()
  const diff = timestamp - now
  
  if (diff <= 0) return '需要复习'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟后`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时后`
  
  const days = Math.floor(diff / 86400000)
  return `${days}天后`
}

// 同类题练习方法
function findSimilarQuestions(item: any) {
  currentPracticeQuestion.value = item
  showSimilarPractice.value = true
  
  // 模拟相似题目
  similarQuestions.value = [
    {
      id: 'sq1',
      type: 'choice',
      content: '计算北纬40°某地夏至日的太阳高度角（太阳直射北纬23.5°）',
      options: [
        { key: 'A', text: '63.5°' },
        { key: 'B', text: '73.5°' },
        { key: 'C', text: '83.5°' },
        { key: 'D', text: '93.5°' }
      ],
      correctAnswer: 'B'
    },
    {
      id: 'sq2',
      type: 'text',
      content: '简述太阳高度角的变化规律及其影响因素。',
      correctAnswer: '太阳高度角随纬度和季节变化...'
    }
  ]
  
  // 初始化答案
  questionAnswers.value = {}
}

function submitPractice() {
  // 检查答案并计算得分
  let correctCount = 0
  similarQuestions.value.forEach(question => {
    const userAnswer = questionAnswers.value[question.id]
    if (userAnswer === question.correctAnswer) {
      correctCount++
    }
  })
  
  const score = Math.round((correctCount / similarQuestions.value.length) * 100)
  
  // 更新原题目的复习数据
  if (currentPracticeQuestion.value) {
    currentPracticeQuestion.value.reviewCount++
    currentPracticeQuestion.value.accuracy = Math.max(
      currentPracticeQuestion.value.accuracy,
      score
    )
  }
  
  // 显示结果
  alert(`练习完成！得分：${score}分`)
  showSimilarPractice.value = false
}

// 复习提醒方法
function saveReminderSettings() {
  // TODO: 保存到本地存储或后端
  localStorage.setItem('reviewReminderSettings', JSON.stringify(reminderSettings.value))
  showReviewReminder.value = false
  
  // 设置提醒
  if (reminderSettings.value.enabled) {
    scheduleReviewReminder()
  }
}

function scheduleReviewReminder() {
  // TODO: 实现定时提醒功能
  console.log('设置复习提醒:', reminderSettings.value)
}

function formatTime(timestamp: number) {
  const now = Date.now()
  const diff = now - timestamp
  
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
  
  const date = new Date(timestamp)
  return `${date.getMonth() + 1}月${date.getDate()}日`
}
</script>

<style scoped lang="scss">
.ai-qa {
  padding: var(--spacing-base);
  padding-bottom: 60px;
}

.card {
  margin-bottom: var(--spacing-base);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-base);

  h3 {
    margin: 0;
  }

  .actions {
    display: flex;
    gap: var(--spacing-small);
  }
}

// 图片上传区域
.image-preview {
  position: relative;
  border-radius: var(--radius-base);
  overflow: hidden;
  margin-bottom: var(--spacing-base);

  img {
    width: 100%;
    max-height: 300px;
    object-fit: contain;
  }
}

.preview-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}

.analyzing {
  text-align: center;
  color: white;

  .spinner {
    width: 40px;
    height: 40px;
    border: 3px solid rgba(255, 255, 255, 0.3);
    border-radius: 50%;
    border-top-color: white;
    animation: spin 1s linear infinite;
    margin: 0 auto var(--spacing-small);
  }
}

.preview-actions {
  display: flex;
  gap: var(--spacing-base);
}

.upload-hint {
  padding: var(--spacing-large);
  text-align: center;
  color: var(--color-text-secondary);
  border: 2px dashed var(--color-border);
  border-radius: var(--radius-base);

  .material-icons {
    font-size: 48px;
    margin-bottom: var(--spacing-small);
  }

  .sub-hint {
    font-size: 0.9em;
    margin: var(--spacing-small) 0 0;
  }
}

// 分析结果
.question-content {
  margin-bottom: var(--spacing-large);

  h4 {
    color: var(--color-text-secondary);
    margin-bottom: var(--spacing-small);
  }

  p {
    margin: 0 0 var(--spacing-small);
    line-height: 1.6;
  }

  .tags {
    display: flex;
    gap: var(--spacing-small);
  }
}

.analysis-points {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);
}

.analysis-point {
  background: #f9f9f9;
  padding: var(--spacing-base);
  border-radius: var(--radius-base);

  .point-header {
    display: flex;
    align-items: center;
    gap: var(--spacing-base);
    margin-bottom: var(--spacing-small);
  }

  .point-type {
    font-weight: 500;
  }

  .point-level {
    padding: 2px var(--spacing-small);
    border-radius: 10px;
    font-size: 0.9em;

    &.严重 {
      background: #fff2f0;
      color: #ff4d4f;
    }

    &.中等 {
      background: #fff7e6;
      color: #faad14;
    }

    &.轻微 {
      background: #f6ffed;
      color: #52c41a;
    }
  }

  .point-desc {
    margin: 0;
    color: var(--color-text-secondary);
  }
}

.knowledge-points {
  margin-bottom: var(--spacing-large);

  .points {
    display: flex;
    flex-wrap: wrap;
    gap: var(--spacing-small);
  }
}

.point-btn {
  padding: var(--spacing-small) var(--spacing-base);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  background: white;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: var(--spacing-small);

  &:hover {
    background: var(--color-primary);
    color: white;
    border-color: var(--color-primary);

    .page-ref {
      color: rgba(255, 255, 255, 0.8);
    }
  }

  .page-ref {
    color: var(--color-text-secondary);
    font-size: 0.9em;
  }
}

.practice-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-small);
}

.practice-item {
  display: flex;
  align-items: center;
  padding: var(--spacing-base);
  background: #f9f9f9;
  border-radius: var(--radius-base);
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    background: #f5f5f5;

    .material-icons {
      transform: translateX(4px);
    }
  }

  .practice-info {
    flex: 1;
  }

  .practice-title {
    margin-bottom: 4px;
  }

  .practice-meta {
    font-size: 0.9em;
    color: var(--color-text-secondary);
    display: flex;
    gap: var(--spacing-base);
  }

  .material-icons {
    color: var(--color-text-secondary);
    transition: transform 0.3s ease;
  }
}

// 错题本管理
.filter-bar {
  margin-bottom: var(--spacing-base);
  padding: var(--spacing-base);
  background: #f9f9f9;
  border-radius: var(--radius-base);

  .filter-chips {
    display: flex;
    flex-wrap: wrap;
    gap: var(--spacing-small);
    margin-bottom: var(--spacing-base);
  }

  .filter-chip {
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

    &:hover:not(.active) {
      background: #f5f5f5;
    }
  }

  .difficulty-filter {
    display: flex;
    align-items: center;
    gap: var(--spacing-small);

    .filter-label {
      font-size: 0.9em;
      color: var(--color-text-secondary);
    }

    .star-filter {
      display: flex;
      gap: 2px;
    }

    .star-btn {
      padding: 4px;
      border: none;
      background: none;
      cursor: pointer;
      transition: all 0.3s ease;

      .material-icons {
        font-size: 18px;
        color: #ddd;
        transition: color 0.3s ease;
      }

      &.active .material-icons {
        color: #ffd700;
      }

      &:hover .material-icons {
        color: #ffd700;
      }
    }
  }
}

.wrong-questions-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);
}

.wrong-question-item {
  display: flex;
  align-items: flex-start;
  gap: var(--spacing-base);
  padding: var(--spacing-base);
  background: #f9f9f9;
  border-radius: var(--radius-base);
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    background: #f5f5f5;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  .question-preview {
    position: relative;
    width: 80px;
    height: 80px;
    border-radius: var(--radius-small);
    overflow: hidden;
    flex-shrink: 0;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .difficulty-stars {
      position: absolute;
      top: 4px;
      right: 4px;
      background: rgba(0, 0, 0, 0.7);
      padding: 2px 4px;
      border-radius: 4px;
      display: flex;
      gap: 1px;

      .star {
        font-size: 10px;
        color: #ddd;

        &.filled {
          color: #ffd700;
        }
      }
    }
  }

  .question-info {
    flex: 1;
    min-width: 0;
  }

  .question-title {
    margin-bottom: var(--spacing-small);
    font-weight: 500;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  .question-meta {
    display: flex;
    align-items: center;
    gap: var(--spacing-base);
    margin-bottom: var(--spacing-small);
    font-size: 0.9em;
    color: var(--color-text-secondary);

    .chapter-tag {
      padding: 2px var(--spacing-small);
      background: var(--color-primary);
      color: white;
      border-radius: 10px;
      font-size: 0.8em;
    }
  }

  .review-stats {
    display: flex;
    flex-wrap: wrap;
    gap: var(--spacing-base);
    font-size: 0.8em;
    color: var(--color-text-secondary);

    .stat-item {
      display: flex;
      align-items: center;
      gap: 4px;

      .material-icons {
        font-size: 14px;
      }
    }
  }

  .question-actions {
    display: flex;
    flex-direction: column;
    gap: var(--spacing-small);

    .action-btn {
      width: 32px;
      height: 32px;
      border: none;
      background: white;
      border-radius: 50%;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: all 0.3s ease;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);

      &:hover {
        background: var(--color-primary);
        color: white;
        transform: scale(1.1);
      }

      .material-icons {
        font-size: 16px;
      }
    }
  }
}

// 动画
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

// 模态框
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

// 筛选模态框样式
.filter-section {
  margin-bottom: var(--spacing-large);

  h4 {
    margin: 0 0 var(--spacing-base);
    color: var(--color-text-secondary);
  }

  .chapter-list {
    display: flex;
    flex-direction: column;
    gap: var(--spacing-small);
  }

  .checkbox-item {
    display: flex;
    align-items: center;
    gap: var(--spacing-small);
    cursor: pointer;

    input[type="checkbox"] {
      margin: 0;
    }
  }

  .difficulty-range {
    display: flex;
    flex-direction: column;
    gap: var(--spacing-small);

    label {
      font-size: 0.9em;
      color: var(--color-text-secondary);
    }

    .range-input {
      width: 100%;
    }
  }

  .review-status {
    display: flex;
    flex-direction: column;
    gap: var(--spacing-small);
  }
}

// 排序模态框样式
.sort-options {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);

  .radio-item {
    display: flex;
    align-items: center;
    gap: var(--spacing-small);
    cursor: pointer;

    input[type="radio"] {
      margin: 0;
    }
  }
}

// 同类题练习样式
.practice-info {
  margin-bottom: var(--spacing-large);
  padding: var(--spacing-base);
  background: #f9f9f9;
  border-radius: var(--radius-base);

  h4 {
    margin: 0 0 var(--spacing-small);
  }

  .practice-meta {
    display: flex;
    gap: var(--spacing-base);
    font-size: 0.9em;
    color: var(--color-text-secondary);

    .tag {
      padding: 2px var(--spacing-small);
      background: var(--color-primary);
      color: white;
      border-radius: 10px;
      font-size: 0.8em;
    }

    .difficulty {
      color: var(--color-text-secondary);
    }
  }
}

.similar-questions {
  h4 {
    margin: 0 0 var(--spacing-base);
  }
}

.question-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);
}

.practice-question-item {
  display: flex;
  gap: var(--spacing-base);
  padding: var(--spacing-base);
  background: #f9f9f9;
  border-radius: var(--radius-base);

  .question-number {
    width: 24px;
    height: 24px;
    background: var(--color-primary);
    color: white;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.9em;
    font-weight: 500;
    flex-shrink: 0;
  }

  .question-content {
    flex: 1;

    p {
      margin: 0 0 var(--spacing-base);
      line-height: 1.6;
    }
  }

  .question-options {
    display: flex;
    flex-direction: column;
    gap: var(--spacing-small);

    .option-item {
      display: flex;
      align-items: center;
      gap: var(--spacing-small);
      cursor: pointer;

      input[type="radio"] {
        margin: 0;
      }
    }
  }

  .question-answer {
    textarea {
      width: 100%;
      padding: var(--spacing-small);
      border: 1px solid var(--color-border);
      border-radius: var(--radius-small);
      resize: vertical;
    }
  }
}

// 复习提醒设置样式
.reminder-settings {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);

  .setting-item {
    display: flex;
    flex-direction: column;
    gap: var(--spacing-small);

    label {
      font-weight: 500;
    }

    select, input {
      padding: var(--spacing-small);
      border: 1px solid var(--color-border);
      border-radius: var(--radius-small);
    }

    input[type="checkbox"] {
      margin-right: var(--spacing-small);
    }
  }
}

// 知识点详情弹窗
.knowledge-modal {
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

.knowledge-card {
  width: 90%;
  max-width: 480px;
  margin: 0;

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--spacing-base);

    h3 {
      margin: 0;
    }
  }

  .card-content {
    p {
      margin: 0 0 var(--spacing-base);
      line-height: 1.6;
    }

    .textbook-ref {
      color: var(--color-text-secondary);
    }
  }
}

// 适配大字体模式
:global(.large-text) {
  .question-content p {
    font-size: 1.1em;
  }

  .point-desc {
    font-size: 1.1em;
  }
}

:global(.xlarge-text) {
  .question-content p {
    font-size: 1.2em;
  }

  .point-desc {
    font-size: 1.2em;
  }
}
</style>
