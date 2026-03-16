<template>
  <div class="qa-page">
    <!-- 问题列表 -->
    <div class="questions-list" v-if="!showingAnswer">
      <!-- 快速提问按钮 -->
      <div class="quick-ask">
        <button class="btn-primary ask-btn" @click="startAsk">
          <span class="material-icons">add</span>
          提出问题
        </button>
        <button class="btn-text voice-btn" @click="startVoiceInput">
          <span class="material-icons">mic</span>
          语音提问
        </button>
      </div>

      <!-- 常见问题 -->
      <div class="common-questions card">
        <h3>常见问题</h3>
        <div class="question-tags">
          <button 
            v-for="q in commonQuestions" 
            :key="q.id"
            class="question-tag"
            @click="selectQuestion(q)"
          >
            {{ q.question }}
          </button>
        </div>
      </div>

      <!-- 历史问题 -->
      <div class="history-questions card">
        <div class="section-header">
          <h3>最近问题</h3>
          <button class="btn-text" @click="clearHistory" v-if="historyQuestions.length">
            <span class="material-icons">delete</span>
            清空历史
          </button>
        </div>
        <div class="questions">
          <div 
            v-for="q in historyQuestions" 
            :key="q.id"
            class="question-item"
            @click="selectQuestion(q)"
          >
            <div class="question-content">
              <div class="question-text">{{ q.question }}</div>
              <div class="question-meta">
                <span class="time">{{ formatTime(q.time) }}</span>
                <span class="tag">{{ q.category }}</span>
              </div>
            </div>
            <span class="material-icons">chevron_right</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 提问界面 -->
    <div v-else-if="isAsking" class="ask-interface">
      <div class="ask-header">
        <button class="btn-icon" @click="cancelAsk">
          <span class="material-icons">arrow_back</span>
        </button>
        <h2>提出问题</h2>
      </div>

      <div class="ask-content card">
        <!-- 文字输入 -->
        <div class="text-input">
          <textarea 
            v-model="questionText"
            placeholder="请输入你的问题..."
            rows="3"
            @keydown.enter.prevent="submitQuestion"
          ></textarea>
          <div class="input-actions">
            <button 
              class="btn-text"
              @click="questionText = ''"
              v-if="questionText"
            >
              <span class="material-icons">close</span>
              清空
            </button>
            <button 
              class="btn-primary"
              @click="submitQuestion"
              :disabled="!questionText.trim()"
            >
              提交问题
            </button>
          </div>
        </div>

        <!-- 图片上传 -->
        <div class="image-upload">
          <div class="upload-preview" v-if="imagePreview">
            <img :src="imagePreview" alt="问题图片">
            <button class="btn-icon remove-btn" @click="removeImage">
              <span class="material-icons">close</span>
            </button>
          </div>
          <button v-else class="upload-btn" @click="uploadImage">
            <span class="material-icons">add_photo_alternate</span>
            添加图片
          </button>
        </div>

        <!-- 问题建议 -->
        <div class="question-suggestions">
          <h3>你可能想问：</h3>
          <div class="suggestions">
            <button 
              v-for="suggestion in questionSuggestions" 
              :key="suggestion"
              class="suggestion-btn"
              @click="questionText = suggestion"
            >
              {{ suggestion }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 答案界面 -->
    <div v-else class="answer-interface">
      <div class="answer-header">
        <button class="btn-icon" @click="backToQuestions">
          <span class="material-icons">arrow_back</span>
        </button>
        <h2>问题解答</h2>
      </div>

      <div class="answer-content">
        <!-- 问题卡片 -->
        <div class="question-card card">
          <div class="question-text">{{ currentQuestion.question }}</div>
          <div class="question-meta">
            <span class="time">{{ formatTime(currentQuestion.time) }}</span>
            <span class="tag">{{ currentQuestion.category }}</span>
          </div>
        </div>

        <!-- 答案卡片 -->
        <div class="answer-card card">
          <div class="answer-section">
            <h3>简要回答</h3>
            <p>{{ currentQuestion.shortAnswer }}</p>
          </div>

          <div class="answer-section">
            <h3>详细解释</h3>
            <p>{{ currentQuestion.detailAnswer }}</p>
          </div>

          <!-- 教材对应 -->
          <div class="textbook-ref">
            <h3>教材对应</h3>
            <div class="refs">
              <div 
                v-for="ref in currentQuestion.textbookRefs" 
                :key="ref.id"
                class="ref-item"
              >
                <span class="tag">{{ ref.book }}</span>
                <span class="page">P{{ ref.page }}</span>
                <p class="content">{{ ref.content }}</p>
              </div>
            </div>
          </div>

          <!-- 相关知识点 -->
          <div class="related-points">
            <h3>相关知识点</h3>
            <div class="points">
              <button 
                v-for="point in currentQuestion.relatedPoints" 
                :key="point.id"
                class="point-btn"
                @click="showKnowledgePoint(point)"
              >
                {{ point.name }}
              </button>
            </div>
          </div>
        </div>

        <!-- 相似问题 -->
        <div class="similar-questions card">
          <h3>相关问题</h3>
          <div class="questions">
            <button 
              v-for="q in currentQuestion.similarQuestions" 
              :key="q.id"
              class="question-btn"
              @click="selectQuestion(q)"
            >
              {{ q.question }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 语音输入提示 -->
    <div v-if="isListening" class="voice-input-modal" @click="stopVoiceInput">
      <div class="voice-input-content">
        <div class="wave-animation"></div>
        <p>正在聆听...</p>
        <p class="hint">点击任意处停止</p>
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

// 状态
const showingAnswer = ref(false)
const isAsking = ref(false)
const isListening = ref(false)
const questionText = ref('')
const imagePreview = ref('')
const selectedPoint = ref<any>(null)
const currentQuestion = ref<any>(null)

// 模拟数据
const commonQuestions = [
  {
    id: 'q1',
    question: '为什么夏季风从海洋吹向陆地？',
    category: '气候',
    time: Date.now(),
    shortAnswer: '因为夏季陆地增温快，形成低压，而海洋增温慢，形成高压。',
    detailAnswer: '夏季时，由于太阳辐射强，陆地比海洋升温更快，导致陆地上形成低压，海洋上形成高压。根据空气从高压流向低压的原理，风就从海洋吹向陆地。这种风带来水汽，形成降水。',
    textbookRefs: [
      {
        id: 'ref1',
        book: '人教版必修一',
        page: 42,
        content: '季风环流的形成与海陆温差有关。'
      }
    ],
    relatedPoints: [
      {
        id: 'p1',
        name: '气压带',
        description: '全球气压带的分布规律及其季节性移动。',
        page: 43
      }
    ],
    similarQuestions: [
      {
        id: 'q2',
        question: '冬季风为什么从陆地吹向海洋？'
      }
    ]
  }
]

const historyQuestions = ref([
  {
    id: 'h1',
    question: '等高线间距越密集说明什么？',
    category: '地形',
    time: Date.now() - 3600000
  }
])

const questionSuggestions = [
  '这个概念在教材中的哪一页？',
  '为什么会形成这种现象？',
  '这个地理过程的主要影响因素是什么？'
]

// 方法
function startAsk() {
  isAsking.value = true
  showingAnswer.value = true
}

function cancelAsk() {
  isAsking.value = false
  showingAnswer.value = false
  questionText.value = ''
  imagePreview.value = ''
}

function submitQuestion() {
  if (!questionText.value.trim()) return
  
  // TODO: 提交问题到后端
  const newQuestion = {
    id: `h${Date.now()}`,
    question: questionText.value,
    category: '待分类',
    time: Date.now()
  }
  
  historyQuestions.value.unshift(newQuestion)
  selectQuestion(newQuestion)
}

function selectQuestion(question: any) {
  currentQuestion.value = {
    ...commonQuestions[0], // 临时使用模拟数据
    ...question
  }
  showingAnswer.value = true
  isAsking.value = false
}

function backToQuestions() {
  showingAnswer.value = false
  isAsking.value = false
  currentQuestion.value = null
}

function clearHistory() {
  historyQuestions.value = []
}

function startVoiceInput() {
  isListening.value = true
  // TODO: 实现语音识别
}

function stopVoiceInput() {
  isListening.value = false
}

function uploadImage() {
  // TODO: 实现图片上传
  imagePreview.value = '/demo-image.jpg'
}

function removeImage() {
  imagePreview.value = ''
}

function showKnowledgePoint(point: any) {
  selectedPoint.value = point
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
.qa-page {
  padding: var(--spacing-base);
  padding-bottom: 60px;
}

// 问题列表样式
.quick-ask {
  display: flex;
  gap: var(--spacing-base);
  margin-bottom: var(--spacing-base);
}

.ask-btn,
.voice-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--spacing-small);
  padding: var(--spacing-base);
  border-radius: var(--radius-base);
}

.common-questions,
.history-questions {
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
}

.question-tags {
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-small);
  margin-top: var(--spacing-base);
}

