<template>
  <div class="quiz-page">
    <!-- 开始页面 -->
    <div v-if="!started" class="start-screen">
      <div class="quiz-info card">
        <h2>预习检测</h2>
        <div class="chapter-info">
          <span class="tag">{{ currentChapter }}</span>
          <span class="tag">共{{ totalQuestions }}题</span>
          <span class="tag">建议用时：{{ suggestedTime }}分钟</span>
        </div>
        
        <!-- 模式选择 -->
        <div class="mode-selection">
          <h3>请选择检测模式</h3>
          <div class="mode-options">
            <div 
              class="mode-card"
              :class="{ selected: selectedMode === 'personalized' }"
              @click="selectMode('personalized')"
            >
              <div class="mode-icon">
                <span class="material-icons">person</span>
              </div>
              <div class="mode-content">
                <h4>个性化模式</h4>
                <p>系统会迅速调取其历史学习数据，根据你的学习情况智能组题</p>
                <div class="mode-features">
                  <div class="feature-item">
                    <span class="material-icons">analytics</span>
                    <span>基于历史正确率分析</span>
                  </div>
                  <div class="feature-item">
                    <span class="material-icons">tune</span>
                    <span>基础题60%+进阶题40%</span>
                  </div>
                </div>
              </div>
            </div>

            <div 
              class="mode-card"
              :class="{ selected: selectedMode === 'standard' }"
              @click="selectMode('standard')"
            >
              <div class="mode-icon">
                <span class="material-icons">school</span>
              </div>
              <div class="mode-content">
                <h4>标准化模式</h4>
                <p>严格按照教材课标要求，均衡配置各类题型</p>
                <div class="mode-features">
                  <div class="feature-item">
                    <span class="material-icons">book</span>
                    <span>概念题40%+应用题30%+综合题30%</span>
                  </div>
                  <div class="feature-item">
                    <span class="material-icons">quiz</span>
                    <span>选择题60%+填空题20%+图文匹配题20%</span>
                  </div>
                  <div class="feature-item">
                    <span class="material-icons">assessment</span>
                    <span>全面检测知识掌握情况</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="description">
          <p>本次检测将帮助你了解对本章知识的掌握程度，请认真作答。</p>
          <ul>
            <li>题目类型：单选题、填空题、图文匹配题</li>
            <li>可以返回修改答案</li>
            <li>完成后查看详细解析</li>
            <li>系统自动批改并关联知识卡片</li>
          </ul>
        </div>
        <button 
          class="btn-primary start-btn" 
          :disabled="!selectedMode"
          @click="startQuiz"
        >
          <span class="material-icons">play_arrow</span>
          开始检测
        </button>
      </div>
    </div>

    <!-- 答题页面 -->
    <div v-else-if="!finished" class="quiz-content">
      <!-- 进度条 -->
      <div class="progress-bar">
        <div class="progress" :style="{ width: progress + '%' }"></div>
      </div>

      <!-- 题目信息 -->
      <div class="question-info">
        <span class="question-number">第 {{ currentIndex + 1 }}/{{ totalQuestions }} 题</span>
        <span class="question-type">{{ currentQuestion.type === 'choice' ? '单选题' : '填空题' }}</span>
      </div>

      <!-- 题目内容 -->
      <div class="question-content card">
        <div class="question-text">{{ currentQuestion.question }}</div>
        
        <!-- 选择题选项 -->
        <div v-if="currentQuestion.type === 'choice'" class="options">
          <button 
            v-for="option in currentQuestion.options" 
            :key="option.value"
            class="option-btn"
            :class="{ selected: currentQuestion.userAnswer === option.value }"
            @click="selectAnswer(option.value)"
          >
            <span class="option-label">{{ option.label }}</span>
            <span class="option-text">{{ option.text }}</span>
          </button>
        </div>

        <!-- 填空题输入框 -->
        <div v-else class="fill-input">
          <input 
            type="text"
            v-model="currentQuestion.userAnswer"
            :placeholder="'请输入答案'"
            @input="updateAnswer"
          >
        </div>
      </div>

      <!-- 导航按钮 -->
      <div class="navigation-buttons">
        <button 
          class="btn-text"
          :disabled="currentIndex === 0"
          @click="prevQuestion"
        >
          <span class="material-icons">arrow_back</span>
          上一题
        </button>

        <button 
          v-if="currentIndex < totalQuestions - 1"
          class="btn-primary"
          @click="nextQuestion"
        >
          下一题
          <span class="material-icons">arrow_forward</span>
        </button>

        <button 
          v-else
          class="btn-primary"
          @click="finishQuiz"
        >
          提交答案
          <span class="material-icons">check</span>
        </button>
      </div>
    </div>

    <!-- 结果页面 -->
    <div v-else class="result-screen">
      <div class="result-summary card">
        <h2>检测完成</h2>
        <div class="score-display">
          <div class="score">{{ score }}%</div>
          <div class="score-text">正确率</div>
        </div>

        <div class="stats">
          <div class="stat-item">
            <div class="stat-value">{{ correctCount }}</div>
            <div class="stat-label">答对题数</div>
          </div>
          <div class="stat-item">
            <div class="stat-value">{{ wrongCount }}</div>
            <div class="stat-label">答错题数</div>
          </div>
          <div class="stat-item">
            <div class="stat-value">{{ timeUsed }}分钟</div>
            <div class="stat-label">用时</div>
          </div>
        </div>

        <div class="weak-points">
          <h3>需要加强的知识点</h3>
          <div class="tags">
            <div 
              v-for="point in weakPoints" 
              :key="point.id"
              class="tag weak-point"
              @click="showKnowledgeCard(point)"
            >
              {{ point.name }}
            </div>
          </div>
        </div>

        <div class="action-buttons">
          <button class="btn-primary" @click="reviewAnswers">
            <span class="material-icons">article</span>
            查看解析
          </button>
          <button class="btn-text" @click="restartQuiz">
            <span class="material-icons">refresh</span>
            重新检测
          </button>
        </div>
      </div>

      <!-- 答案解析 -->
      <div v-if="showingReview" class="review-section">
        <div 
          v-for="(question, index) in questions" 
          :key="index"
          class="question-review card"
        >
          <div class="review-header">
            <span class="question-number">第 {{ index + 1 }} 题</span>
            <span 
              class="status"
              :class="{ correct: question.isCorrect, wrong: !question.isCorrect }"
            >
              {{ question.isCorrect ? '答对' : '答错' }}
            </span>
          </div>

          <div class="question-text">{{ question.question }}</div>

          <div v-if="question.type === 'choice'" class="review-options">
            <div 
              v-for="option in question.options" 
              :key="option.value"
              class="review-option"
              :class="{
                'user-answer': option.value === question.userAnswer,
                'correct-answer': option.value === question.answer
              }"
            >
              <span class="option-label">{{ option.label }}</span>
              <span class="option-text">{{ option.text }}</span>
            </div>
          </div>

          <div v-else class="review-fill">
            <div class="user-answer">
              你的答案：{{ question.userAnswer }}
            </div>
            <div class="correct-answer">
              正确答案：{{ question.answer }}
            </div>
          </div>

          <div class="explanation">
            <h4>解析</h4>
            <p>{{ question.explanation }}</p>
            <div class="related-knowledge">
              <span>相关知识点：</span>
              <div class="tags">
                <div 
                  v-for="point in question.knowledgePoints" 
                  :key="point.id"
                  class="tag"
                  @click="showKnowledgeCard(point)"
                >
                  {{ point.name }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 知识卡片弹窗 -->
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

// 状态
const started = ref(false)
const finished = ref(false)
const showingReview = ref(false)
const currentIndex = ref(0)
const startTime = ref(0)
const selectedPoint = ref<any>(null)

// 模式选择
const selectedMode = ref<'personalized' | 'standard' | null>(null)

// 模拟数据
const currentChapter = '第二章 大气环流'
const suggestedTime = 15

const questions = ref([
  {
    id: 'q1',
    type: 'choice',
    question: '下列哪项不是影响季风形成的主要因素？',
    options: [
      { value: 'A', label: 'A', text: '海陆温差' },
      { value: 'B', label: 'B', text: '地转偏向力' },
      { value: 'C', label: 'C', text: '地形地势' },
      { value: 'D', label: 'D', text: '洋流方向' }
    ],
    answer: 'D',
    userAnswer: '',
    explanation: '季风的形成主要受海陆温差、地转偏向力和地形地势的影响。洋流虽然会影响局部气候，但不是季风形成的主要因素。',
    knowledgePoints: [
      { id: 'k1', name: '季风成因', description: '季风是由于海陆温差形成的周期性风向交替变化现象。', page: 42 },
      { id: 'k2', name: '地转偏向力', description: '由地球自转产生的一种虚假力，使北半球的大气运动向右偏转。', page: 43 }
    ],
    isCorrect: false
  },
  {
    id: 'q2',
    type: 'fill',
    question: '夏季风从______吹向陆地，带来______天气。',
    answer: '海洋,温暖潮湿',
    userAnswer: '',
    explanation: '夏季，陆地增温快形成低压，海洋增温慢形成高压，风从海洋吹向陆地，带来温暖潮湿的天气。',
    knowledgePoints: [
      { id: 'k1', name: '季风成因', description: '季风是由于海陆温差形成的周期性风向交替变化现象。', page: 42 }
    ],
    isCorrect: false
  }
])

// 计算属性
const totalQuestions = computed(() => questions.value.length)
const currentQuestion = computed(() => questions.value[currentIndex.value])
const progress = computed(() => ((currentIndex.value + 1) / totalQuestions.value) * 100)

const correctCount = computed(() => questions.value.filter(q => q.isCorrect).length)
const wrongCount = computed(() => questions.value.filter(q => !q.isCorrect).length)
const score = computed(() => Math.round((correctCount.value / totalQuestions.value) * 100))
const timeUsed = computed(() => Math.round((Date.now() - startTime.value) / 60000))

const weakPoints = computed(() => {
  const points: any[] = []
  questions.value.forEach(q => {
    if (!q.isCorrect) {
      points.push(...q.knowledgePoints)
    }
  })
  return Array.from(new Set(points))
})

// 方法
function selectMode(mode: 'personalized' | 'standard') {
  selectedMode.value = mode
  // 根据选择的模式生成不同的题目
  generateQuestionsByMode(mode)
}

function generateQuestionsByMode(mode: 'personalized' | 'standard') {
  if (mode === 'personalized') {
    // 个性化模式：基于历史数据生成题目
    // 模拟：学生最近30天在某章节的正确率为65%，存在"图表分析"的能力短板
    questions.value = [
      {
        id: 'q1',
        type: 'choice',
        question: '下列哪项不是影响季风形成的主要因素？',
        options: [
          { value: 'A', label: 'A', text: '海陆温差' },
          { value: 'B', label: 'B', text: '地转偏向力' },
          { value: 'C', label: 'C', text: '地形地势' },
          { value: 'D', label: 'D', text: '洋流方向' }
        ],
        answer: 'D',
        userAnswer: '',
        explanation: '季风的形成主要受海陆温差、地转偏向力和地形地势的影响。洋流虽然会影响局部气候，但不是季风形成的主要因素。',
        knowledgePoints: [
          { id: 'k1', name: '季风成因', description: '季风是由于海陆温差形成的周期性风向交替变化现象。', page: 42 },
          { id: 'k2', name: '地转偏向力', description: '由地球自转产生的一种虚假力，使北半球的大气运动向右偏转。', page: 43 }
        ],
        isCorrect: false,
        difficulty: 'basic' // 基础题
      },
      {
        id: 'q2',
        type: 'choice',
        question: '根据下图分析，该地区的气候类型最可能是？',
        options: [
          { value: 'A', label: 'A', text: '热带雨林气候' },
          { value: 'B', label: 'B', text: '地中海气候' },
          { value: 'C', label: 'C', text: '温带海洋性气候' },
          { value: 'D', label: 'D', text: '亚热带季风气候' }
        ],
        answer: 'B',
        userAnswer: '',
        explanation: '从图表可以看出，该地区夏季高温少雨，冬季温和多雨，符合地中海气候的特征。',
        knowledgePoints: [
          { id: 'k3', name: '图表分析', description: '学会从气候图表中分析气候特征和类型。', page: 45 },
          { id: 'k4', name: '地中海气候', description: '夏季炎热干燥，冬季温和多雨的气候类型。', page: 46 }
        ],
        isCorrect: false,
        difficulty: 'advanced' // 进阶题，重点覆盖图表分析能力
      },
      {
        id: 'q3',
        type: 'fill',
        question: '夏季风从______吹向陆地，带来______天气。',
        answer: '海洋,温暖潮湿',
        userAnswer: '',
        explanation: '夏季，陆地增温快形成低压，海洋增温慢形成高压，风从海洋吹向陆地，带来温暖潮湿的天气。',
        knowledgePoints: [
          { id: 'k1', name: '季风成因', description: '季风是由于海陆温差形成的周期性风向交替变化现象。', page: 42 }
        ],
        isCorrect: false,
        difficulty: 'basic' // 基础题
      }
    ]
  } else {
    // 标准化模式：严格按照教材课标要求
    questions.value = [
      {
        id: 'q1',
        type: 'choice',
        question: '下列哪项不是影响季风形成的主要因素？',
        options: [
          { value: 'A', label: 'A', text: '海陆温差' },
          { value: 'B', label: 'B', text: '地转偏向力' },
          { value: 'C', label: 'C', text: '地形地势' },
          { value: 'D', label: 'D', text: '洋流方向' }
        ],
        answer: 'D',
        userAnswer: '',
        explanation: '季风的形成主要受海陆温差、地转偏向力和地形地势的影响。洋流虽然会影响局部气候，但不是季风形成的主要因素。',
        knowledgePoints: [
          { id: 'k1', name: '季风成因', description: '季风是由于海陆温差形成的周期性风向交替变化现象。', page: 42 },
          { id: 'k2', name: '地转偏向力', description: '由地球自转产生的一种虚假力，使北半球的大气运动向右偏转。', page: 43 }
        ],
        isCorrect: false,
        type: 'concept' // 概念题
      },
      {
        id: 'q2',
        type: 'choice',
        question: '某城市位于30°N，120°E，其气候特征最可能是？',
        options: [
          { value: 'A', label: 'A', text: '全年高温多雨' },
          { value: 'B', label: 'B', text: '夏季高温多雨，冬季温和少雨' },
          { value: 'C', label: 'C', text: '夏季炎热干燥，冬季温和多雨' },
          { value: 'D', label: 'D', text: '全年温和湿润' }
        ],
        answer: 'B',
        userAnswer: '',
        explanation: '该城市位于亚热带地区，受季风影响，夏季高温多雨，冬季温和少雨，属于亚热带季风气候。',
        knowledgePoints: [
          { id: 'k5', name: '亚热带季风气候', description: '亚热带季风气候的特征和分布。', page: 47 }
        ],
        isCorrect: false,
        type: 'application' // 应用题
      },
      {
        id: 'q3',
        type: 'match',
        question: '请将下列气候类型与其特征进行匹配：',
        options: [
          { value: 'A', label: 'A', text: '热带雨林气候' },
          { value: 'B', label: 'B', text: '地中海气候' },
          { value: 'C', label: 'C', text: '温带海洋性气候' }
        ],
        matches: [
          { value: '1', text: '全年高温多雨' },
          { value: '2', text: '夏季炎热干燥，冬季温和多雨' },
          { value: '3', text: '全年温和湿润' }
        ],
        answer: 'A1,B2,C3',
        userAnswer: '',
        explanation: '热带雨林气候全年高温多雨；地中海气候夏季炎热干燥，冬季温和多雨；温带海洋性气候全年温和湿润。',
        knowledgePoints: [
          { id: 'k6', name: '气候类型特征', description: '不同气候类型的特征对比。', page: 48 }
        ],
        isCorrect: false,
        type: 'comprehensive' // 综合题
      }
    ]
  }
}

function startQuiz() {
  started.value = true
  startTime.value = Date.now()
}

function selectAnswer(value: string) {
  currentQuestion.value.userAnswer = value
}

function updateAnswer(event: Event) {
  const input = event.target as HTMLInputElement
  currentQuestion.value.userAnswer = input.value
}

function prevQuestion() {
  if (currentIndex.value > 0) {
    currentIndex.value--
  }
}

function nextQuestion() {
  if (currentIndex.value < totalQuestions.value - 1) {
    currentIndex.value++
  }
}

function checkAnswers() {
  questions.value.forEach(q => {
    if (q.type === 'choice') {
      q.isCorrect = q.userAnswer === q.answer
    } else {
      q.isCorrect = q.userAnswer.trim() === q.answer
    }
  })
}

function finishQuiz() {
  checkAnswers()
  finished.value = true
}

function reviewAnswers() {
  showingReview.value = true
}

function restartQuiz() {
  // 重置所有状态
  questions.value.forEach(q => {
    q.userAnswer = ''
    q.isCorrect = false
  })
  currentIndex.value = 0
  started.value = false
  finished.value = false
  showingReview.value = false
  startTime.value = 0
}

function showKnowledgeCard(point: any) {
  selectedPoint.value = point
}
</script>

<style scoped lang="scss">
.quiz-page {
  padding: var(--spacing-base);
  padding-bottom: 60px;
}

.start-screen,
.result-screen {
  max-width: 600px;
  margin: 0 auto;
}

.quiz-info {
  text-align: center;
  padding: var(--spacing-large);

  h2 {
    margin-bottom: var(--spacing-base);
    font-size: 1.5em;
  }
}

.chapter-info {
  display: flex;
  justify-content: center;
  gap: var(--spacing-small);
  margin-bottom: var(--spacing-large);
}

.description {
  text-align: left;
  margin-bottom: var(--spacing-large);

  ul {
    padding-left: var(--spacing-large);
    color: var(--color-text-secondary);
  }
}

.start-btn {
  width: 100%;
  max-width: 200px;

  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
}

// 模式选择样式
.mode-selection {
  margin: var(--spacing-large) 0;

  h3 {
    text-align: center;
    margin-bottom: var(--spacing-base);
    color: var(--color-text-secondary);
  }
}

.mode-options {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--spacing-base);
  margin-bottom: var(--spacing-large);

  @media (max-width: 768px) {
    grid-template-columns: 1fr;
  }
}

