"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
router.use(auth_1.authenticate);
// 报告相关路由
router.get('/learning/:type', async (req, res) => {
    res.json({ success: true, data: {} });
});
router.get('/teaching/:classId', async (req, res) => {
    res.json({ success: true, data: {} });
});
exports.default = router;
//# sourceMappingURL=report.routes.js.map