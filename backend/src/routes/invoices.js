const express = require('express');
const invoiceService = require('../services/invoiceService');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/pending', authenticate, async (req, res, next) => {
  try {
    const payments = await invoiceService.getPendingPayments(req.user.workshopId);
    res.json(payments);
  } catch (err) {
    next(err);
  }
});

router.get('/:repairOrderId', authenticate, async (req, res, next) => {
  try {
    const invoice = await invoiceService.getInvoice(req.params.repairOrderId);
    res.json(invoice);
  } catch (err) {
    next(err);
  }
});

router.post('/:repairOrderId/generate', authenticate, async (req, res, next) => {
  try {
    const invoice = await invoiceService.generateInvoice(req.params.repairOrderId);
    res.status(201).json(invoice);
  } catch (err) {
    next(err);
  }
});

router.post('/:invoiceId/pay', authenticate, async (req, res, next) => {
  try {
    const invoice = await invoiceService.recordPayment(req.params.invoiceId, req.body.amount, req.body.method);
    res.json(invoice);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
