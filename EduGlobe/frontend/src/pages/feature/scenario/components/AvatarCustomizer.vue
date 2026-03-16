<template>
  <div class="avatar-customizer">
    <!-- 左侧：角色选择与属性 -->
    <div class="left-panel">
      <div class="panel-header">
        <h3>定义探索者</h3>
      </div>

      <!-- 角色选择网格 -->
      <div class="character-grid">
        <div
          v-for="char in characters"
          :key="char.id"
          class="character-item"
          :class="{ active: selectedCharacter?.id === char.id }"
          @click="selectCharacter(char)"
        >
          <div class="character-avatar">
            <img :src="char.avatar" :alt="char.name" />
            <div v-if="selectedCharacter?.id === char.id" class="selected-badge">✓</div>
          </div>
          <div class="character-name">{{ char.name }}</div>
          <div v-if="selectedCharacter?.id === char.id" class="character-gender">
            {{ char.gender === 'male' ? '男' : '女' }}
          </div>
        </div>
      </div>

      <!-- 职业选择 -->
      <div class="profession-section">
        <h4>选择职业套装</h4>
        <div class="profession-list">
          <div
            v-for="prof in professions"
            :key="prof.id"
            class="profession-item"
            :class="{ active: selectedProfession?.id === prof.id }"
            @click="selectProfession(prof)"
          >
            <span class="profession-icon">{{ prof.icon }}</span>
            <span class="profession-name">{{ prof.name }}</span>
          </div>
        </div>
      </div>

      <!-- 属性显示 -->
      <div class="attributes-section">
        <h4>步频反选报</h4>
        <div class="attributes-list">
          <div class="attribute-item">
            <span class="attribute-icon">🔨</span>
            <span class="attribute-label">地质容</span>
            <span class="attribute-value">{{ finalAttributes.geology }}</span>
          </div>
          <div class="attribute-item">
            <span class="attribute-icon">🌦️</span>
            <span class="attribute-label">气气观测</span>
            <span class="attribute-value">{{ finalAttributes.atmosphere }}</span>
          </div>
          <div class="attribute-item">
            <span class="attribute-icon">📝</span>
            <span class="attribute-label">记景</span>
            <span class="attribute-value">{{ finalAttributes.recording }}</span>
          </div>
          <div class="attribute-item">
            <span class="attribute-icon">💬</span>
            <span class="attribute-label">去议</span>
            <span class="attribute-value">{{ finalAttributes.discussion }}</span>
          </div>
        </div>
      </div>

      <!-- 确认按钮 -->
      <button class="confirm-btn" @click="handleConfirm" :disabled="!selectedCharacter || !selectedProfession">
        {{ selectedCharacter && selectedProfession ? '开始探索' : '请选择角色和职业' }}
      </button>
    </div>

    <!-- 中央：3D角色预览 -->
    <div class="center-preview">
      <div class="preview-container">
        <div class="character-preview" v-if="selectedCharacter">
          <div class="preview-character">
            <img :src="selectedCharacter.avatar" :alt="selectedCharacter.name" class="preview-avatar" />
            <div class="character-info">
              <h3>{{ selectedCharacter.name }}</h3>
              <p v-if="selectedProfession">{{ selectedProfession.name }}</p>
            </div>
          </div>
          
          <!-- 装备展示 -->
          <div class="equipment-display" v-if="currentEquipment.length > 0">
            <h4>当前装备</h4>
            <div class="equipment-list">
              <div v-for="(item, index) in currentEquipment" :key="index" class="equipment-item">
                <span class="equipment-icon">🎒</span>
                <span>{{ item }}</span>
              </div>
            </div>
          </div>
        </div>
        <div v-else class="preview-placeholder">
          <p>请选择角色开始定制</p>
        </div>
      </div>
    </div>

    <!-- 右侧：场景选择 -->
    <div class="right-panel">
      <div class="panel-header">
        <h3>场景选择</h3>
      </div>
      <div class="scene-list">
        <div
          v-for="scene in scenarios"
          :key="scene.id"
          class="scene-item"
          :class="{ active: selectedScene?.id === scene.id }"
          @click="selectScene(scene)"
        >
          <button class="scene-add-btn">+</button>
          <div class="scene-info">
            <h4>{{ scene.name }}</h4>
            <p class="scene-type">{{ scene.type }}</p>
          </div>
        </div>
      </div>
      <button class="assign-btn" @click="handleAssign" :disabled="!selectedScene">
        指定
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { getTasks } from '../../../services/api'

