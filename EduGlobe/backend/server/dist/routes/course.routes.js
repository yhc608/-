"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
router.use(auth_1.authenticate);
// 课程相关路由
router.get('/', async (req, res) => {
    res.json({ success: true, data: [] });
});
router.get('/:id', async (req, res) => {
    res.json({ success: true, data: {} });
});
router.post('/', async (req, res) => {
    res.json({ success: true, message: '课程创建成功' });
});
exports.default = router;
//# sourceMappingURL=course.routes.js.map