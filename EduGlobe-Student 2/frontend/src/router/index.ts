import { createRouter, createWebHistory } from 'vue-router'
import Index from '@/pages/index/index.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'Index',
      component: Index,
      meta: { tab: true }
    },
    {
      path: '/prep',
      name: 'Preparation',
      component: () => import('@/pages/prep/index.vue'),
      meta: { tab: true },
      children: [
        {
          path: 'knowledge-map',
          name: 'KnowledgeMap',
          component: () => import('@/pages/prep/knowledge-map.vue')
        },
        {
          path: 'cards',
          name: 'ConceptCards',
          component: () => import('@/pages/prep/cards.vue')
        },
        {
          path: 'quiz',
          name: 'Quiz',
          component: () => import('@/pages/prep/quiz.vue')
        }
      ]
    },
    {
      path: '/classroom',
      name: 'Classroom',
      component: () => import('@/pages/classroom/index.vue'),
      meta: { tab: true },
      children: [
        {
          path: 'virtual-tutor',
          name: 'VirtualTutor',
          component: () => import('@/pages/classroom/virtual-tutor.vue')
        },
        {
          path: 'games',
          name: 'Games',
          component: () => import('@/pages/classroom/games.vue')
        },
        {
          path: 'qa',
          name: 'QuestionAnswer',
          component: () => import('@/pages/classroom/qa.vue')
        }
      ]
    },
    {
      path: '/review',
      name: 'Review',
      component: () => import('@/pages/review/index.vue'),
      meta: { tab: true },
      children: [
        {
          path: 'channel-square',
          name: 'ChannelSquare',
          component: () => import('@/components/ChannelSquare.vue')
        },
        {
          path: 'ai-qa',
          name: 'AIQuestionAnswer',
          component: () => import('@/pages/review/ai-qa.vue')
        },
        {
          path: 'report',
          name: 'Report',
          component: () => import('@/pages/review/report.vue')
        },
        {
          path: 'resources',
          name: 'Resources',
          component: () => import('@/pages/review/resources.vue')
        }
      ]
    },
    {
      path: '/mine',
      name: 'Mine',
      component: () => import('@/pages/mine/index.vue'),
      meta: { tab: true }
    },
    {
      path: '/settings',
      name: 'Settings',
      component: () => import('@/pages/settings/index.vue'),
      meta: { tab: false }
    },
    {
      path: '/feature/geopolitics',
      name: 'FeatureGeopolitics',
      component: () => import('@/pages/feature/geopolitics/index.vue')
    },
    {
      path: '/feature/geopolitics/detail',
      name: 'FeatureGeopoliticsDetail',
      component: () => import('@/pages/feature/geopolitics/detail.vue')
    },
    {
      path: '/feature/geopolitics/quiz',
      name: 'FeatureGeopoliticsQuiz',
      component: () => import('@/pages/feature/geopolitics/quiz.vue')
    },
    {
      path: '/feature/geopolitics/report',
      name: 'FeatureGeopoliticsReport',
      component: () => import('@/pages/feature/geopolitics/report.vue')
    },
    {
      path: '/feature/companion',
      name: 'FeatureCompanion',
      component: () => import('@/pages/feature/companion/index.vue')
    },
    {
      path: '/feature/companion/question',
      name: 'FeatureCompanionQuestion',
      component: () => import('@/pages/feature/companion/question.vue')
    },
    {
      path: '/feature/companion/compare',
      name: 'FeatureCompanionCompare',
      component: () => import('@/pages/feature/companion/compare.vue')
    },
    {
      path: '/feature/companion/resource',
      name: 'FeatureCompanionResource',
      component: () => import('@/pages/feature/companion/resource.vue')
    },
    {
      path: '/feature/companion/overview',
      name: 'FeatureCompanionOverview',
      component: () => import('@/pages/feature/companion/overview.vue')
    },
    {
      path: '/feature/cyberlab',
      name: 'FeatureCyberlab',
      component: () => import('@/pages/feature/cyberlab/index.vue')
    },
    {
      path: '/feature/cyberlab/experiment',
      name: 'FeatureCyberlabExperiment',
      component: () => import('@/pages/feature/cyberlab/experiment.vue')
    },
    {
      path: '/feature/cyberlab/result',
      name: 'FeatureCyberlabResult',
      component: () => import('@/pages/feature/cyberlab/result.vue')
    },
    {
      path: '/feature/interactive',
      name: 'FeatureInteractive',
      component: () => import('@/pages/feature/interactive/index.vue')
    },
    {
      path: '/feature/interactive/explore',
      name: 'FeatureInteractiveExplore',
      component: () => import('@/pages/feature/interactive/explore.vue')
    },
    {
      path: '/feature/interactive/deep',
      name: 'FeatureInteractiveDeep',
      component: () => import('@/pages/feature/interactive/deep.vue')
    },
    {
      path: '/feature/interactive/highlights',
      name: 'FeatureInteractiveHighlights',
      component: () => import('@/pages/feature/interactive/highlights.vue')
    },
    {
      path: '/feature/scenario',
      name: 'FeatureScenario',
      component: () => import('@/pages/feature/scenario/index.vue')
    },
    {
      path: '/feature/scenario/explore',
      name: 'FeatureScenarioExplore',
      component: () => import('@/pages/feature/scenario/explore.vue')
    },
    {
      path: '/feature/scenario/task',
      name: 'FeatureScenarioTask',
      component: () => import('@/pages/feature/scenario/task.vue')
    },
    {
      path: '/feature/scenario/record',
      name: 'FeatureScenarioRecord',
      component: () => import('@/pages/feature/scenario/record.vue')
    }
  ]
})

// 路由守卫：检查课堂互动模块的访问时间
router.beforeEach((to, _from, next) => {
  // 检查是否是课堂互动页面
  if (to.path.startsWith('/classroom')) {
    // TODO: 检查当前是否在课堂时间
    // const isClassTime = checkClassTime()
    const isClassTime = true // 临时允许访问
    if (!isClassTime) {
      next('/') // 不在课堂时间，跳转到首页
    } else {
      next()
    }
  } else {
    next()
  }
})

export default router