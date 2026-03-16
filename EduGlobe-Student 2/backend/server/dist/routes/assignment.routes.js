"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
router.use(auth_1.authenticate);
// 作业相关路由
router.get('/', async (req, res) => {
    res.json({ success: true, data: [] });
});
router.post('/', async (req, res) => {
    res.json({ success: true, message: '作业创建成功' });
});
router.post('/:id/submit', async (req, res) => {
    res.json({ success: true, message: '作业提交成功' });
});
exports.default = router;
//# sourceMappingURL=assignment.routes.js.map