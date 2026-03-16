"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_controller_1 = require("../controllers/auth.controller");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
router.post('/register', auth_controller_1.register);
router.post('/login', auth_controller_1.login);
router.post('/logout', auth_1.authenticate, auth_controller_1.logout);
router.post('/refresh-token', auth_controller_1.refreshToken);
router.get('/me', auth_1.authenticate, auth_controller_1.getCurrentUser);
router.put('/profile', auth_1.authenticate, auth_controller_1.updateProfile);
router.put('/change-password', auth_1.authenticate, auth_controller_1.changePassword);
exports.default = router;
//# sourceMappingURL=auth.routes.js.map