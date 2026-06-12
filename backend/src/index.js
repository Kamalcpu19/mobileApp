const express = require('express');
const cors = require('cors');
const config = require('./config');
const { errorHandler } = require('./middleware/validate');

const authRoutes = require('./routes/auth');
const dashboardRoutes = require('./routes/dashboard');
const appointmentRoutes = require('./routes/appointments');
const repairOrderRoutes = require('./routes/repairOrders');
const vehicleRoutes = require('./routes/vehicles');
const inspectionRoutes = require('./routes/inspections');
const complaintRoutes = require('./routes/complaints');
const aiRoutes = require('./routes/ai');
const estimateRoutes = require('./routes/estimates');
const invoiceRoutes = require('./routes/invoices');
const customerRoutes = require('./routes/customers');

const app = express();

app.use(cors({ origin: config.corsOrigin }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'Workshop Service Advisor API' });
});

app.use('/api/auth', authRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/appointments', appointmentRoutes);
app.use('/api/repair-orders', repairOrderRoutes);
app.use('/api/vehicles', vehicleRoutes);
app.use('/api/inspections', inspectionRoutes);
app.use('/api/complaints', complaintRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/estimates', estimateRoutes);
app.use('/api/invoices', invoiceRoutes);
app.use('/api/customers', customerRoutes);

app.use(errorHandler);

const PORT = config.port;
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Workshop Service Advisor API running on port ${PORT}`);
  });
}

module.exports = app;