// 类型定义
type Character = {
  id: string
  name: string
  gender: 'male' | 'female'
  hairColor: string
  hairStyle: string
  skinTone: string
  avatar: string
  baseAttributes: {
    geology: number
    atmosphere: number
    recording: number
    discussion: number
  }
}

type Profession = {
  id: string
  name: string
  icon: string
  description: string
  equipment: Record<string, string[]>
  attributeBonus: {
    geology: number
    atmosphere: number
    recording: number
    discussion: number
  }
}

type Scenario = {
  id: string
  name: string
  type: string
  description?: string
}

// Props 定义
const props = defineProps<{
  scenarios?: Scenario[]
}>()

// 事件定义
const emit = defineEmits<{
  (e: 'confirm', data: { character: Character; profession: Profession; scene: Scenario | null }): void
}>()

// 响应式数据
const characters = ref<Character[]>([])
const professions = ref<Profession[]>([])
const scenarios = ref<Scenario[]>([])
const selectedCharacter = ref<Character | null>(null)
const selectedProfession = ref<Profession | null>(null)
const selectedScene = ref<Scenario | null>(null)

// 计算最终属性（角色基础属性 + 职业加成）
const finalAttributes = computed(() => {
  if (!selectedCharacter.value) {
    return { geology: 0, atmosphere: 0, recording: 0, discussion: 0 }
  }
  
  const base = selectedCharacter.value.baseAttributes
  const bonus = selectedProfession.value?.attributeBonus || {
    geology: 0,
    atmosphere: 0,
    recording: 0,
    discussion: 0
  }
  
  return {
    geology: base.geology + bonus.geology,
    atmosphere: base.atmosphere + bonus.atmosphere,
    recording: base.recording + bonus.recording,
    discussion: base.discussion + bonus.discussion
  }
})

// 计算当前装备（根据场景自动调整）
const currentEquipment = computed(() => {
  if (!selectedProfession.value || !selectedScene.value) {
    return []
  }
  
  // 获取场景对应的装备类型
  const sceneEquipmentMap: Record<string, string> = {
    'volcano_observation': 'volcano',
    'monsoon_experience': 'monsoon',
    'karst_cave_explore': 'karst',
    'urban_function': 'urban',
    'settlement_planning': 'settlement',
    'tropical_rainforest': 'tropical_rainforest',
    'polar_glacier': 'polar_glacier'
  }
  
  const equipmentType = sceneEquipmentMap[selectedScene.value.id] || 'base'
  const sceneEquipment = selectedProfession.value.equipment[equipmentType] || []
  const baseEquipment = selectedProfession.value.equipment.base || []
  
  // 合并基础装备和场景特定装备
  return [...baseEquipment, ...sceneEquipment]
})

// 方法
function selectCharacter(char: Character) {
  selectedCharacter.value = char
  // 保存到 localStorage
  localStorage.setItem('selectedCharacter', JSON.stringify(char))
}

function selectProfession(prof: Profession) {
  selectedProfession.value = prof
  // 保存到 localStorage
  localStorage.setItem('selectedProfession', JSON.stringify(prof))
}

function selectScene(scene: Scenario) {
  selectedScene.value = scene
}

function handleConfirm() {
  if (selectedCharacter.value && selectedProfession.value) {
    // 触发确认事件
    emit('confirm', {
      character: selectedCharacter.value,
      profession: selectedProfession.value,
      scene: selectedScene.value
    })
  }
}

