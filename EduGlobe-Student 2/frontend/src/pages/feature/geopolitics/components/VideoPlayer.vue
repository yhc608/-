<template>
  <div class="video-player">
    <div class="player-header">
      <h4>📹 热点视频讲解</h4>
      <button v-if="hasAudio" class="audio-btn" @click="toggleAudio">
        <span class="material-icons">{{ audioPlaying ? 'volume_up' : 'volume_off' }}</span>
        {{ audioPlaying ? '关闭语音' : '开启语音' }}
      </button>
    </div>
    <div class="video-container">
      <video 
        ref="videoRef"
        :src="videoUrl"
        controls
        @play="handlePlay"
        @pause="handlePause"
        @ended="handleEnded"
      >
        您的浏览器不支持视频播放
      </video>
      <div v-if="!videoUrl" class="video-placeholder">
        <div class="placeholder-content">
          <span class="material-icons">play_circle_outline</span>
          <p>视频加载中...</p>
          <p class="video-description">{{ description }}</p>
        </div>
      </div>
    </div>
    <div v-if="audioScript" class="audio-script">
      <h5>语音讲解内容：</h5>
      <p>{{ audioScript }}</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onBeforeUnmount } from 'vue';

const props = defineProps<{
  videoUrl?: string;
  audioUrl?: string;
  description?: string;
  audioScript?: string;
}>();

const videoRef = ref<HTMLVideoElement | null>(null);
const audioRef = ref<HTMLAudioElement | null>(null);
const audioPlaying = ref(false);
const videoPlaying = ref(false);

const hasAudio = computed(() => !!props.audioUrl);

onMounted(() => {
  if (props.audioUrl) {
    audioRef.value = new Audio(props.audioUrl);
    audioRef.value.addEventListener('ended', () => {
      audioPlaying.value = false;
    });
  }
});

onBeforeUnmount(() => {
  if (audioRef.value) {
    audioRef.value.pause();
    audioRef.value = null;
  }
});

function toggleAudio() {
  if (!audioRef.value) return;
  
  if (audioPlaying.value) {
    audioRef.value.pause();
    audioPlaying.value = false;
  } else {
    audioRef.value.play();
    audioPlaying.value = true;
  }
}

function handlePlay() {
  videoPlaying.value = true;
  // 如果视频播放，可以同步播放音频
  if (audioRef.value && audioPlaying.value) {
    audioRef.value.play();
  }
}

function handlePause() {
  videoPlaying.value = false;
  if (audioRef.value) {
    audioRef.value.pause();
  }
}

function handleEnded() {
  videoPlaying.value = false;
  if (audioRef.value) {
    audioRef.value.pause();
    audioPlaying.value = false;
  }
}
</script>

<style scoped lang="scss">
.video-player {
  background: var(--color-bg-secondary);
  border-radius: var(--radius-base);
  padding: var(--spacing-base);
  margin-bottom: var(--spacing-base);
}

.player-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-base);
  
  h4 {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
}

.audio-btn {
  display: flex;
  align-items: center;
  gap: var(--spacing-small);
  padding: var(--spacing-small) var(--spacing-base);
  background: var(--color-primary);
  color: white;
  border: none;
  border-radius: var(--radius-base);
  cursor: pointer;
  font-size: 12px;
  transition: var(--transition-base);
  
  &:hover {
    background: var(--color-primary-dark);
  }
  
  .material-icons {
    font-size: 18px;
  }
}

.video-container {
  position: relative;
  width: 100%;
  background: #000;
  border-radius: var(--radius-base);
  overflow: hidden;
  
  video {
    width: 100%;
    height: auto;
    display: block;
  }
}

.video-placeholder {
  width: 100%;
  height: 300px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  
  .placeholder-content {
    text-align: center;
    color: white;
    
    .material-icons {
      font-size: 64px;
      margin-bottom: var(--spacing-base);
    }
    
    p {
      margin: var(--spacing-small) 0;
      font-size: 14px;
    }
    
    .video-description {
      font-size: 12px;
      opacity: 0.9;
    }
  }
}

.audio-script {
  margin-top: var(--spacing-base);
  padding: var(--spacing-base);
  background: var(--color-bg-tertiary);
  border-radius: var(--radius-base);
  border-left: 3px solid var(--color-primary);
  
  h5 {
    margin: 0 0 var(--spacing-small) 0;
    font-size: 14px;
    font-weight: 600;
    color: var(--color-text-primary);
  }
  
  p {
    margin: 0;
    font-size: 13px;
    line-height: 1.6;
    color: var(--color-text-secondary);
  }
}
</style>







