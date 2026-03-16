# EduGlobe-Student（new-project）架构与接口说明

本说明文档面向需要在本项目基础上替换/接入各类智能模型（识别、问答、推荐、知识图谱等）的工程师，系统性说明本项目的框架选型、目录结构、路由设计、页面与组件职责、工具方法、数据流以及可替换的模型接口规范，确保后续可复用并复刻相同的产品能力与交互逻辑。

## 1. 技术栈与基础设施
- 前端框架：Vue 3（Composition API）
- 构建工具：Vite
- 语言：TypeScript
- 路由：vue-router v4（HTML5 history 模式）
- 样式：SCSS（全局样式位于 `src/styles/global.scss`）
- 可视化：ECharts（`echarts`）
- 3D：three.js（`three`）

关键入口：
- `src/main.ts`：创建应用并挂载路由
- `src/router/index.ts`：声明路由表与路由守卫
- `vite.config.ts`：Vite 开发服务器与插件配置
- `package.json`：依赖与脚本（`dev`/`build`/`preview`）

## 2. 目录结构与职责边界（关键路径）
```
src/
  App.vue                 # 根组件（应用级布局/路由出口/全局样式入口）
  main.ts                 # 入口文件，注册路由并挂载应用
  router/
    index.ts              # 路由表与路由守卫
  styles/
    global.scss           # 全局样式变量与通用样式
  utils/
    feature.ts            # 动态能力开关/灰度能力检测（示例：课堂 Tab 显隐）
    offline.ts            # 本地缓存工具（带过期时间）
  components/
    TabBar.vue            # 底部导航（依据路由 meta.tab 显示）
    ChannelSquare.vue     # 渠道广场（复习区子路由）
    UserSelection.vue     # 用户/身份选择组件（示例）
  pages/
    index/                # 首页
      index.vue
    prep/                 # 课前预习
      index.vue
      knowledge-map.vue   # 知识图谱/知识点导航
      cards.vue           # 概念卡片
      quiz.vue            # 小测
    classroom/            # 课堂互动
      index.vue
      virtual-tutor.vue   # 虚拟助教（模型交互位点之一）
      games.vue           # 课堂小游戏
      qa.vue              # 课堂问答（模型交互位点之一）
    review/               # 课后复习
      index.vue
      ai-qa.vue           # AI 错题识别/讲解/推荐（模型交互位点之二）
      report.vue          # 学情报告
      resources.vue       # 资源推荐
    settings/
      index.vue           # 设置页
```

职责说明：
- `pages/**`：场景页，承载明确业务流程（预习/课堂/复习/设置）。
- `components/**`：跨场景复用 UI 组件与复合交互组件。
- `utils/**`：与业务弱相关的通用工具（缓存、能力检测）。
- `router/**`：导航结构、鉴权/准入策略、懒加载边界。

## 3. 路由设计与导航逻辑
- 使用 `createWebHistory()`，主导航由四大分区组成：`/`（首页）、`/prep`（预习）、`/classroom`（课堂）、`/review`（复习）、`/settings`（设置）。
- 子路由按业务模块拆分，采用路由懒加载。
- 元信息 `meta.tab: true` 用于控制底部 `TabBar` 的显示。
- 路由守卫：在 `router.beforeEach` 中对 `/classroom/**` 增加访问时段校验（示例中暂以 `isClassTime = true` 占位）。

示例（节选）：
```12:93:src/router/index.ts
const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', name: 'Index', component: Index, meta: { tab: true } },
    { path: '/prep', name: 'Preparation', component: () => import('../pages/prep/index.vue'), meta: { tab: true }, children: [...] },
    { path: '/classroom', name: 'Classroom', component: () => import('../pages/classroom/index.vue'), meta: { tab: true }, children: [...] },
    { path: '/review', name: 'Review', component: () => import('../pages/review/index.vue'), meta: { tab: true }, children: [...] },
    { path: '/settings', name: 'Settings', component: () => import('../pages/settings/index.vue'), meta: { tab: true } }
  ]
})

router.beforeEach((to, from, next) => {
  if (to.path.startsWith('/classroom')) {
    const isClassTime = true // TODO: 接入实际课堂时段校验
    if (!isClassTime) next('/')
    else next()
  } else {
    next()
  }
})
```

## 4. 状态管理与数据流
本项目未引入集中式状态管理（如 Pinia/Redux），当前数据以页面局部 `ref`/`computed` 管理，必要时可通过：
- 在 `pages/**` 中拉取接口数据，向下传递给 `components/**`；
- 将跨页面的轻量状态（如开关、最近选择）放入 `utils/offline.ts` 的本地缓存；
- 如需更复杂的跨页状态与异步链路，建议引入 Pinia 并在此文档补充 store 规范。