function handleAssign() {
  if (selectedScene.value && selectedCharacter.value && selectedProfession.value) {
    // 保存当前选择
    localStorage.setItem('selectedCharacter', JSON.stringify(selectedCharacter.value))
    localStorage.setItem('selectedProfession', JSON.stringify(selectedProfession.value))
    localStorage.setItem('selectedScene', JSON.stringify(selectedScene.value))
    
    // 跳转到探索页面
    const exploreUrl = `/feature/scenario/explore?id=${encodeURIComponent(selectedScene.value.id)}`
    history.pushState({}, '', exploreUrl)
    window.dispatchEvent(new PopStateEvent('popstate'))
  }
}

// 加载数据
onMounted(async () => {
  try {
    // 加载角色和职业数据
    const avatarsRes = await fetch('/mock/avatars.json')
    const avatarsData = await avatarsRes.json()
    characters.value = avatarsData.characters || []
    professions.value = avatarsData.professions || []
    
    // 使用传入的场景数据或从API加载
    if (props.scenarios && props.scenarios.length > 0) {
      scenarios.value = props.scenarios
    } else {
      const tasksData = await getTasks()
      scenarios.value = tasksData.scenarios || []
    }
    
    // 恢复之前的选择
    const savedChar = localStorage.getItem('selectedCharacter')
    const savedProf = localStorage.getItem('selectedProfession')
    
    if (savedChar) {
      const char = JSON.parse(savedChar)
      selectedCharacter.value = characters.value.find(c => c.id === char.id) || null
    }
    
    if (savedProf) {
      const prof = JSON.parse(savedProf)
      selectedProfession.value = professions.value.find(p => p.id === prof.id) || null
    }
  } catch (error) {
    console.error('加载数据失败:', error)
  }
})
</script>

<style scoped lang="scss">
.avatar-customizer {
  display: grid;
  grid-template-columns: 280px 1fr 240px;
  gap: var(--spacing-base);
  min-height: 600px;
  padding: var(--spacing-base);
  background: var(--color-bg-primary);
}

.left-panel,
.right-panel {
  background: var(--color-bg-secondary);
  border-radius: var(--radius-large);
  padding: var(--spacing-base);
  box-shadow: var(--shadow-base);
  display: flex;
  flex-direction: column;
  gap: var(--spacing-base);
}

.panel-header {
  h3 {
    margin: 0;
    font-size: 18px;
    font-weight: 600;
    color: var(--color-text-primary);
    padding-bottom: var(--spacing-small);
    border-bottom: 2px solid var(--color-border);
  }
}

// 角色选择网格
.character-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--spacing-small);
  margin-bottom: var(--spacing-base);
}

.character-item {
  position: relative;
  cursor: pointer;
  padding: var(--spacing-small);
  border-radius: var(--radius-base);
  border: 2px solid transparent;
  transition: var(--transition-base);
  text-align: center;
  
  &:hover {
    background: var(--color-bg-tertiary);
    border-color: var(--color-primary-light);
  }
  
  &.active {
    border-color: #FFD700;
    background: rgba(255, 215, 0, 0.1);
    box-shadow: 0 0 0 2px rgba(255, 215, 0, 0.2);
  }
}

.character-avatar {
  position: relative;
  width: 60px;
  height: 60px;
  margin: 0 auto var(--spacing-small);
  border-radius: var(--radius-base);
  overflow: hidden;
  border: 2px solid var(--color-border);
  
  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
  
  .selected-badge {
    position: absolute;
    top: -4px;
    right: -4px;
    width: 20px;
    height: 20px;
    background: #FFD700;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 12px;
    font-weight: bold;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  }
}

.character-name {
  font-size: 12px;
  font-weight: 500;
  color: var(--color-text-primary);
  margin-bottom: 2px;
}

.character-gender {
  font-size: 10px;
  color: #FFD700;
  font-weight: 600;
}

// 职业选择
.profession-section {
  h4 {
    margin: 0 0 var(--spacing-small) 0;
    font-size: 14px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
}

.profession-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-small);
}

.profession-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  padding: var(--spacing-small);
  border-radius: var(--radius-base);
  border: 1px solid var(--color-border);
  cursor: pointer;
  transition: var(--transition-base);
  
  &:hover {
    background: var(--color-bg-tertiary);
    border-color: var(--color-primary);
  }
  
  &.active {
    background: var(--color-primary);
    color: white;
    border-color: var(--color-primary);
  }
}

