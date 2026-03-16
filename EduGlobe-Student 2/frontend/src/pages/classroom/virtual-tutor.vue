<template>
  <div class="virtual-tutor">
    <!-- 角色选择 -->
    <div class="character-selection" v-if="!selectedCharacter">
      <h2>选择你的地理导师</h2>
      <div class="characters">
        <div 
          v-for="character in characters" 
          :key="character.id"
          class="character-card"
          @click="selectCharacter(character)"
        >
          <div class="avatar">
            <img :src="character.avatar" :alt="character.name">
          </div>
          <div class="info">
            <h3>{{ character.name }}</h3>
            <p class="title">{{ character.title }}</p>
            <p class="description">{{ character.description }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 对话界面 -->
    <div v-else class="chat-interface">
      <!-- 角色信息 -->
      <div class="character-info">
        <div class="avatar">
          <img :src="selectedCharacter.avatar" :alt="selectedCharacter.name">
        </div>
        <div class="info">
          <h3>{{ selectedCharacter.name }}</h3>
          <p>{{ selectedCharacter.title }}</p>
        </div>
        <button class="btn-icon" @click="selectedCharacter = null">
          <span class="material-icons">close</span>
        </button>
      </div>

      <!-- 主要内容区域 -->
      <div class="main-content">
        <!-- AI人物形象 -->
        <div class="ai-character" :class="{ speaking: isSpeaking }">
          <div class="character-portrait">
            <img :src="selectedCharacter.portrait" :alt="selectedCharacter.name">
            <div class="speech-bubble" v-if="isSpeaking">
              <div class="bubble-content">
                <div class="speaking-text">{{ currentSpeakingText }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- 对话内容 -->
        <div class="chat-content" ref="chatContent">
          <div 
            v-for="(message, index) in messages" 
            :key="index"
            class="message"
            :class="{ 
              'character': message.type === 'character',
              'user': message.type === 'user'
            }"
          >
            <div class="message-content">
              <div v-if="message.type === 'character'" class="typing-animation">
                {{ message.content }}
              </div>
              <div v-else>{{ message.content }}</div>
            </div>

            <!-- 选项按钮 -->
            <div v-if="message.options" class="options">
              <button 
                v-for="option in message.options" 
                :key="option.id"
                class="option-btn"
                @click="selectOption(option)"
              >
                {{ option.text }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- 输入区域 -->
      <div class="input-area">
        <div class="input-wrapper">
          <input 
            type="text"
            v-model="userInput"
            placeholder="输入你的问题..."
            @keyup.enter="sendMessage"
          >
          <button class="btn-icon" @click="startVoiceInput">
            <span class="material-icons">mic</span>
          </button>
        </div>
        <button 
          class="btn-primary send-btn"
          :disabled="!userInput.trim()"
          @click="sendMessage"
        >
          <span class="material-icons">send</span>
        </button>
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
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue'

// 状态
const selectedCharacter = ref<any>(null)
const messages = ref<any[]>([])
const userInput = ref('')
const isListening = ref(false)
const chatContent = ref<HTMLElement>()

// AI人物说话状态
const isSpeaking = ref(false)
const currentSpeakingText = ref('')

// 模拟数据
const characters = [
  {
    id: 'xuxiake',
    name: '徐霞客',
    title: '明代地理学家、旅行家',
    description: '游历山川，著《徐霞客游记》，对中国自然地理有深入研究。',
    avatar: '/avatars/xuxiake.png',
    portrait: '/徐霞客.jpg',
    welcomeMessage: '欢迎同学！今天我们一起探索大自然的奥秘，你想了解什么？',
    topics: [
      {
        id: 't1',
        question: '四山环翠是什么地貌特征？',
        answer: '四山环翠描述的是群山环绕的盆地地貌。这种地形在我游历的江南地区很常见，比如杭州。山地环绕不仅创造了优美的自然景观，还为当地气候和水文带来重要影响。'
      }
    ]
  },
  {
    id: 'zhangqian',
    name: '张骞',
    title: '汉代外交家、探险家',
    description: '开辟丝绸之路，对中亚地理、民族有详细记载。',
    avatar: '/avatars/zhangqian.png',
    portrait: '/张骞.jpg',
    welcomeMessage: '你好！让我带你了解丝绸之路沿线的地理特征。',
    topics: [
      {
        id: 't1',
        question: '为什么丝绸之路要经过河西走廊？',
        answer: '河西走廊是连接中原与西域的重要通道。这里地势平坦，有绿洲分布，是穿越荒漠地区的最佳路线。同时，走廊两侧的祁连山和北山为商旅提供了天然屏障。'
      }
    ]
  }
]

// 方法
function selectCharacter(character: any) {
  selectedCharacter.value = character
  // 添加欢迎消息
  addMessage({
    type: 'character',
    content: character.welcomeMessage,
    options: [
      { id: 'o1', text: character.topics[0].question }
    ]
  })
  // 触发AI人物说话动画
  makeCharacterSpeak(character.welcomeMessage)
}

function addMessage(message: any) {
  messages.value.push(message)
  // 滚动到底部
  nextTick(() => {
    if (chatContent.value) {
      chatContent.value.scrollTop = chatContent.value.scrollHeight
    }
  })
}

function selectOption(option: any) {
  // 添加用户选择
  addMessage({
    type: 'user',
    content: option.text
  })

  // 查找对应的回答
  const topic = selectedCharacter.value.topics.find((t: any) => t.question === option.text)
  if (topic) {
    setTimeout(() => {
      addMessage({
        type: 'character',
        content: topic.answer
      })
      // 触发AI人物说话动画
      makeCharacterSpeak(topic.answer)
    }, 500)
  }
}

function sendMessage() {
  if (!userInput.value.trim()) return

  // 添加用户消息
  addMessage({
    type: 'user',
    content: userInput.value
  })

  // 模拟回答
  setTimeout(() => {
    const response = '这是一个很好的问题！让我想想...'
    addMessage({
      type: 'character',
      content: response
    })
    // 触发AI人物说话动画
    makeCharacterSpeak(response)
  }, 500)

  userInput.value = ''
}

// 语音输入相关
function startVoiceInput() {
  isListening.value = true
  // TODO: 实现语音识别
}

function stopVoiceInput() {
  isListening.value = false
}

// AI人物说话方法
function makeCharacterSpeak(text: string) {
  isSpeaking.value = true
  currentSpeakingText.value = text
  
  // 模拟说话时长
  const speakDuration = text.length * 100 // 每个字符100ms
  setTimeout(() => {
    isSpeaking.value = false
    currentSpeakingText.value = ''
  }, speakDuration)
}
</script>

<style scoped lang="scss">
.virtual-tutor {
  height: calc(100vh - 180px);
  display: flex;
  flex-direction: column;
}

.character-selection {
  padding: var(--spacing-base);

  h2 {
    text-align: center;
    margin-bottom: var(--spacing-large);
  }
}

.characters {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--spacing-base);
}

.character-card {
  background: white;
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  gap: var(--spacing-base);
  align-items: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  .avatar {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    overflow: hidden;
    flex-shrink: 0;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  }

  .info {
    flex: 1;

    h3 {
      margin: 0 0 4px;
    }

    .title {
      color: var(--color-text-secondary);
      font-size: 0.9em;
      margin: 0 0 8px;
    }

    .description {
      margin: 0;
      font-size: 0.9em;
      color: var(--color-text-secondary);
    }
  }
}

.chat-interface {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #f5f5f5;
}

// 主要内容区域
.main-content {
  flex: 1;
  display: flex;
  gap: var(--spacing-base);
  overflow: hidden;
}

// AI人物形象
.ai-character {
  width: 280px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
  padding: var(--spacing-base);
  background: white;
  border-radius: var(--radius-base);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

  @media (max-width: 768px) {
    display: none;
  }

  &.speaking {
    .character-portrait img {
      animation: speaking 0.5s ease-in-out infinite alternate;
    }
  }
}

.character-portrait {
  position: relative;
  width: 100%;
  height: 280px;
  margin-bottom: var(--spacing-base);

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: var(--radius-base);
    transition: all 0.3s ease;
  }
}


