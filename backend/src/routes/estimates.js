const express = require('express');
const estimateService = require('../services/estimateService');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/:repairOrderId', authenticate, async (req, res, next) => {
  try {
    const estimate = await estimateService.getEstimate(req.params.repairOrderId);
    res.json(estimate);
  } catch (err) {
    next(err);
  }
});

router.post('/:repairOrderId', authenticate, async (req, res, next) => {
  try {
    const estimate = await estimateService.createEstimate(req.params.repairOrderId);
    res.status(201).json(estimate);
  } catch (err) {
    next(err);
  }
});

router.post('/:estimateId/items', authenticate, async (req, res, next) => {
  try {
    const item = await estimateService.addLineItem(req.params.estimateId, req.body);
    res.status(201).json(item);
  } catch (err) {
    next(err);
  }
});

router.post('/:estimateId/submit', authenticate, async (req, res, next) => {
  try {
    const estimate = await estimateService.submitForApproval(req.params.estimateId);
    res.json(estimate);
  } catch (err) {
    next(err);
  }
});

router.post('/approve/:token', async (req, res, next) => {
  try {
    const estimate = await estimateService.getEstimateByToken(req.params.token);
    if (!estimate) return res.status(404).json({ error: 'Invalid approval link' });
    const result = await estimateService.approveEstimate(estimate.id, req.body.approvals);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

router.get('/approve/:token', async (req, res, next) => {
  try {
    const estimate = await estimateService.getEstimateByToken(req.params.token);
    if (!estimate) return res.status(404).json({ error: 'Invalid approval link' });
    res.json(estimate);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