.profession-icon {
  font-size: 20px;
}

.profession-name {
  font-size: 13px;
  font-weight: 500;
}

// 属性显示
.attributes-section {
  h4 {
    margin: 0 0 var(--spacing-small) 0;
    font-size: 14px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
}

.attributes-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-small);
}

.attribute-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  padding: var(--spacing-small);
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
  
  .attribute-icon {
    font-size: 16px;
  }
  
  .attribute-label {
    flex: 1;
    font-size: 13px;
    color: var(--color-text-secondary);
  }
  
  .attribute-value {
    font-size: 14px;
    font-weight: 600;
    color: var(--color-primary);
  }
}

// 按钮
.confirm-btn,
.assign-btn {
  width: 100%;
  padding: var(--spacing-base);
  background: linear-gradient(135deg, #FF6B4A 0%, #FF8C69 100%);
  color: white;
  border: none;
  border-radius: var(--radius-base);
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: var(--transition-base);
  margin-top: auto;
  
  &:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(255, 107, 74, 0.4);
  }
  
  &:disabled {
    background: var(--color-text-disabled);
    cursor: not-allowed;
    opacity: 0.6;
  }
}

// 中央预览区
.center-preview {
  background: var(--color-bg-secondary);
  border-radius: var(--radius-large);
  padding: var(--spacing-base);
  box-shadow: var(--shadow-base);
  display: flex;
  align-items: center;
  justify-content: center;
}

.preview-container {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.character-preview {
  text-align: center;
}

.preview-character {
  margin-bottom: var(--spacing-base);
}

.preview-avatar {
  width: 200px;
  height: 200px;
  border-radius: var(--radius-large);
  object-fit: cover;
  border: 3px solid var(--color-primary);
  box-shadow: var(--shadow-large);
  margin-bottom: var(--spacing-base);
}

.character-info {
  h3 {
    margin: 0 0 var(--spacing-small) 0;
    font-size: 20px;
    color: var(--color-text-primary);
  }
  
  p {
    margin: 0;
    font-size: 14px;
    color: var(--color-text-secondary);
  }
}

.equipment-display {
  margin-top: var(--spacing-base);
  padding: var(--spacing-base);
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
  width: 100%;
  max-width: 300px;
  
  h4 {
    margin: 0 0 var(--spacing-small) 0;
    font-size: 14px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
}

.equipment-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-small);
}

.equipment-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  font-size: 12px;
  color: var(--color-text-secondary);
  
  .equipment-icon {
    font-size: 16px;
  }
}

.preview-placeholder {
  text-align: center;
  color: var(--color-text-secondary);
  padding: var(--spacing-large);
}

// 右侧场景列表
.scene-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-small);
  flex: 1;
}

.scene-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  padding: var(--spacing-small);
  border-radius: var(--radius-base);
  border: 1px solid var(--color-border);
  cursor: pointer;
  transition: var(--transition-base);
  
  &:hover {
    background: var(--color-bg-tertiary);
    border-color: var(--color-primary);
  }
  
  &.active {
    background: rgba(123, 107, 82, 0.1);
    border-color: var(--color-primary);
  }
}

.scene-add-btn {
  width: 24px;
  height: 24px;
  border: 1px solid var(--color-primary);
  background: transparent;
  color: var(--color-primary);
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  transition: var(--transition-base);
  
  &:hover {
    background: var(--color-primary);
    color: white;
  }
}

.scene-info {
  flex: 1;
  
  h4 {
    margin: 0 0 2px 0;
    font-size: 13px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
  
  .scene-type {
    margin: 0;
    font-size: 11px;
    color: var(--color-text-secondary);
  }
}

.assign-btn {
  margin-top: var(--spacing-base);
}

// 响应式布局
@media (max-width: 1024px) {
  .avatar-customizer {
    grid-template-columns: 1fr;
    grid-template-rows: auto auto auto;
  }
  
  .center-preview {
    min-height: 300px;
  }
}
</style>