.speech-bubble {
  position: absolute;
  top: -10px;
  left: 50%;
  transform: translateX(-50%);
  background: white;
  border-radius: var(--radius-base);
  padding: var(--spacing-small) var(--spacing-base);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  max-width: 220px;
  z-index: 10;
  animation: bubbleAppear 0.3s ease-out;

  &::after {
    content: '';
    position: absolute;
    bottom: -8px;
    left: 50%;
    transform: translateX(-50%);
    width: 0;
    height: 0;
    border-left: 8px solid transparent;
    border-right: 8px solid transparent;
    border-top: 8px solid white;
  }
}

.bubble-content {
  .speaking-text {
    font-size: 0.85em;
    line-height: 1.4;
    color: var(--color-text-primary);
    max-height: 60px;
    overflow: hidden;
    text-overflow: ellipsis;
  }
}

// 说话动画
@keyframes speaking {
  0% {
    transform: scale(1);
  }
  100% {
    transform: scale(1.02);
  }
}

@keyframes bubbleAppear {
  0% {
    opacity: 0;
    transform: translateX(-50%) translateY(10px);
  }
  100% {
    opacity: 1;
    transform: translateX(-50%) translateY(0);
  }
}

.character-info {
  background: white;
  padding: var(--spacing-base);
  display: flex;
  align-items: center;
  gap: var(--spacing-base);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

  .avatar {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    overflow: hidden;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  }

  .info {
    flex: 1;

    h3 {
      margin: 0;
    }

    p {
      margin: 4px 0 0;
      color: var(--color-text-secondary);
      font-size: 0.9em;
    }
  }
}

