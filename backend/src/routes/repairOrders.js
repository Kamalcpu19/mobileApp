const express = require('express');
const repairOrderService = require('../services/repairOrderService');
const invoiceService = require('../services/invoiceService');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/', authenticate, async (req, res, next) => {
  try {
    const orders = await repairOrderService.getRepairOrders(req.user.workshopId, {
      stage: req.query.stage,
      search: req.query.search,
    });
    res.json(orders);
  } catch (err) {
    next(err);
  }
});

router.post('/', authenticate, async (req, res, next) => {
  try {
    const order = await repairOrderService.createRepairOrder(req.user.workshopId, req.user.id, req.body);
    res.status(201).json(order);
  } catch (err) {
    next(err);
  }
});

router.get('/stages', authenticate, (req, res) => {
  res.json(repairOrderService.STAGES);
});

router.get('/:id', authenticate, async (req, res, next) => {
  try {
    const order = await repairOrderService.getRepairOrderById(req.params.id, req.user.workshopId);
    if (!order) return res.status(404).json({ error: 'Repair order not found' });
    res.json(order);
  } catch (err) {
    next(err);
  }
});

router.patch('/:id/stage', authenticate, async (req, res, next) => {
  try {
    const order = await repairOrderService.updateStage(req.params.id, req.body.stage, req.user.id, req.body.notes);
    res.json(order);
  } catch (err) {
    next(err);
  }
});

router.get('/:id/timeline', authenticate, async (req, res, next) => {
  try {
    const timeline = await repairOrderService.getStageHistory(req.params.id);
    res.json(timeline);
  } catch (err) {
    next(err);
  }
});

router.post('/:id/close', authenticate, async (req, res, next) => {
  try {
    const order = await repairOrderService.closeJobCard(req.params.id, req.body, req.user.id);
    res.json(order);
  } catch (err) {
    next(err);
  }
});

router.post('/:id/job-card', authenticate, async (req, res, next) => {
  try {
    const jobCard = await invoiceService.createJobCard(req.params.id);
    res.status(201).json(jobCard);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