.mode-card {
  border: 2px solid var(--color-border);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  cursor: pointer;
  transition: all 0.3s ease;
  background: white;

  &:hover {
    border-color: var(--color-primary);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  &.selected {
    border-color: var(--color-primary);
    background: #f0f8ff;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  .mode-icon {
    text-align: center;
    margin-bottom: var(--spacing-base);

    .material-icons {
      font-size: 32px;
      color: var(--color-primary);
    }
  }

  .mode-content {
    h4 {
      margin: 0 0 var(--spacing-small);
      text-align: center;
      color: var(--color-primary);
      font-size: 1.1em;
    }

    p {
      margin: 0 0 var(--spacing-base);
      text-align: center;
      color: var(--color-text-secondary);
      font-size: 0.9em;
      line-height: 1.4;
    }
  }
}

.mode-features {
  .feature-item {
    display: flex;
    align-items: center;
    gap: var(--spacing-small);
    margin-bottom: var(--spacing-small);
    font-size: 0.85em;
    color: var(--color-text-secondary);

    .material-icons {
      font-size: 16px;
      color: var(--color-primary);
    }
  }
}

.progress-bar {
  height: 4px;
  background: var(--color-border);
  margin-bottom: var(--spacing-base);
  border-radius: 2px;
  overflow: hidden;
}

.progress {
  height: 100%;
  background: var(--color-primary);
  transition: width 0.3s ease;
}

.question-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: var(--spacing-base);
  color: var(--color-text-secondary);
}

