const express = require('express');
const inspectionService = require('../services/inspectionService');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/templates', authenticate, async (req, res, next) => {
  try {
    const templates = await inspectionService.getInspectionTemplates(req.user.workshopId, req.query.type || 'pre');
    res.json(templates);
  } catch (err) {
    next(err);
  }
});

router.post('/:repairOrderId/init', authenticate, async (req, res, next) => {
  try {
    const items = await inspectionService.initializeInspection(
      req.params.repairOrderId,
      req.user.workshopId,
      req.body.inspectionType || 'pre'
    );
    res.status(201).json(items);
  } catch (err) {
    next(err);
  }
});

router.get('/:repairOrderId', authenticate, async (req, res, next) => {
  try {
    const items = await inspectionService.getInspectionItems(req.params.repairOrderId, req.query.type);
    res.json(items);
  } catch (err) {
    next(err);
  }
});

router.patch('/items/:itemId', authenticate, async (req, res, next) => {
  try {
    const item = await inspectionService.updateInspectionItem(req.params.itemId, req.body);
    res.json(item);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
