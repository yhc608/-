"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
router.use(auth_1.authenticate);
// 教学资源路由
router.get('/', async (req, res) => {
    res.json({ success: true, data: [] });
});
router.get('/:id', async (req, res) => {
    res.json({ success: true, data: {} });
});
router.post('/upload', async (req, res) => {
    res.json({ success: true, message: '资源上传成功' });
});
exports.default = router;
//# sourceMappingURL=resource.routes.js.map