.chat-content {
  flex: 1;
  overflow-y: auto;
  padding: var(--spacing-base);
  background: white;
  border-radius: var(--radius-base);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.message {
  margin-bottom: var(--spacing-base);
  display: flex;
  flex-direction: column;
  gap: var(--spacing-small);

  &.character {
    align-items: flex-start;

    .message-content {
      background: white;
      border-radius: 0 var(--radius-base) var(--radius-base) var(--radius-base);
    }
  }

  &.user {
    align-items: flex-end;

    .message-content {
      background: var(--color-primary);
      color: white;
      border-radius: var(--radius-base) 0 var(--radius-base) var(--radius-base);
    }
  }
}

.message-content {
  padding: var(--spacing-base);
  max-width: 80%;
  word-break: break-word;
}

.options {
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-small);
}

.option-btn {
  padding: var(--spacing-small) var(--spacing-base);
  background: white;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    background: var(--color-primary);
    color: white;
    border-color: var(--color-primary);
  }
}

.input-area {
  background: white;
  padding: var(--spacing-base);
  display: flex;
  gap: var(--spacing-base);
  align-items: center;
}

.input-wrapper {
  flex: 1;
  display: flex;
  align-items: center;
  background: #f5f5f5;
  border-radius: var(--radius-base);
  padding: 0 var(--spacing-small);

  input {
    flex: 1;
    border: none;
    background: transparent;
    padding: var(--spacing-base);
    font-size: inherit;

    &:focus {
      outline: none;
    }
  }
}

.send-btn {
  width: 44px;
  height: 44px;
  padding: 0;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.voice-input-modal {
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

// 打字动画
.typing-animation {
  display: inline-block;
  animation: typing 1.5s steps(40, end);
}

@keyframes typing {
  from { clip-path: inset(0 100% 0 0); }
  to { clip-path: inset(0 0 0 0); }
}

// 适配大字体模式
:global(.large-text) {
  .character-card {
    .title, .description {
      font-size: 1em;
    }
  }

  .message-content {
    font-size: 1.1em;
  }
}

:global(.xlarge-text) {
  .character-card {
    .title, .description {
      font-size: 1.1em;
    }
  }

  .message-content {
    font-size: 1.2em;
  }
}
</style>
