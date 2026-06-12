const express = require('express');
const customerService = require('../services/customerService');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/messages', authenticate, async (req, res, next) => {
  try {
    const messages = await customerService.getMessages(req.user.workshopId);
    res.json(messages);
  } catch (err) {
    next(err);
  }
});

router.post('/', authenticate, async (req, res, next) => {
  try {
    const customer = await customerService.createOrUpdateCustomer(req.user.workshopId, req.body);
    res.status(201).json(customer);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', authenticate, async (req, res, next) => {
  try {
    const customer = await customerService.getCustomer(req.params.id);
    if (!customer) return res.status(404).json({ error: 'Customer not found' });
    res.json(customer);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
