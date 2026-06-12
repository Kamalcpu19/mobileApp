const express = require('express');
const { body } = require('express-validator');
const authService = require('../services/authService');
const { validate } = require('../middleware/validate');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.post(
  '/login',
  [
    body('username').notEmpty().withMessage('Username is required'),
    body('password').notEmpty().withMessage('Password is required'),
  ],
  validate,
  async (req, res, next) => {
    try {
      const result = await authService.login(req.body.username, req.body.password);
      res.json(result);
    } catch (err) {
      next(err);
    }
  }
);

router.get('/profile', authenticate, async (req, res, next) => {
  try {
    const profile = await authService.getProfile(req.user.id);
    res.json(profile);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
