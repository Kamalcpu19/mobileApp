const express = require('express');
const aiService = require('../services/aiService');
const estimateService = require('../services/estimateService');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/settings', authenticate, async (req, res, next) => {
  try {
    const settings = await aiService.getAutomationSettings(req.user.workshopId);
    res.json(settings);
  } catch (err) {
    next(err);
  }
});

router.get('/recommendations/:repairOrderId', authenticate, async (req, res, next) => {
  try {
    const recommendations = await aiService.getRecommendations(req.params.repairOrderId);
    res.json(recommendations);
  } catch (err) {
    next(err);
  }
});

router.patch('/recommendations/:id/select', authenticate, async (req, res, next) => {
  try {
    const rec = await aiService.selectRecommendation(req.params.id, req.body.isSelected);
    res.json(rec);
  } catch (err) {
    next(err);
  }
});

router.post('/estimate/:repairOrderId', authenticate, async (req, res, next) => {
  try {
    const result = await aiService.generateEstimate(req.params.repairOrderId, req.user.workshopId);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

router.post('/payment-reminder', authenticate, async (req, res, next) => {
  try {
    const message = await aiService.generatePaymentReminder(
      req.body.type,
      req.body.customerName,
      req.body.amount,
      req.body.dueDate
    );
    res.json({ message });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
