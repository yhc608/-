<template>
  <div class="feature-page">
    <header class="feature-header">
      <button class="link" @click="$router.back()">返回</button>
      <h2>第一视角探索 · {{ sceneName }}</h2>
      <nav>
        <button class="link" @click="goTask">任务</button>
        <button class="link" @click="goRecord">记录</button>
      </nav>
    </header>
    <FirstPersonView @interact="onInteract" />
    <KnowledgePopup v-if="popup" :content="popup" @close="popup=''" />
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, computed } from 'vue';
import FirstPersonView from './components/FirstPersonView.vue';
import KnowledgePopup from './components/KnowledgePopup.vue';

const sceneId = ref('volcano_observation');
const sceneName = ref('加载中');
const popup = ref('');

// 获取保存的角色和职业信息
const selectedCharacter = computed(() => {
  const saved = localStorage.getItem('selectedCharacter');
  return saved ? JSON.parse(saved) : null;
});

const selectedProfession = computed(() => {
  const saved = localStorage.getItem('selectedProfession');
  return saved ? JSON.parse(saved) : null;
});

// 计算当前装备（根据场景自动调整）
const currentEquipment = computed(() => {
  if (!selectedProfession.value || !sceneId.value) {
    return [];
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
  };
  
  const equipmentType = sceneEquipmentMap[sceneId.value] || 'base';
  const sceneEquipment = selectedProfession.value.equipment?.[equipmentType] || [];
  const baseEquipment = selectedProfession.value.equipment?.base || [];
  
  // 合并基础装备和场景特定装备
  return [...baseEquipment, ...sceneEquipment];
});

onMounted(async () => {
  const id = new URL(location.href).searchParams.get('id') || 'volcano_observation';
  sceneId.value = id;
  // 从API获取场景名称
  try {
    const { getTasks } = await import('../../../services/api');
    const data = await getTasks();
    const scene = data.scenarios?.find((s: any) => s.id === id);
    sceneName.value = scene?.name || id;
  } catch (error) {
    sceneName.value = id;
  }
  
  // 如果没有选择角色，提示用户返回选择
  if (!selectedCharacter.value || !selectedProfession.value) {
    console.warn('未选择角色或职业，请返回场景大厅进行选择');
  }
});
function onInteract(type:string){
  const messages: Record<string, string> = {
    observe: '观测到喷发物：火山灰与熔岩流，注意记录地貌变化。',
    measure: '完成坡度测量：坡度 35°，建议分析水土流失风险。',
    explain: '请根据气压差和热力环流解释该区域季风方向。',
    record: '已保存探索位置至日志，可前往“记录”查看。'
  };
  popup.value = messages[type] || messages.observe;
}
function goTask() {
  history.pushState({}, '', `/feature/scenario/task?id=${encodeURIComponent(sceneId.value)}`);
  window.dispatchEvent(new PopStateEvent('popstate'));
}
function goRecord() {
  history.pushState({}, '', `/feature/scenario/record?id=${encodeURIComponent(sceneId.value)}`);
  window.dispatchEvent(new PopStateEvent('popstate'));
}
</script>

<style scoped>
.feature-page { padding: 16px; }
</style>


