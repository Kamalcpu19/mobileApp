const express = require('express');
const complaintService = require('../services/complaintService');
const aiService = require('../services/aiService');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/:repairOrderId', authenticate, async (req, res, next) => {
  try {
    const complaints = await complaintService.getComplaints(req.params.repairOrderId);
    res.json(complaints);
  } catch (err) {
    next(err);
  }
});

router.post('/:repairOrderId', authenticate, async (req, res, next) => {
  try {
    const complaint = await complaintService.addComplaint(
      req.params.repairOrderId,
      req.body.description,
      req.body.source || 'manual'
    );
    res.status(201).json(complaint);
  } catch (err) {
    next(err);
  }
});

router.post('/:repairOrderId/analyze', authenticate, async (req, res, next) => {
  try {
    const result = await aiService.analyzeComplaints(req.params.repairOrderId, req.user.workshopId);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