本地缓存工具（节选）：
```1:6:src/utils/offline.ts
export function setCache<T>(key:string, data:T){ uni.setStorageSync(key, { data, ts:Date.now() }) }
export function getCache<T>(key:string, maxAgeMs=7*24*3600*1000): T|null {
  const v = uni.getStorageSync(key); if(!v) return null
  if(Date.now()-v.ts>maxAgeMs) return null
  return v.data as T
}
```
说明：当前实现调用了 `uni.setStorageSync/getStorageSync`，这是从历史 uni-app 代码迁移保留的 API 名称。若运行在纯 Web 环境，请用 `localStorage` 或自定义存储适配器替换（见第 9 节“环境与适配”）。

## 5. 关键页面与模型对接位点

### 5.1 复习区 AI 问答（`pages/review/ai-qa.vue`）
功能分层：
- 错题拍照与图片选择（`openCamera/openGallery` 占位）
- 图片解析并生成结构化分析结果（`analyzeImage`）
- 错误点归因、知识点关联、推荐练习生成
- 错题本管理、筛选/排序、同类题练习、复习提醒

当前为前端 mock 流程，核心注入点：
- `analyzeImage()`：对图片进行 OCR/题目解析与理解，返回结构化结果
- `findSimilarQuestions()`：基于错题检索相似题目
- `submitPractice()`：对练习提交做评测反馈与难度自适应调整（可后端化）
- `saveReminderSettings()`：保存复习提醒偏好并下发日程（可后端化）

数据结构（前端预期示例）：
```582:612:src/pages/review/ai-qa.vue
const mockAnalysisResult = {
  question: '...题干...',
  subject: '自然地理',
  chapter: '地球运动',
  difficulty: 4,
  errorPoints: [{ id:'e1', type:'计算错误', level:'严重', description:'...' }],
  knowledgePoints: [{ id:'k1', name:'太阳高度角', description:'...', page:25 }],
  recommendedPractice: [{ id:'p1', title:'...', questionCount:5, estimatedTime:15 }]
}
```

### 5.2 课堂互动（`pages/classroom/**`）
位点：
- `virtual-tutor.vue`：课堂虚拟助教（语义问答/口语陪练/引导）
- `qa.vue`：课堂问答（实时/轮次问答、可加评分）
- `games.vue`：互动小游戏（可接模型生成题/规则）
进入控制：路由守卫按时段准入，或接入教师端信令验证。

### 5.3 预习区（`pages/prep/**`）
- `knowledge-map.vue`：展示知识图谱与章节关系（可由模型或后端生成/更新图）
- `cards.vue`：概念卡片（关键信息提炼与生成）
- `quiz.vue`：小测（基于知识点出题/自适应）

## 6. 能力开关与特性探测
`utils/feature.ts` 用于控制某些特性是否展示。例如课堂 Tab 显隐：
```1:12:src/utils/feature.ts
export function shouldShowClassTab(): Promise<boolean> {
  return new Promise((resolve) => {
    uni.request({ url: 'https://api.example.com/class/status', timeout: 300,
      success: (resp:any)=>{ try{ resolve(Boolean(resp?.data?.open)) }catch{ resolve(false) } },
      fail: ()=> resolve(false)
    })
  })
}
```
说明：此处同样使用了 `uni.request`，可替换为 `fetch/axios` 或自定义 `httpClient`，并在第 9 节的适配层中统一处理。

## 7. 可替换的模型接口规范（建议）
为实现“换模型不改业务”，推荐在前端与模型服务之间定义稳定的 HTTP/WS 契约，并在前端只依赖这些契约。以下为建议协议，可按实际后端实现做映射层。

1) 题图解析与错因分析
- Endpoint：`POST /api/ai/ocr-analyze`
- Request（JSON）：
```json
{ "imageBase64": "data:image/jpeg;base64,...", "lang": "zh", "scene": "exam|textbook|notebook" }
```
- Response（JSON）：
```json
{
  "question": "题目文本",
  "subject": "学科",
  "chapter": "章节名",
  "difficulty": 1,
  "errorPoints": [{ "id":"e1","type":"计算错误","level":"严重","description":"..." }],
  "knowledgePoints": [{ "id":"k1","name":"知识点","description":"...","page":25 }],
  "recommendedPractice": [{ "id":"p1","title":"练习名","questionCount":5,"estimatedTime":15 }]
}
```

