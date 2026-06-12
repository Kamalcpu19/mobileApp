const express = require('express');
const appointmentService = require('../services/appointmentService');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/', authenticate, async (req, res, next) => {
  try {
    const appointments = await appointmentService.getAppointments(req.user.workshopId, {
      category: req.query.category,
      search: req.query.search,
      date: req.query.date,
    });
    res.json(appointments);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', authenticate, async (req, res, next) => {
  try {
    const appointment = await appointmentService.getAppointmentById(req.params.id, req.user.workshopId);
    if (!appointment) return res.status(404).json({ error: 'Appointment not found' });
    res.json(appointment);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
