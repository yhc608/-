"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
router.use(auth_1.authenticate);
// 答疑相关路由
router.post('/ask', async (req, res) => {
    res.json({ success: true, data: { answer: 'AI回答' } });
});
router.get('/history', async (req, res) => {
    res.json({ success: true, data: [] });
});
exports.default = router;
//# sourceMappingURL=qa.routes.js.map