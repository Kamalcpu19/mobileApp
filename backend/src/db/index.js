const sql = require('mssql');
require('dotenv').config();
const { convertPostgresToSqlServer } = require('./queryConverter');

const config = {
  user: process.env.DB_USER || 'sa',
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER || 'localhost',
  database: process.env.DB_NAME || 'workshop_advisor',
  port: parseInt(process.env.DB_PORT || '1433', 10),
  options: {
    encrypt: process.env.DB_ENCRYPT !== 'false',
    trustServerCertificate: process.env.DB_TRUST_CERT !== 'false',
    enableArithAbort: true,
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000,
  },
};

let poolPromise;

async function getPool() {
  if (!poolPromise) {
    poolPromise = sql.connect(config);
  }
  return poolPromise;
}

function inferSqlType(value) {
  if (value === null || value === undefined) return sql.NVarChar;
  if (typeof value === 'boolean') return sql.Bit;
  if (typeof value === 'number') {
    return Number.isInteger(value) ? sql.Int : sql.Decimal(18, 2);
  }
  if (value instanceof Date) return sql.DateTime2;
  if (typeof value === 'string' && value.length > 4000) return sql.NVarChar(sql.MAX);
  return sql.NVarChar;
}

async function query(text, params = []) {
  const pool = await getPool();
  const request = pool.request();
  const convertedSql = convertPostgresToSqlServer(text);

  params.forEach((value, index) => {
    const paramName = `p${index + 1}`;
    if (value === null || value === undefined) {
      request.input(paramName, sql.NVarChar, null);
      return;
    }
    request.input(paramName, inferSqlType(value), value);
  });

  const result = await request.query(convertedSql);
  return { rows: result.recordset || [] };
}

async function closePool() {
  if (poolPromise) {
    await sql.close();
    poolPromise = null;
  }
}

module.exports = {
  query,
  closePool,
  pool: { end: closePool },
  sql,
};