.question-content {
  margin-bottom: var(--spacing-large);
}

.question-text {
  font-size: 1.1em;
  margin-bottom: var(--spacing-large);
}

.options {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);
}

.option-btn {
  display: flex;
  align-items: center;
  padding: var(--spacing-base);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  background: white;
  cursor: pointer;
  transition: all 0.3s ease;
  min-height: 44px;
  text-align: left;

  &:hover {
    background: #f5f5f5;
  }

  &.selected {
    background: var(--color-primary);
    color: white;
    border-color: var(--color-primary);
  }

  .option-label {
    font-weight: 500;
    margin-right: var(--spacing-base);
  }
}

.fill-input {
  input {
    width: 100%;
    padding: var(--spacing-base);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    font-size: inherit;

    &:focus {
      outline: none;
      border-color: var(--color-primary);
    }
  }
}

.navigation-buttons {
  display: flex;
  justify-content: space-between;
  gap: var(--spacing-base);

  button {
    min-width: 120px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 4px;
  }
}

.result-summary {
  text-align: center;
  padding: var(--spacing-large);

  h2 {
    margin-bottom: var(--spacing-large);
  }
}

.score-display {
  margin-bottom: var(--spacing-large);

  .score {
    font-size: 3em;
    font-weight: bold;
    color: var(--color-primary);
  }

  .score-text {
    color: var(--color-text-secondary);
  }
}

.stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--spacing-base);
  margin-bottom: var(--spacing-large);
}

.stat-item {
  .stat-value {
    font-size: 1.5em;
    font-weight: 500;
  }

  .stat-label {
    color: var(--color-text-secondary);
    font-size: 0.9em;
  }
}

.weak-points {
  text-align: left;
  margin-bottom: var(--spacing-large);

  h3 {
    margin-bottom: var(--spacing-base);
    color: var(--color-text-secondary);
  }

  .tags {
    display: flex;
    flex-wrap: wrap;
    gap: var(--spacing-small);
  }

  .weak-point {
    cursor: pointer;
    background: #fff2f0;
    color: #ff4d4f;

    &:hover {
      background: #ffccc7;
    }
  }
}

.action-buttons {
  display: flex;
  gap: var(--spacing-base);
  justify-content: center;

  button {
    min-width: 120px;
  }
}

.review-section {
  margin-top: var(--spacing-large);
}

.question-review {
  margin-bottom: var(--spacing-base);
}

.review-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: var(--spacing-base);

  .status {
    &.correct {
      color: var(--color-success);
    }

    &.wrong {
      color: var(--color-error);
    }
  }
}

.review-options {
  .review-option {
    padding: var(--spacing-base);
    margin-bottom: var(--spacing-small);
    border-radius: var(--radius-base);
    display: flex;
    align-items: center;

    &.user-answer {
      background: #fff2f0;
    }

    &.correct-answer {
      background: #f6ffed;
    }

    .option-label {
      margin-right: var(--spacing-base);
      font-weight: 500;
    }
  }
}

