const express = require('express');
const dashboardService = require('../services/dashboardService');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/counts', authenticate, async (req, res, next) => {
  try {
    const counts = await dashboardService.getDashboardCounts(req.user.workshopId);
    res.json(counts);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
