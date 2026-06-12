const express = require('express');
const vehicleService = require('../services/vehicleService');
const aiService = require('../services/aiService');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

router.get('/lookup/:registrationNumber', authenticate, async (req, res, next) => {
  try {
    const vehicle = await vehicleService.lookupVehicle(req.user.workshopId, req.params.registrationNumber);
    if (!vehicle) return res.status(404).json({ error: 'Vehicle not found', detected: false });

    const history = await vehicleService.getServiceHistory(vehicle.id);
    res.json({ ...vehicle, detected: true, ...history });
  } catch (err) {
    next(err);
  }
});

router.post('/', authenticate, async (req, res, next) => {
  try {
    const vehicle = await vehicleService.createOrUpdateVehicle(req.user.workshopId, req.body);
    res.status(201).json(vehicle);
  } catch (err) {
    next(err);
  }
});

router.get('/:id/history', authenticate, async (req, res, next) => {
  try {
    const history = await vehicleService.getServiceHistory(req.params.id);
    res.json(history);
  } catch (err) {
    next(err);
  }
});

router.get('/:id/images', authenticate, async (req, res, next) => {
  try {
    const images = await vehicleService.getVehicleImages(req.params.id);
    res.json(images);
  } catch (err) {
    next(err);
  }
});

router.post('/:id/images', authenticate, async (req, res, next) => {
  try {
    await vehicleService.saveVehicleImage(req.params.id, req.body.imageType, req.body.imageUrl);
    res.status(201).json({ success: true });
  } catch (err) {
    next(err);
  }
});

router.post('/ocr', authenticate, async (req, res, next) => {
  try {
    const result = await aiService.recognizeNumberPlate(req.body.imageBase64);
    if (result.detected && result.registrationNumber) {
      const vehicle = await vehicleService.lookupVehicle(req.user.workshopId, result.registrationNumber);
      if (vehicle) {
        const history = await vehicleService.getServiceHistory(vehicle.id);
        return res.json({ ...result, vehicle, ...history });
      }
    }
    res.json(result);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
