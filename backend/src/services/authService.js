const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../db');
const config = require('../config');

async function login(username, password) {
  const result = await db.query(
    `SELECT u.*, w.name as workshop_name, w.country_code
     FROM users u
     JOIN workshops w ON u.workshop_id = w.id
     WHERE u.username = $1 AND u.is_active = TRUE`,
    [username]
  );

  if (result.rows.length === 0) {
    const error = new Error('Invalid credentials');
    error.status = 401;
    throw error;
  }

  const user = result.rows[0];
  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) {
    const error = new Error('Invalid credentials');
    error.status = 401;
    throw error;
  }

  const token = jwt.sign(
    {
      id: user.id,
      username: user.username,
      workshopId: user.workshop_id,
      role: user.role,
    },
    config.jwt.secret,
    { expiresIn: config.jwt.expiresIn }
  );

  return {
    token,
    user: {
      id: user.id,
      username: user.username,
      fullName: user.full_name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      workshopId: user.workshop_id,
      workshopName: user.workshop_name,
      countryCode: user.country_code,
    },
  };
}

async function getProfile(userId) {
  const result = await db.query(
    `SELECT u.id, u.username, u.full_name, u.email, u.phone, u.role, u.avatar_url,
            w.id as workshop_id, w.name as workshop_name, w.address, w.phone as workshop_phone, w.email as workshop_email
     FROM users u
     JOIN workshops w ON u.workshop_id = w.id
     WHERE u.id = $1`,
    [userId]
  );
  return result.rows[0];
}

module.exports = { login, getProfile };
