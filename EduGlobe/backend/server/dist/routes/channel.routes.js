"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
router.use(auth_1.authenticate);
// 地学交流频道路由
router.get('/', async (req, res) => {
    res.json({ success: true, data: [] });
});
router.post('/', async (req, res) => {
    res.json({ success: true, message: '频道创建成功' });
});
router.get('/:id/posts', async (req, res) => {
    res.json({ success: true, data: [] });
});
router.post('/:id/posts', async (req, res) => {
    res.json({ success: true, message: '帖子发布成功' });
});
exports.default = router;
//# sourceMappingURL=channel.routes.js.map