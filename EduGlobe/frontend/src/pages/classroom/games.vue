<template>
  <div class="games-page">
    <!-- 游戏列表 -->
    <div v-if="!currentGame" class="game-list">
      <div 
        v-for="game in games" 
        :key="game.id"
        class="game-card"
        @click="startGame(game)"
      >
        <div class="game-preview">
          <img :src="game.preview" :alt="game.title">
          <div class="game-tags">
            <span class="tag">{{ game.type }}</span>
            <span class="tag">{{ game.duration }}</span>
          </div>
        </div>
        <div class="game-info">
          <h3>{{ game.title }}</h3>
          <p class="description">{{ game.description }}</p>
          <div class="knowledge-points">
            <span class="label">相关知识点：</span>
            <div class="tags">
              <span 
                v-for="point in game.knowledgePoints" 
                :key="point.id"
                class="tag"
                :title="'教材第' + point.page + '页'"
              >
                {{ point.name }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 气候拼图游戏 -->
    <div v-else-if="currentGame.id === 'climate-puzzle'" class="climate-puzzle">
      <div class="game-header">
        <h2>{{ currentGame.title }}</h2>
        <div class="game-stats">
          <div class="stat">
            <span class="label">已用时间</span>
            <span class="value">{{ formatTime(timeUsed) }}</span>
          </div>
          <div class="stat">
            <span class="label">剩余步数</span>
            <span class="value">{{ movesLeft }}</span>
          </div>
          <div class="stat">
            <span class="label">得分</span>
            <span class="value">{{ score }}</span>
          </div>
        </div>
      </div>

      <div class="puzzle-container">
        <!-- 拼图区域 -->
        <div 
          class="puzzle-grid"
          :style="{ 
            gridTemplateColumns: `repeat(${gridSize}, 1fr)`,
            gridTemplateRows: `repeat(${gridSize}, 1fr)`
          }"
        >
          <div 
            v-for="(tile, index) in puzzleTiles" 
            :key="index"
            class="puzzle-tile"
            :class="{ 
              'empty': tile.isEmpty,
              'correct': tile.isCorrect
            }"
            :style="{ 
              backgroundImage: tile.isEmpty ? 'none' : `url(${currentGame.image})`,
              backgroundPosition: `${tile.x * -100}% ${tile.y * -100}%`
            }"
            @click="moveTile(index)"
          >
            <span v-if="showNumbers && !tile.isEmpty" class="tile-number">
              {{ tile.number }}
            </span>
          </div>
        </div>

        <!-- 控制按钮 -->
        <div class="puzzle-controls">
          <button class="btn-text" @click="toggleNumbers">
            {{ showNumbers ? '隐藏数字' : '显示数字' }}
          </button>
          <button class="btn-text" @click="showHint">
            查看提示
            <span class="hint-count">({{ hintCount }}/3)</span>
          </button>
          <button class="btn-primary" @click="restartGame">
            重新开始
          </button>
        </div>
      </div>

      <!-- 提示图片 -->
      <div v-if="showingHint" class="hint-modal" @click="hideHint">
        <div class="hint-content">
          <img :src="currentGame.image" alt="提示图">
          <p>点击任意处关闭</p>
        </div>
      </div>
    </div>

    <!-- 地理灯谜游戏 -->
    <div v-else-if="currentGame.id === 'geo-riddle'" class="geo-riddle">
      <div class="game-header">
        <h2>{{ currentGame.title }}</h2>
        <div class="game-stats">
          <div class="stat">
            <span class="label">当前得分</span>
            <span class="value">{{ score }}</span>
          </div>
          <div class="stat">
            <span class="label">剩余时间</span>
            <span class="value">{{ formatTime(timeLeft) }}</span>
          </div>
        </div>
      </div>

      <div class="riddle-container">
        <!-- 灯谜内容 -->
        <div class="riddle-content">
          <div class="riddle-text">
            <h3>谜面</h3>
            <p>{{ currentRiddle.question }}</p>
          </div>
          
          <div class="riddle-hint" v-if="showRiddleHint">
            <h3>提示</h3>
            <p>{{ currentRiddle.hint }}</p>
          </div>

          <!-- 答题区域 -->
          <div class="answer-area">
            <input 
              v-if="!currentRiddle.options"
              type="text"
              v-model="userAnswer"
              placeholder="请输入答案..."
              @keyup.enter="submitAnswer"
            >
            <div v-else class="options">
              <button 
                v-for="option in currentRiddle.options" 
                :key="option.value"
                class="option-btn"
                :class="{ selected: userAnswer === option.value }"
                @click="userAnswer = option.value"
              >
                {{ option.text }}
              </button>
            </div>
          </div>

          <div class="action-buttons">
            <button 
              class="btn-text"
              @click="showRiddleHint = true"
              v-if="!showRiddleHint"
            >
              显示提示
            </button>
            <button 
              class="btn-primary"
              @click="submitAnswer"
              :disabled="!userAnswer"
            >
              提交答案
            </button>
          </div>
        </div>

        <!-- 答案解析 -->
        <div v-if="showExplanation" class="explanation">
          <div class="result" :class="isCorrect ? 'correct' : 'wrong'">
            {{ isCorrect ? '回答正确！' : '回答错误' }}
          </div>
          <div class="correct-answer" v-if="!isCorrect">
            正确答案：{{ currentRiddle.answer }}
          </div>
          <div class="explanation-text">
            <h3>解析</h3>
            <p>{{ currentRiddle.explanation }}</p>
          </div>
          <button class="btn-primary" @click="nextRiddle">
            {{ hasNextRiddle ? '下一题' : '完成游戏' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 地理大富翁游戏 -->
    <div v-else-if="currentGame.id === 'geo-monopoly'" class="geo-monopoly">
      <div class="game-header">
        <h2>{{ currentGame.title }}</h2>
        <div class="game-stats">
          <div class="stat">
            <span class="label">当前位置</span>
            <span class="value">{{ monopolyBoard[currentPosition].name }}</span>
          </div>
          <div class="stat">
            <span class="label">资金</span>
            <span class="value">¥{{ playerMoney }}</span>
          </div>
          <div class="stat">
            <span class="label">得分</span>
            <span class="value">{{ score }}</span>
          </div>
        </div>
      </div>

      <div class="monopoly-container">
        <!-- 游戏棋盘 -->
        <div class="monopoly-board">
          <div 
            v-for="(cell, index) in monopolyBoard" 
            :key="index"
            class="board-cell"
            :class="{ 
              'current': index === currentPosition,
              'start': cell.type === 'start',
              'landmark': cell.type === 'landmark',
              'chance': cell.type === 'chance',
              'destiny': cell.type === 'destiny'
            }"
            :style="{ backgroundColor: cell.color }"
          >
            <div class="cell-content">
              <div class="cell-name">{{ cell.name }}</div>
              <div v-if="cell.type === 'landmark'" class="cell-price">
                ¥{{ cell.price }}
              </div>
            </div>
          </div>
        </div>

        <!-- 游戏控制 -->
        <div class="monopoly-controls">
          <button class="btn-primary" @click="rollDice">
            <span class="material-icons">casino</span>
            掷骰子
          </button>
          <button class="btn-text" @click="restartGame">
            重新开始
          </button>
        </div>
      </div>

      <!-- 答题模态框 -->
      <div v-if="showQuestionModal" class="question-modal" @click.self="closeQuestionModal">
        <div class="question-content">
          <div class="question-header">
            <h3>地理知识问答</h3>
            <button class="btn-icon" @click="closeQuestionModal">
              <span class="material-icons">close</span>
            </button>
          </div>
          <div class="question-body">
            <p class="question-text">{{ currentQuestion?.question }}</p>
            <div class="question-options">
              <button 
                v-for="option in currentQuestion?.options" 
                :key="option.value"
                class="option-btn"
                @click="answerQuestion(option.value)"
              >
                {{ option.value }}. {{ option.text }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 灾害应对模拟游戏 -->
    <div v-else-if="currentGame.id === 'disaster-simulation'" class="disaster-simulation">
      <div class="game-header">
        <h2>{{ currentGame.title }}</h2>
        <div class="game-stats">
          <div class="stat">
            <span class="label">当前场景</span>
            <span class="value">{{ scenarioIndex + 1 }}/{{ disasterScenarios.length }}</span>
          </div>
          <div class="stat">
            <span class="label">决策得分</span>
            <span class="value">{{ score }}</span>
          </div>
        </div>
      </div>

      <div class="simulation-container">
        <!-- 场景描述 -->
        <div class="scenario-info">
          <h3>{{ currentScenario?.title }}</h3>
          <p class="scenario-description">{{ currentScenario?.description }}</p>
          <div class="situation-box">
            <h4>当前情况</h4>
            <p>{{ currentScenario?.situation }}</p>
          </div>
        </div>

        <!-- 决策选项 -->
        <div class="decision-options">
          <h4>请选择你的应对方案：</h4>
          <div class="options-grid">
            <button 
              v-for="decision in currentScenario?.decisions" 
              :key="decision.id"
              class="decision-btn"
              @click="makeDecision(decision)"
            >
              {{ decision.text }}
            </button>
          </div>
        </div>
      </div>

      <!-- 决策结果模态框 -->
      <div v-if="showDecisionModal" class="decision-modal" @click.self="closeDecisionModal">
        <div class="decision-content">
          <div class="decision-header">
            <h3>决策结果</h3>
            <button class="btn-icon" @click="closeDecisionModal">
              <span class="material-icons">close</span>
            </button>
          </div>
          <div class="decision-body">
            <div class="result-info">
              <div class="consequence">
                <h4>结果：</h4>
                <p>{{ decisionResult?.consequences }}</p>
              </div>
              <div class="explanation">
                <h4>解释：</h4>
                <p>{{ decisionResult?.explanation }}</p>
              </div>
              <div class="score-info">
                <span class="score-label">获得分数：</span>
                <span class="score-value">+{{ decisionResult?.score }}</span>
              </div>
            </div>
            <div class="decision-actions">
              <button 
                v-if="scenarioIndex < disasterScenarios.length - 1"
                class="btn-primary" 
                @click="nextScenario"
              >
                下一个场景
              </button>
              <button 
                v-else
                class="btn-primary" 
                @click="exitGame"
              >
                完成训练
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 返回按钮 -->
    <button 
      v-if="currentGame"
      class="btn-back"
      @click="exitGame"
    >
      <span class="material-icons">arrow_back</span>
      返回游戏列表
    </button>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'

// 状态
const currentGame = ref<any>(null)
const timeUsed = ref(0)
const timeLeft = ref(0)
const score = ref(0)
const movesLeft = ref(30)
const showNumbers = ref(true)
const showingHint = ref(false)
const hintCount = ref(3)
const gridSize = 3
const userAnswer = ref('')
const showRiddleHint = ref(false)
const showExplanation = ref(false)
const isCorrect = ref(false)
const currentRiddleIndex = ref(0)

// 地理大富翁游戏状态
const currentPosition = ref(0)
const playerMoney = ref(1000)
const currentQuestion = ref<any>(null)
const showQuestionModal = ref(false)
const questionAnswered = ref(false)

// 灾害应对模拟游戏状态
const currentScenario = ref<any>(null)
const scenarioIndex = ref(0)
const playerDecisions = ref<any[]>([])
const showDecisionModal = ref(false)
const decisionResult = ref<any>(null)

// 游戏数据
const games = [
  {
    id: 'climate-puzzle',
    title: '气候带拼图',
    type: '知识巩固',
    duration: '约5分钟',
    preview: '/games/climate-puzzle-preview.png',
    image: '/games/climate-map.png',
    description: '通过拼图形式学习全球气候带分布，了解各气候带的特征和分布规律。',
    knowledgePoints: [
      { id: 'k1', name: '气候带分布', page: 42 },
      { id: 'k2', name: '气压带', page: 43 }
    ]
  },
  {
    id: 'geo-riddle',
    title: '地理灯谜',
    type: '趣味学习',
    duration: '约3分钟',
    preview: '/games/geo-riddle-preview.png',
    description: '以灯谜形式复习地理知识，寓教于乐。',
    knowledgePoints: [
      { id: 'k3', name: '地形特征', page: 15 },
      { id: 'k4', name: '自然地理', page: 20 }
    ]
  },
  {
    id: 'geo-monopoly',
    title: '地理大富翁',
    type: '考点闯关',
    duration: '约10分钟',
    preview: '/games/geo-monopoly-preview.png',
    description: '通过大富翁游戏形式，在考点情境中闯关答题，巩固地理知识。',
    knowledgePoints: [
      { id: 'k5', name: '地形地貌', page: 25 },
      { id: 'k6', name: '气候类型', page: 30 },
      { id: 'k7', name: '人文地理', page: 35 }
    ]
  },
  {
    id: 'disaster-simulation',
    title: '灾害应对模拟',
    type: '决策训练',
    duration: '约8分钟',
    preview: '/games/disaster-simulation-preview.png',
    description: '在沉浸式灾害情境中进行决策训练，学习地理灾害的应对知识。',
    knowledgePoints: [
      { id: 'k8', name: '自然灾害', page: 50 },
      { id: 'k9', name: '防灾减灾', page: 52 },
      { id: 'k10', name: '应急管理', page: 55 }
    ]
  }
]

// 灯谜数据
const riddles = [
  {
    question: '春夏向北吹，秋冬向南归（打一地理名词）',
    answer: '季风',
    hint: '与风向的周期性变化有关',
    explanation: '季风是由于海陆温差形成的周期性风向交替变化现象。夏季风从海洋吹向陆地（向北），冬季风从陆地吹向海洋（向南）。',
    options: [
      { value: 'monsoon', text: '季风' },
      { value: 'trade_wind', text: '信风' },
      { value: 'westerly', text: '西风' }
    ]
  },
  {
    question: '山环水绕，云雾缭绕（打一地形）',
    answer: '盆地',
    hint: '四周高，中间低',
    explanation: '盆地是四周高、中间低的地形，常有河流流经，易形成云雾。',
    options: [
      { value: 'basin', text: '盆地' },
      { value: 'plain', text: '平原' },
      { value: 'plateau', text: '高原' }
    ]
  }
]

// 地理大富翁游戏数据
const monopolyBoard = [
  { position: 0, name: '起点', type: 'start', color: '#4CAF50' },
  { position: 1, name: '青藏高原', type: 'landmark', color: '#FF9800', price: 200, rent: 20 },
  { position: 2, name: '长江中下游平原', type: 'landmark', color: '#2196F3', price: 180, rent: 18 },
  { position: 3, name: '黄土高原', type: 'landmark', color: '#9C27B0', price: 160, rent: 16 },
  { position: 4, name: '东北平原', type: 'landmark', color: '#F44336', price: 140, rent: 14 },
  { position: 5, name: '机会', type: 'chance', color: '#FFC107' },
  { position: 6, name: '华北平原', type: 'landmark', color: '#00BCD4', price: 120, rent: 12 },
  { position: 7, name: '云贵高原', type: 'landmark', color: '#8BC34A', price: 100, rent: 10 },
  { position: 8, name: '命运', type: 'destiny', color: '#E91E63' },
  { position: 9, name: '塔里木盆地', type: 'landmark', color: '#795548', price: 80, rent: 8 }
]

const monopolyQuestions = [
  {
    id: 1,
    question: '青藏高原被称为"世界屋脊"，其平均海拔是多少？',
    options: [
      { value: 'A', text: '3000米以上' },
      { value: 'B', text: '4000米以上' },
      { value: 'C', text: '5000米以上' },
      { value: 'D', text: '6000米以上' }
    ],
    correct: 'B',
    explanation: '青藏高原平均海拔在4000米以上，是世界上最高的高原。'
  },
  {
    id: 2,
    question: '长江中下游平原的主要农作物是什么？',
    options: [
      { value: 'A', text: '小麦' },
      { value: 'B', text: '水稻' },
      { value: 'C', text: '玉米' },
      { value: 'D', text: '大豆' }
    ],
    correct: 'B',
    explanation: '长江中下游平原水热条件优越，主要种植水稻。'
  }
]

// 灾害应对模拟游戏数据
const disasterScenarios = [
  {
    id: 1,
    title: '地震灾害应对',
    description: '某地发生7.0级地震，你作为应急管理人员，需要做出正确的决策。',
    situation: '地震发生后，学校教学楼出现裂缝，学生正在上课，你接到报告后需要立即行动。',
    decisions: [
      {
        id: 'd1',
        text: '立即组织学生疏散到操场',
        consequences: '正确决策，避免了可能的伤亡',
        score: 10,
        explanation: '地震发生后，首要任务是确保人员安全，疏散到空旷地带是最佳选择。'
      },
      {
        id: 'd2',
        text: '先检查建筑结构再决定',
        consequences: '延误了疏散时间，增加了风险',
        score: 2,
        explanation: '地震后建筑结构可能不稳定，应该优先疏散人员。'
      },
      {
        id: 'd3',
        text: '等待上级指示',
        consequences: '错过了最佳疏散时机',
        score: 0,
        explanation: '地震应急需要快速反应，不能等待指示。'
      }
    ]
  },
  {
    id: 2,
    title: '洪水灾害应对',
    description: '连日暴雨导致河流水位上涨，你所在的村庄面临洪水威胁。',
    situation: '气象部门发布洪水预警，预计2小时后洪水将到达村庄，你需要制定应对方案。',
    decisions: [
      {
        id: 'd4',
        text: '立即组织村民撤离到高地',
        consequences: '成功避免了人员伤亡',
        score: 10,
        explanation: '洪水预警发布后，应该立即组织人员撤离到安全地带。'
      },
      {
        id: 'd5',
        text: '先转移贵重物品',
        consequences: '延误了人员撤离时间',
        score: 3,
        explanation: '人员安全比财产更重要，应该优先撤离人员。'
      },
      {
        id: 'd6',
        text: '加固房屋等待洪水过去',
        consequences: '房屋被冲毁，人员被困',
        score: 0,
        explanation: '洪水威力巨大，房屋加固无法抵御，应该及时撤离。'
      }
    ]
  }
]

// 计算属性
const puzzleTiles = ref(generatePuzzle())
const currentRiddle = computed(() => riddles[currentRiddleIndex.value])
const hasNextRiddle = computed(() => currentRiddleIndex.value < riddles.length - 1)

// 方法
function startGame(game: any) {
  currentGame.value = game
  if (game.id === 'climate-puzzle') {
    initPuzzle()
  } else if (game.id === 'geo-riddle') {
    initRiddle()
  } else if (game.id === 'geo-monopoly') {
    initMonopoly()
  } else if (game.id === 'disaster-simulation') {
    initDisasterSimulation()
  }
}

function exitGame() {
  currentGame.value = null
  resetGameState()
}

// 拼图游戏相关
function generatePuzzle() {
  const tiles = []
  const total = gridSize * gridSize
  for (let i = 0; i < total - 1; i++) {
    const x = i % gridSize
    const y = Math.floor(i / gridSize)
    tiles.push({
      number: i + 1,
      x,
      y,
      isEmpty: false,
      isCorrect: true
    })
  }
  tiles.push({ number: total, x: gridSize - 1, y: gridSize - 1, isEmpty: true, isCorrect: true })
  return tiles
}

function initPuzzle() {
  // 随机打乱拼图
  for (let i = puzzleTiles.value.length - 2; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    const temp = { ...puzzleTiles.value[i] }
    puzzleTiles.value[i] = { ...puzzleTiles.value[j] }
    puzzleTiles.value[j] = temp
  }
  timeUsed.value = 0
  score.value = 0
  movesLeft.value = 30
  startTimer()
}

function moveTile(index: number) {
  if (movesLeft.value <= 0) return

  const emptyIndex = puzzleTiles.value.findIndex(tile => tile.isEmpty)
  const canMove = isAdjacent(index, emptyIndex)

  if (canMove) {
    // 交换位置
    const temp = { ...puzzleTiles.value[index] }
    puzzleTiles.value[index] = { ...puzzleTiles.value[emptyIndex] }
    puzzleTiles.value[emptyIndex] = temp
    movesLeft.value--
    checkWinCondition()
  }
}

function isAdjacent(index1: number, index2: number) {
  const row1 = Math.floor(index1 / gridSize)
  const col1 = index1 % gridSize
  const row2 = Math.floor(index2 / gridSize)
  const col2 = index2 % gridSize

  return (
    (Math.abs(row1 - row2) === 1 && col1 === col2) ||
    (Math.abs(col1 - col2) === 1 && row1 === row2)
  )
}

function checkWinCondition() {
  const isWin = puzzleTiles.value.every((tile, index) => {
    if (tile.isEmpty) return index === puzzleTiles.value.length - 1
    return tile.number === index + 1
  })

  if (isWin) {
    score.value = Math.max(100 - timeUsed.value - (30 - movesLeft.value) * 2, 10)
    // TODO: 显示胜利提示
  }
}

// 灯谜游戏相关
function initRiddle() {
  currentRiddleIndex.value = 0
  score.value = 0
  timeLeft.value = 180 // 3分钟
  showRiddleHint.value = false
  showExplanation.value = false
  userAnswer.value = ''
  startTimer()
}

function submitAnswer() {
  const riddle = currentRiddle.value
  isCorrect.value = userAnswer.value === riddle.answer
  score.value += isCorrect.value ? 10 : 0
  showExplanation.value = true
}

function nextRiddle() {
  if (hasNextRiddle.value) {
    currentRiddleIndex.value++
    showRiddleHint.value = false
    showExplanation.value = false
    userAnswer.value = ''
  } else {
    // TODO: 显示游戏完成提示
  }
}

// 通用方法
let timer: number
function startTimer() {
  timer = window.setInterval(() => {
    if (currentGame.value.id === 'climate-puzzle') {
      timeUsed.value++
    } else {
      timeLeft.value--
      if (timeLeft.value <= 0) {
        clearInterval(timer)
        // TODO: 显示时间到提示
      }
    }
  }, 1000)
}

function resetGameState() {
  clearInterval(timer)
  timeUsed.value = 0
  timeLeft.value = 0
  score.value = 0
  movesLeft.value = 30
  showNumbers.value = true
  showingHint.value = false
  hintCount.value = 3
  userAnswer.value = ''
  showRiddleHint.value = false
  showExplanation.value = false
  currentRiddleIndex.value = 0
  
  // 重置地理大富翁游戏状态
  currentPosition.value = 0
  playerMoney.value = 1000
  currentQuestion.value = null
  showQuestionModal.value = false
  questionAnswered.value = false
  
  // 重置灾害应对模拟游戏状态
  currentScenario.value = null
  scenarioIndex.value = 0
  playerDecisions.value = []
  showDecisionModal.value = false
  decisionResult.value = null
}

function formatTime(seconds: number) {
  const minutes = Math.floor(seconds / 60)
  const remainingSeconds = seconds % 60
  return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`
}

function toggleNumbers() {
  showNumbers.value = !showNumbers.value
}

function showHint() {
  if (hintCount.value > 0) {
    showingHint.value = true
    hintCount.value--
  }
}

function hideHint() {
  showingHint.value = false
}

// 地理大富翁游戏相关
function initMonopoly() {
  currentPosition.value = 0
  playerMoney.value = 1000
  score.value = 0
  questionAnswered.value = false
  showQuestionModal.value = false
  startTimer()
}

function rollDice() {
  const dice = Math.floor(Math.random() * 6) + 1
  currentPosition.value = (currentPosition.value + dice) % monopolyBoard.length
  const currentCell = monopolyBoard[currentPosition.value]
  
  if (currentCell.type === 'landmark') {
    showQuestionModal.value = true
    currentQuestion.value = monopolyQuestions[Math.floor(Math.random() * monopolyQuestions.length)]
  } else if (currentCell.type === 'chance') {
    // 机会卡逻辑
    const chanceEvents = [
      { text: '获得奖学金', money: 100 },
      { text: '地理知识竞赛获奖', money: 150 },
      { text: '购买地理书籍', money: -50 }
    ]
    const event = chanceEvents[Math.floor(Math.random() * chanceEvents.length)]
    playerMoney.value += event.money
    // TODO: 显示机会卡内容
  } else if (currentCell.type === 'destiny') {
    // 命运卡逻辑
    const destinyEvents = [
      { text: '地震灾害，损失财产', money: -200 },
      { text: '洪水预警，提前准备', money: -100 },
      { text: '地理考察，获得经验', money: 200 }
    ]
    const event = destinyEvents[Math.floor(Math.random() * destinyEvents.length)]
    playerMoney.value += event.money
    // TODO: 显示命运卡内容
  }
}

function answerQuestion(answer: string) {
  if (currentQuestion.value) {
    const isCorrect = answer === currentQuestion.value.correct
    if (isCorrect) {
      score.value += 10
      playerMoney.value += 50
    } else {
      playerMoney.value -= 20
    }
    questionAnswered.value = true
    showQuestionModal.value = false
  }
}

function closeQuestionModal() {
  showQuestionModal.value = false
  questionAnswered.value = false
}

// 灾害应对模拟游戏相关
function initDisasterSimulation() {
  scenarioIndex.value = 0
  playerDecisions.value = []
  currentScenario.value = disasterScenarios[scenarioIndex.value]
  score.value = 0
  showDecisionModal.value = false
  decisionResult.value = null
  startTimer()
}

function makeDecision(decision: any) {
  playerDecisions.value.push(decision)
  decisionResult.value = decision
  score.value += decision.score
  showDecisionModal.value = true
}

function nextScenario() {
  if (scenarioIndex.value < disasterScenarios.length - 1) {
    scenarioIndex.value++
    currentScenario.value = disasterScenarios[scenarioIndex.value]
    showDecisionModal.value = false
    decisionResult.value = null
  } else {
    // 游戏结束
    // TODO: 显示游戏完成界面
  }
}

function closeDecisionModal() {
  showDecisionModal.value = false
  decisionResult.value = null
}

onMounted(() => {
  // 可以添加游戏资源预加载逻辑
})

onUnmounted(() => {
  clearInterval(timer)
})
</script>

<style scoped lang="scss">
.games-page {
  padding: var(--spacing-base);
  padding-bottom: 60px;
}

// 游戏列表样式
.game-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: var(--spacing-base);
}

.game-card {
  background: white;
  border-radius: var(--radius-base);
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }
}

.game-preview {
  position: relative;
  padding-top: 56.25%; // 16:9 比例

  img {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .game-tags {
    position: absolute;
    top: var(--spacing-base);
    right: var(--spacing-base);
    display: flex;
    gap: var(--spacing-small);
  }
}

.game-info {
  padding: var(--spacing-base);

  h3 {
    margin: 0 0 var(--spacing-small);
  }

  .description {
    color: var(--color-text-secondary);
    margin-bottom: var(--spacing-base);
  }
}

.knowledge-points {
  .label {
    color: var(--color-text-secondary);
    margin-right: var(--spacing-small);
  }

  .tags {
    display: flex;
    flex-wrap: wrap;
    gap: var(--spacing-small);
    margin-top: var(--spacing-small);
  }
}

// 游戏界面通用样式
.game-header {
  background: white;
  padding: var(--spacing-base);
  border-radius: var(--radius-base);
  margin-bottom: var(--spacing-base);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

  h2 {
    margin: 0 0 var(--spacing-base);
  }
}

.game-stats {
  display: flex;
  gap: var(--spacing-large);
}

.stat {
  display: flex;
  flex-direction: column;
  align-items: center;

  .label {
    color: var(--color-text-secondary);
    font-size: 0.9em;
  }

  .value {
    font-size: 1.2em;
    font-weight: 500;
  }
}

// 拼图游戏样式
.puzzle-container {
  background: white;
  padding: var(--spacing-base);
  border-radius: var(--radius-base);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.puzzle-grid {
  display: grid;
  gap: 2px;
  background: #333;
  padding: 2px;
  border-radius: var(--radius-base);
  aspect-ratio: 1;
  margin-bottom: var(--spacing-base);
}

.puzzle-tile {
  position: relative;
  background-size: 300% 300%;
  cursor: pointer;
  transition: transform 0.3s ease;
  border-radius: 2px;

  &:not(.empty):hover {
    transform: scale(0.98);
  }

  &.empty {
    background: #666;
  }

  &.correct {
    outline: 2px solid var(--color-success);
  }
}

.tile-number {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: rgba(0, 0, 0, 0.5);
  color: white;
  padding: 4px 8px;
  border-radius: var(--radius-small);
}

.puzzle-controls {
  display: flex;
  justify-content: center;
  gap: var(--spacing-base);
}

// 灯谜游戏样式
.riddle-container {
  background: white;
  padding: var(--spacing-base);
  border-radius: var(--radius-base);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.riddle-content {
  max-width: 600px;
  margin: 0 auto;
}

.riddle-text,
.riddle-hint {
  margin-bottom: var(--spacing-large);

  h3 {
    color: var(--color-text-secondary);
    margin-bottom: var(--spacing-small);
  }

  p {
    font-size: 1.2em;
    margin: 0;
  }
}

.answer-area {
  margin-bottom: var(--spacing-base);

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

.options {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: var(--spacing-base);
}

.option-btn {
  padding: var(--spacing-base);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  background: white;
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: left;

  &:hover {
    background: #f5f5f5;
  }

  &.selected {
    background: var(--color-primary);
    color: white;
    border-color: var(--color-primary);
  }
}

.action-buttons {
  display: flex;
  justify-content: flex-end;
  gap: var(--spacing-base);
}

.explanation {
  margin-top: var(--spacing-large);
  padding-top: var(--spacing-large);
  border-top: 1px solid var(--color-border);
  text-align: center;

  .result {
    font-size: 1.2em;
    font-weight: 500;
    margin-bottom: var(--spacing-base);

    &.correct {
      color: var(--color-success);
    }

    &.wrong {
      color: var(--color-error);
    }
  }

  .correct-answer {
    margin-bottom: var(--spacing-base);
  }

  .explanation-text {
    text-align: left;
    margin-bottom: var(--spacing-large);

    h3 {
      color: var(--color-text-secondary);
      margin-bottom: var(--spacing-small);
    }
  }
}

// 提示模态框
.hint-modal {
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

.hint-content {
  background: white;
  padding: var(--spacing-base);
  border-radius: var(--radius-base);
  text-align: center;

  img {
    max-width: 100%;
    max-height: 70vh;
    border-radius: var(--radius-small);
    margin-bottom: var(--spacing-base);
  }

  p {
    color: var(--color-text-secondary);
    margin: 0;
  }
}

// 返回按钮
.btn-back {
  position: fixed;
  bottom: var(--spacing-large);
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  padding: var(--spacing-base) var(--spacing-large);
  background: white;
  border: none;
  border-radius: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    transform: translateX(-50%) translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  }
}

// 地理大富翁游戏样式
.geo-monopoly {
  .monopoly-container {
    background: white;
    padding: var(--spacing-base);
    border-radius: var(--radius-base);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  }
}

.monopoly-board {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  grid-template-rows: repeat(2, 1fr);
  gap: 2px;
  background: #333;
  padding: 2px;
  border-radius: var(--radius-base);
  margin-bottom: var(--spacing-base);
  aspect-ratio: 5/2;
}

.board-cell {
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 0.8em;
  text-align: center;
  border-radius: 2px;
  position: relative;
  transition: all 0.3s ease;

  &.current {
    transform: scale(1.05);
    box-shadow: 0 0 10px rgba(255, 255, 255, 0.5);
    z-index: 2;
  }

  &.start {
    background: linear-gradient(45deg, #4CAF50, #66BB6A) !important;
  }

  &.chance {
    background: linear-gradient(45deg, #FFC107, #FFD54F) !important;
    color: #333;
  }

  &.destiny {
    background: linear-gradient(45deg, #E91E63, #F06292) !important;
  }
}

.cell-content {
  padding: var(--spacing-small);
  
  .cell-name {
    font-weight: 500;
    margin-bottom: 2px;
  }
  
  .cell-price {
    font-size: 0.7em;
    opacity: 0.8;
  }
}

.monopoly-controls {
  display: flex;
  justify-content: center;
  gap: var(--spacing-base);
}

// 答题模态框样式
.question-modal {
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

.question-content {
  background: white;
  border-radius: var(--radius-base);
  max-width: 500px;
  width: 90%;
  max-height: 80vh;
  overflow-y: auto;
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-base);
  border-bottom: 1px solid var(--color-border);

  h3 {
    margin: 0;
  }
}

.question-body {
  padding: var(--spacing-base);
}

.question-text {
  font-size: 1.1em;
  margin-bottom: var(--spacing-base);
  line-height: 1.5;
}

.question-options {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-small);
}

// 灾害应对模拟游戏样式
.disaster-simulation {
  .simulation-container {
    background: white;
    padding: var(--spacing-base);
    border-radius: var(--radius-base);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  }
}

.scenario-info {
  margin-bottom: var(--spacing-large);

  h3 {
    color: var(--color-primary);
    margin-bottom: var(--spacing-small);
  }

  .scenario-description {
    color: var(--color-text-secondary);
    margin-bottom: var(--spacing-base);
    line-height: 1.5;
  }
}

.situation-box {
  background: #f8f9fa;
  padding: var(--spacing-base);
  border-radius: var(--radius-base);
  border-left: 4px solid var(--color-warning);

  h4 {
    color: var(--color-warning);
    margin: 0 0 var(--spacing-small);
  }

  p {
    margin: 0;
    line-height: 1.5;
  }
}

.decision-options {
  h4 {
    margin-bottom: var(--spacing-base);
    color: var(--color-text-primary);
  }
}

.options-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: var(--spacing-base);
}

.decision-btn {
  padding: var(--spacing-base);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-base);
  background: white;
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: left;
  font-size: 1em;
  line-height: 1.4;

  &:hover {
    border-color: var(--color-primary);
    background: #f8f9ff;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  &:active {
    transform: translateY(0);
  }
}

// 决策结果模态框样式
.decision-modal {
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

.decision-content {
  background: white;
  border-radius: var(--radius-base);
  max-width: 600px;
  width: 90%;
  max-height: 80vh;
  overflow-y: auto;
}

.decision-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-base);
  border-bottom: 1px solid var(--color-border);

  h3 {
    margin: 0;
  }
}

.decision-body {
  padding: var(--spacing-base);
}

.result-info {
  margin-bottom: var(--spacing-large);

  .consequence,
  .explanation {
    margin-bottom: var(--spacing-base);

    h4 {
      color: var(--color-text-secondary);
      margin-bottom: var(--spacing-small);
    }

    p {
      margin: 0;
      line-height: 1.5;
    }
  }
}

.score-info {
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  padding: var(--spacing-base);
  background: #f0f8ff;
  border-radius: var(--radius-base);
  border-left: 4px solid var(--color-success);

  .score-label {
    color: var(--color-text-secondary);
  }

  .score-value {
    font-size: 1.2em;
    font-weight: 500;
    color: var(--color-success);
  }
}

.decision-actions {
  display: flex;
  justify-content: center;
}

// 适配大字体模式
:global(.large-text) {
  .game-card {
    .description {
      font-size: 1.1em;
    }
  }

  .riddle-text p,
  .riddle-hint p {
    font-size: 1.3em;
  }

  .question-text {
    font-size: 1.2em;
  }

  .scenario-description,
  .situation-box p {
    font-size: 1.1em;
  }
}

:global(.xlarge-text) {
  .game-card {
    .description {
      font-size: 1.2em;
    }
  }

  .riddle-text p,
  .riddle-hint p {
    font-size: 1.4em;
  }

  .question-text {
    font-size: 1.3em;
  }

  .scenario-description,
  .situation-box p {
    font-size: 1.2em;
  }
}
</style>
