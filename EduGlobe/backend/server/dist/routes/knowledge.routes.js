"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
router.use(auth_1.authenticate);
// 知识图谱相关路由
router.get('/nodes', async (req, res) => {
    res.json({ success: true, data: [] });
});
router.get('/nodes/:id', async (req, res) => {
    res.json({ success: true, data: {} });
});
router.get('/relations', async (req, res) => {
    res.json({ success: true, data: [] });
});
exports.default = router;
//# sourceMappingURL=knowledge.routes.js.map