2) 相似题检索
- Endpoint：`POST /api/ai/similar-questions`
- Request：`{ "question": "题干文本", "tags": ["地球运动","太阳高度角"] }`
- Response：
```json
{
  "items": [
    { "id":"sq1","type":"choice","content":"...","options":[{"key":"A","text":"..."},...],"correctAnswer":"B" },
    { "id":"sq2","type":"text","content":"...", "correctAnswer":"参考答案..." }
  ]
}
```

3) 课堂虚拟助教对话（可选流式）
- Endpoint（HTTP）：`POST /api/ai/assistant`
- Request：`{ "messages":[{"role":"user","content":"..."}], "sessionId":"...", "mode":"classroom" }`
- Response：`{ "reply":"..." , "meta":{ "citations":[], "actions":[] } }`
- 若需流式：WebSocket/Server-Sent Events，前端仅需消费 `delta` 字段

4) 学情与报告生成
- Endpoint：`POST /api/ai/report`
- Request：`{ "history": [...练习与问答记录...], "dimension":["accuracy","mastery","time"], "period":"7d" }`
- Response：`{ "summary":"...", "charts":[{ "type":"line","data":{...} }], "insights":[...] }`

5) 能力开关/活动时段
- Endpoint：`GET /api/class/status`
- Response：`{ "open": true }`

统一错误：
```json
{ "error": { "code": "BadRequest|ModelOverload|Timeout|Internal", "message": "..." } }
```

## 8. 业务流程（高层）

- 错题识别与复习（`/review/ai-qa`）
  1. 用户拍照/上传 → 显示预览
  2. 点击“开始分析” → 调用 OCR+理解服务 → 返回结构化结果
  3. 展示题干、错因、知识点 → 提供“保存到错题本”
  4. 基于知识点生成推荐练习 → 同类题练习 → 记录复习次数/正确率，滚动调整复习间隔
  5. 可设置复习提醒（本地或后端）

- 课堂互动（`/classroom/*`）
  1. 进入路由时做时段校验
  2. 虚拟助教/问答/小游戏模块按需调用模型服务
  3. 互动数据沉淀至学情报告

- 预习（`/prep/*`）
  1. 基于章节/知识图谱浏览内容
  2. 概念卡片与小测可由模型动态生成/整编

## 9. 环境与适配
- 运行命令：
  - 开发：`npm run dev`
  - 构建：`npm run build`
  - 预览：`npm run preview`
- 端口：默认 5173，可在 `vite.config.ts` 修改。
- 适配 `uni.*` API：本仓库保留了部分 uni-app 时代的调用（如 `uni.request`、`uni.setStorageSync`）。若运行在纯 Web 环境：
  - 将 `utils/offline.ts` 替换为使用 `localStorage` 或 IndexedDB；
  - 将 `utils/feature.ts` 的 `uni.request` 替换为 `fetch/axios`；
  - 或者新增一个 `src/utils/adapters.ts`，导出统一的 `httpClient` 与 `storage` 接口，在全局仅依赖该适配层，以便后续一键替换运行环境。

## 10. 扩展与二次开发建议
- 引入 Pinia 管理跨页面状态（错题本/练习记录/用户偏好/课堂会话）。
- 将所有模型调用统一封装到 `src/services/ai.ts`，内部做供应商/模型路由、多路重试与降级。
- 为 ECharts 与 three.js 场景建立 `hooks/` 封装，统一初始化与销毁，降低页面复杂度。
- 增加 `env` 配置（如 `VITE_API_BASE_URL`）并统一通过 `httpClient` 注入。
- 所有可训练/可替换模型，务必以“契约优先”设计（即本文件第 7 节的接口规范），前端只依赖契约与适配层。

## 11. 已知占位与待接入点
- `router.beforeEach` 中课堂时段校验为占位，需接后台接口。
- `pages/review/ai-qa.vue` 的拍照/相册、分析、相似题、提醒等均为前端模拟，应替换为实际服务。
- `utils/feature.ts` 的 `uni.request` 需要环境适配或替换为统一 `httpClient`。

---
如需在此基础上替换成其他大模型（OCR/问答/检索/推荐），只需：
1) 实现第 7 节的接口契约（或在前端 `services/ai.ts` 做参数/返回的映射）；
2) 在对应页面的方法里调用新服务（`analyzeImage`、`findSimilarQuestions`、`assistant` 等）；
3) 保持返回结构与前端展示数据结构一致，即可无缝复用现有 UI 与交互。