.question-tag {
  padding: var(--spacing-small) var(--spacing-base);
  background: #f5f5f5;
  border: none;
  border-radius: var(--radius-base);
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: left;

  &:hover {
    background: var(--color-primary);
    color: white;
  }
}

.question-item {
  display: flex;
  align-items: center;
  padding: var(--spacing-base) 0;
  border-bottom: 1px solid var(--color-border);
  cursor: pointer;

  &:last-child {
    border-bottom: none;
  }

  &:hover {
    .material-icons {
      transform: translateX(4px);
    }
  }

  .question-content {
    flex: 1;
  }

  .question-text {
    margin-bottom: 4px;
  }

  .question-meta {
    display: flex;
    align-items: center;
    gap: var(--spacing-small);
    font-size: 0.9em;
    color: var(--color-text-secondary);
  }

  .material-icons {
    color: var(--color-text-secondary);
    transition: transform 0.3s ease;
  }
}

// 提问界面样式
.ask-header,
.answer-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-base);
  margin-bottom: var(--spacing-base);

  h2 {
    margin: 0;
  }
}

.text-input {
  margin-bottom: var(--spacing-base);

  textarea {
    width: 100%;
    padding: var(--spacing-base);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    resize: none;
    font-size: inherit;
    font-family: inherit;

    &:focus {
      outline: none;
      border-color: var(--color-primary);
    }
  }
}