.review-fill {
  margin: var(--spacing-base) 0;

  .user-answer,
  .correct-answer {
    padding: var(--spacing-small) var(--spacing-base);
    border-radius: var(--radius-base);
  }

  .user-answer {
    background: #fff2f0;
    margin-bottom: var(--spacing-small);
  }

  .correct-answer {
    background: #f6ffed;
  }
}

.explanation {
  margin-top: var(--spacing-base);
  padding-top: var(--spacing-base);
  border-top: 1px solid var(--color-border);

  h4 {
    margin-bottom: var(--spacing-small);
    color: var(--color-text-secondary);
  }

  .related-knowledge {
    margin-top: var(--spacing-base);
    display: flex;
    align-items: center;
    gap: var(--spacing-base);

    .tags {
      display: flex;
      gap: var(--spacing-small);
    }

    .tag {
      cursor: pointer;

      &:hover {
        background: var(--color-primary);
        color: white;
      }
    }
  }
}

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

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--spacing-base);

    h3 {
      margin: 0;
    }
  }

  .textbook-ref {
    margin-top: var(--spacing-base);
    color: var(--color-text-secondary);
  }
}

// 适配大字体模式
:global(.large-text) {
  .question-text {
    font-size: 1.2em;
  }

  .option-text {
    font-size: 1.1em;
  }
}

:global(.xlarge-text) {
  .question-text {
    font-size: 1.3em;
  }

  .option-text {
    font-size: 1.2em;
  }
}
</style>