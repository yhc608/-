"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
router.use(auth_1.authenticate);
router.use((0, auth_1.authorize)('student'));
// 虚拟实验路由
router.get('/', async (req, res) => {
    res.json({ success: true, data: [] });
});
router.get('/:id', async (req, res) => {
    res.json({ success: true, data: {} });
});
router.post('/:id/start', async (req, res) => {
    res.json({ success: true, message: '实验开始' });
});
router.post('/:id/submit', async (req, res) => {
    res.json({ success: true, message: '实验结果已提交' });
});
exports.default = router;
//# sourceMappingURL=experiment.routes.js.map