.input-actions {
  display: flex;
  justify-content: flex-end;
  gap: var(--spacing-base);
  margin-top: var(--spacing-small);
}

.image-upload {
  margin-bottom: var(--spacing-base);
}

.upload-preview {
  position: relative;
  border-radius: var(--radius-base);
  overflow: hidden;

  img {
    width: 100%;
    max-height: 200px;
    object-fit: cover;
  }

  .remove-btn {
    position: absolute;
    top: var(--spacing-small);
    right: var(--spacing-small);
    background: rgba(0, 0, 0, 0.5);
    color: white;
  }
}

.upload-btn {
  width: 100%;
  padding: var(--spacing-large);
  border: 2px dashed var(--color-border);
  border-radius: var(--radius-base);
  background: none;
  color: var(--color-text-secondary);
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    border-color: var(--color-primary);
    color: var(--color-primary);
  }

  .material-icons {
    font-size: 32px;
    margin-bottom: var(--spacing-small);
  }
}

.question-suggestions {
  h3 {
    color: var(--color-text-secondary);
    margin-bottom: var(--spacing-base);
  }
}

.suggestions {
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-small);
}

.suggestion-btn {
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

// 答案界面样式
.answer-content {
  .card {
    margin-bottom: var(--spacing-base);
  }
}

.question-card {
  .question-text {
    font-size: 1.2em;
    margin-bottom: var(--spacing-small);
  }

  .question-meta {
    display: flex;
    align-items: center;
    gap: var(--spacing-small);
    color: var(--color-text-secondary);
    font-size: 0.9em;
  }
}

.answer-section {
  margin-bottom: var(--spacing-large);

  h3 {
    color: var(--color-text-secondary);
    margin-bottom: var(--spacing-small);
  }

  p {
    margin: 0;
    line-height: 1.6;
  }
}

.textbook-ref {
  .refs {
    display: flex;
    flex-direction: column;
    gap: var(--spacing-base);
  }

  .ref-item {
    display: flex;
    align-items: center;
    gap: var(--spacing-small);
    flex-wrap: wrap;

    .page {
      color: var(--color-text-secondary);
    }

    .content {
      width: 100%;
      margin: var(--spacing-small) 0 0;
      color: var(--color-text-secondary);
      font-size: 0.9em;
    }
  }
}

.related-points {
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

  &:hover {
    background: var(--color-primary);
    color: white;
    border-color: var(--color-primary);
  }
}

.similar-questions {
  .questions {
    display: flex;
    flex-direction: column;
    gap: var(--spacing-small);
  }
}

.question-btn {
  padding: var(--spacing-base);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  background: white;
  cursor: pointer;
  text-align: left;
  transition: all 0.3s ease;

  &:hover {
    background: #f5f5f5;
  }
}

// 模态框样式
.voice-input-modal,
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

.voice-input-content {
  background: white;
  border-radius: var(--radius-large);
  padding: var(--spacing-large);
  text-align: center;

  .wave-animation {
    width: 100px;
    height: 100px;
    border-radius: 50%;
    background: var(--color-primary);
    margin: 0 auto var(--spacing-base);
    animation: wave 1.5s infinite ease-in-out;
  }

  .hint {
    color: var(--color-text-secondary);
    font-size: 0.9em;
    margin: var(--spacing-small) 0 0;
  }
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

@keyframes wave {
  0% {
    transform: scale(0.95);
    box-shadow: 0 0 0 0 rgba(74, 144, 226, 0.3);
  }
  70% {
    transform: scale(1);
    box-shadow: 0 0 0 30px rgba(74, 144, 226, 0);
  }
  100% {
    transform: scale(0.95);
    box-shadow: 0 0 0 0 rgba(74, 144, 226, 0);
  }
}

// 适配大字体模式
:global(.large-text) {
  .question-text {
    font-size: 1.3em;
  }

  .answer-section p {
    font-size: 1.1em;
  }
}

:global(.xlarge-text) {
  .question-text {
    font-size: 1.4em;
  }

  .answer-section p {
    font-size: 1.2em;
  }
}
</style>
